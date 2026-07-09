import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/clients_provider.dart';
import '../../domain/entities/client_entity.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormPage({super.key, this.clientId});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  ClientEntity? _existingClient;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFields(List<ClientEntity> clients) {
    if (!_isInitialized && widget.clientId != null) {
      _existingClient = clients.firstWhere((c) => c.id == widget.clientId);
      _nameController.text = _existingClient!.fullName;
      _phoneController.text = _existingClient!.phone ?? '';
      _emailController.text = _existingClient!.email ?? '';
      _notesController.text = _existingClient!.notes ?? '';
      _isInitialized = true;
    }
  }

  void _submit(String barbershopId) {
    if (_formKey.currentState!.validate()) {
      if (widget.clientId == null) {
        final newClient = ClientEntity(
          id: const Uuid().v4(),
          barbershopId: barbershopId,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        ref.read(clientsStateProvider.notifier).addClient(newClient).then((_) {
          if (!mounted) return;
          context.pop();
        });
      } else {
        final updated = _existingClient!.copyWith(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        ref.read(clientsStateProvider.notifier).updateClientDetails(updated).then((_) {
          if (!mounted) return;
          context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final clientsAsync = ref.watch(clientsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('Error: No se encontró contexto de la barbería.'));
          }

          clientsAsync.whenData((list) => _initFields(list));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Información de Contacto', style: AppTextStyles.h3),
                        const SizedBox(height: AppSizes.lg),

                        // Name
                        AppTextField(
                          label: AppStrings.fullName,
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => Validators.required(val, 'El nombre completo'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Phone
                        AppTextField(
                          label: AppStrings.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Email
                        AppTextField(
                          label: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Notes
                        AppTextField(
                          label: 'Notas de Preferencia (Opcional)',
                          controller: _notesController,
                          prefixIcon: Icons.note_alt_outlined,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppButton(
                    text: AppStrings.save,
                    onPressed: () => _submit(barbershop.id),
                    isLoading: clientsAsync.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
