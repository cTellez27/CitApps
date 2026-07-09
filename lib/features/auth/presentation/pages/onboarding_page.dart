import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).createBarbershop(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, current) {
      if (current is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.message),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (current is Authenticated && current.user.barbershopId != null) {
        // Redirigir al dashboard si ya tiene barbería creada
        context.go(RouteNames.dashboard);
      }
    });

    final isLoading = state is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu Barbería'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: AppStrings.logout,
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '¡Bienvenido a CitApps!',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Registra los datos de tu barbería para configurar tu espacio de trabajo.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Barbershop Name
                        AppTextField(
                          label: 'Nombre de la Barbería',
                          controller: _nameController,
                          prefixIcon: Icons.storefront_outlined,
                          validator: (val) => Validators.required(val, 'El nombre de la barbería'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Phone
                        AppTextField(
                          label: 'Teléfono de Contacto',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Address
                        AppTextField(
                          label: 'Dirección',
                          controller: _addressController,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (val) => Validators.required(val, 'La dirección'),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Create button
                        AppButton(
                          text: 'Finalizar Configuración',
                          onPressed: _submit,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
