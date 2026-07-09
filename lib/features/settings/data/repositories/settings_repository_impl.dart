import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/barbershop_entity.dart';
import '../../domain/entities/barbershop_hours_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/barbershop_model.dart';
import '../models/barbershop_hours_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  const SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BarbershopEntity>> getBarbershop(String id) async {
    try {
      final model = await remoteDataSource.getBarbershop(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarbershopEntity>> updateBarbershop(
    BarbershopEntity barbershop,
  ) async {
    try {
      final model = BarbershopModel.fromEntity(barbershop);
      final updated = await remoteDataSource.updateBarbershop(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarbershopHoursEntity>>> getBarbershopHours(
    String barbershopId,
  ) async {
    try {
      final models = await remoteDataSource.getBarbershopHours(barbershopId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarbershopHoursEntity>>> updateBarbershopHours(
    List<BarbershopHoursEntity> hours,
  ) async {
    try {
      final models = hours.map((h) => BarbershopHoursModel.fromEntity(h)).toList();
      final updated = await remoteDataSource.updateBarbershopHours(models);
      return Right(updated.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
