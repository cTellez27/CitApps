import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/barbershop_entity.dart';
import '../../domain/entities/barbershop_hours_entity.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  // Profile Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();

  // Local Hours state to allow changes before saving
  List<BarbershopHoursEntity> _localHours = [];
  bool _isHoursInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _initProfileControllers(BarbershopEntity barbershop) {
    if (_nameController.text.isEmpty) {
      _nameController.text = barbershop.name;
      _phoneController.text = barbershop.phone ?? '';
      _addressController.text = barbershop.address ?? '';
      _websiteController.text = barbershop.website ?? '';
      _instagramController.text = barbershop.instagram ?? '';
    }
  }

  void _saveProfile(BarbershopEntity current) {
    if (_profileFormKey.currentState!.validate()) {
      final updated = current.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
      );

      ref.read(barbershopStateProvider.notifier).updateBarbershop(updated).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil de la barbería actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      });
    }
  }

  void _saveHours() {
    // Validar que en los días abiertos el cierre sea posterior a la apertura
    for (final hour in _localHours) {
      if (hour.isOpen) {
        final open = _parseTime(hour.openTime);
        final close = _parseTime(hour.closeTime);
        if (open.isAfter(close) || open.isAtSameMomentAs(close)) {
          final dayName = AppDateUtils.dayNameFull(hour.dayOfWeek == 0 ? 7 : hour.dayOfWeek);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en $dayName: El cierre debe ser posterior a la apertura.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
    }

    ref.read(barbershopHoursStateProvider.notifier).updateHours(_localHours).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horarios de operación actualizados'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hours, minutes);
  }

  Future<void> _selectTime(int index, bool isOpenTime) async {
    final hour = _localHours[index];
    final initialTimeStr = isOpenTime ? hour.openTime : hour.closeTime;
    final parts = initialTimeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isOpenTime ? 'Hora de Apertura' : 'Hora de Cierre',
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      setState(() {
        _localHours[index] = isOpenTime
            ? hour.copyWith(openTime: formattedTime)
            : hour.copyWith(closeTime: formattedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final hoursAsync = ref.watch(barbershopHoursStateProvider);

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryDark,
          tabs: const [
            Tab(icon: Icon(Icons.storefront_rounded), text: 'Perfil'),
            Tab(icon: Icon(Icons.access_time_rounded), text: 'Horarios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── PESTAÑA PERFIL ──
          barbershopAsync.when(
            data: (barbershop) {
              if (barbershop == null) {
                return const Center(child: Text('No hay datos de la barbería.'));
              }
              _initProfileControllers(barbershop);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Form(
                  key: _profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Datos Generales', style: AppTextStyles.h3),
                            const SizedBox(height: AppSizes.lg),

                            // Name
                            AppTextField(
                              label: 'Nombre de la Barbería',
                              controller: _nameController,
                              prefixIcon: Icons.storefront_outlined,
                              readOnly: !isOwnerOrAdmin,
                              validator: (val) =>
                                  Validators.required(val, 'El nombre de la barbería'),
                            ),
                            const SizedBox(height: AppSizes.md),

                            // Phone
                            AppTextField(
                              label: 'Teléfono',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              readOnly: !isOwnerOrAdmin,
                              validator: Validators.phone,
                            ),
                            const SizedBox(height: AppSizes.md),

                            // Address
                            AppTextField(
                              label: 'Dirección',
                              controller: _addressController,
                              prefixIcon: Icons.location_on_outlined,
                              readOnly: !isOwnerOrAdmin,
                              validator: (val) => Validators.required(val, 'La dirección'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Redes Sociales & Sitio Web', style: AppTextStyles.h4),
                            const SizedBox(height: AppSizes.lg),

                            // Website
                            AppTextField(
                              label: 'Sitio Web',
                              controller: _websiteController,
                              prefixIcon: Icons.language_rounded,
                              readOnly: !isOwnerOrAdmin,
                            ),
                            const SizedBox(height: AppSizes.md),

                            // Instagram
                            AppTextField(
                              label: 'Instagram',
                              controller: _instagramController,
                              prefixIcon: Icons.camera_alt_outlined,
                              readOnly: !isOwnerOrAdmin,
                            ),
                          ],
                        ),
                      ),
                      if (isOwnerOrAdmin) ...[
                        const SizedBox(height: AppSizes.xl),
                        AppButton(
                          text: AppStrings.save,
                          onPressed: () => _saveProfile(barbershop),
                          isLoading: barbershopAsync.isLoading,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            loading: () => const LoadingWidget(),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(barbershopStateProvider),
            ),
          ),

          // ── PESTAÑA HORARIOS ──
          hoursAsync.when(
            data: (hours) {
              if (hours.isEmpty) {
                return const Center(child: Text('No hay horarios cargados.'));
              }
              if (!_isHoursInitialized) {
                _localHours = List.from(hours);
                _isHoursInitialized = true;
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      itemCount: _localHours.length,
                      itemBuilder: (context, index) {
                        final hour = _localHours[index];
                        final dayName = AppDateUtils.dayNameFull(
                          hour.dayOfWeek == 0 ? 7 : hour.dayOfWeek,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.sm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    dayName,
                                    style: AppTextStyles.labelLg,
                                  ),
                                ),
                                Switch(
                                  value: hour.isOpen,
                                  activeThumbColor: AppColors.primary,
                                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                                  onChanged: !isOwnerOrAdmin
                                      ? null
                                      : (val) {
                                          setState(() {
                                            _localHours[index] = hour.copyWith(isOpen: val);
                                          });
                                        },
                                ),
                                const SizedBox(width: AppSizes.md),
                                if (hour.isOpen) ...[
                                  TextButton(
                                    onPressed: !isOwnerOrAdmin
                                        ? null
                                        : () => _selectTime(index, true),
                                    child: Text(
                                      AppDateUtils.formatTimeString(hour.openTime),
                                      style: TextStyle(
                                        color: isOwnerOrAdmin ? AppColors.primary : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text('a'),
                                  TextButton(
                                    onPressed: !isOwnerOrAdmin
                                        ? null
                                        : () => _selectTime(index, false),
                                    child: Text(
                                      AppDateUtils.formatTimeString(hour.closeTime),
                                      style: TextStyle(
                                        color: isOwnerOrAdmin ? AppColors.primary : Colors.white,
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Cerrado',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isOwnerOrAdmin)
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: AppButton(
                        text: 'Guardar Horarios',
                        onPressed: _saveHours,
                        isLoading: hoursAsync.isLoading,
                      ),
                    ),
                ],
              );
            },
            loading: () => const LoadingWidget(),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () {
                _isHoursInitialized = false;
                ref.invalidate(barbershopHoursStateProvider);
              },
            ),
          ),
        ],
      ),
    );
  }
}
