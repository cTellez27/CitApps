import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<void> resetPassword({
    required String email,
  });

  Future<UserModel?> getCurrentUser();

  Future<UserModel> createBarbershop({
    required String name,
    required String phone,
    required String address,
  });

  Stream<UserModel?> get onAuthStateChanged;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final sb.SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(message: 'El usuario no pudo autenticarse');
      }

      return await _getUserProfile(response.user!.id, response.user!.email);
    } on sb.AuthException catch (e) {
      throw AuthException(message: _mapAuthErrorMessage(e.message));
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'owner', // El primer usuario registrado es dueño
        },
      );

      if (response.user == null) {
        throw const AuthException(message: 'Error al registrar el usuario');
      }

      // Esperar brevemente a que el trigger de base de datos se ejecute
      await Future.delayed(const Duration(milliseconds: 500));

      return await _getUserProfile(response.user!.id, response.user!.email);
    } on sb.AuthException catch (e) {
      throw AuthException(message: _mapAuthErrorMessage(e.message));
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw AuthException(message: _mapAuthErrorMessage(e.message));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;
      return await _getUserProfile(user.id, user.email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> createBarbershop({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      // 1. Create barbershop
      final barbershop = await supabase.from(DbTables.barbershops).insert({
        'name': name,
        'phone': phone,
        'address': address,
      }).select().single();

      final barbershopId = barbershop['id'] as String;
      final userId = supabase.auth.currentUser!.id;

      // 2. Update user profile to link to the new barbershop
      final profile = await supabase.from(DbTables.profiles).update({
        'barbershop_id': barbershopId,
      }).eq('id', userId).select().single();

      return UserModel.fromJson(profile, email: supabase.auth.currentUser!.email);
    } catch (e) {
      throw ServerException(message: 'Error al registrar la barbería: $e');
    }
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return supabase.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;

      try {
        return await _getUserProfile(session.user.id, session.user.email);
      } catch (_) {
        return null;
      }
    });
  }

  /// Helper to fetch and map a user's profile from the DB.
  Future<UserModel> _getUserProfile(String uid, String? email) async {
    try {
      final data = await supabase
          .from(DbTables.profiles)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data == null) {
        throw const NotFoundException(message: 'No se encontró el perfil de usuario');
      }

      return UserModel.fromJson(data, email: email);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: 'Error al consultar perfil en base de datos: $e');
    }
  }

  /// Map common Supabase Auth error messages to user friendly Spanish versions.
  String _mapAuthErrorMessage(String msg) {
    if (msg.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('User already registered')) {
      return 'Este correo electrónico ya está registrado';
    }
    if (msg.contains('Signup requires a valid password')) {
      return 'Contraseña no válida';
    }
    return msg;
  }
}
