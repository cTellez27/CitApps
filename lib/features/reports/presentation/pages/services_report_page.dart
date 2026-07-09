import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/reports_provider.dart';
import '../../domain/entities/services_report_entity.dart';
import '../../domain/entities/services_report_item_entity.dart';

class ServicesReportPage extends ConsumerWidget {
  const ServicesReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final barbershopAsync = ref.watch(barbershopStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Servicios'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('No se encontró la barbería.'));
          }

          final query = ServicesReportQuery(
            barbershopId: barbershop.id,
            period: period,
          );

          final reportAsync = ref.watch(servicesReportProvider(query));

          return Column(
            children: [
              // ── Period Selector ──
              Container(
                color: AppColors.cardDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ReportPeriod.values.map((p) {
                    final isSelected = p == period;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.accent
                                  : AppColors.background,
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.sm),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: isSelected ? 1 : 0,
                            ),
                            onPressed: () => ref
                                .read(reportPeriodProvider.notifier)
                                .state = p,
                            child: Text(
                              _periodLabel(p),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Report Content ──
              Expanded(
                child: reportAsync.when(
                  data: (report) => _ReportBody(report: report),
                  loading: () => const LoadingWidget(),
                  error: (e, _) => AppErrorWidget(
                    message: e.toString(),
                    onRetry: () =>
                        ref.invalidate(servicesReportProvider(query)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }

  String _periodLabel(ReportPeriod p) => switch (p) {
        ReportPeriod.currentWeek => 'Esta\nSemana',
        ReportPeriod.currentMonth => 'Este\nMes',
        ReportPeriod.lastMonth => 'Mes\nAnterior',
      };
}

// ── Report Body Widget ──

class _ReportBody extends StatelessWidget {
  final ServicesReportEntity report;

  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final (start, end) = (report.periodStart, report.periodEnd);
    final dateRange =
        '${DateFormat('d MMM', 'es').format(start)} — ${DateFormat('d MMM yyyy', 'es').format(end)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Period label ──
          Center(
            child: Text(
              dateRange,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // ── KPI Cards ──
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Citas',
                  value: '${report.totalAppointments}',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _KpiCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Ingresos',
                  value: CurrencyUtils.format(report.totalRevenue),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _KpiCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Ticket Prom.',
                  value: CurrencyUtils.format(report.averageTicket),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),

          if (report.items.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  children: [
                    const Icon(Icons.bar_chart_rounded,
                        size: 64, color: AppColors.borderDark),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'No hay citas completadas\nen este período.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ── Bar Chart ──
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicios Más Realizados', style: AppTextStyles.h4),
                  const SizedBox(height: AppSizes.lg),
                  _ServicesBarChart(items: report.items),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Services Detail Table ──
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalle por Servicio', style: AppTextStyles.h4),
                  const SizedBox(height: AppSizes.md),
                  const Divider(),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Servicio',
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.textSecondaryDark)),
                        ),
                        Expanded(
                          child: Text('Cant.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.textSecondaryDark)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Ingresos',
                              textAlign: TextAlign.end,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.textSecondaryDark)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ...report.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isAlternate = index % 2 == 1;
                    return Container(
                      color: isAlternate
                          ? AppColors.cardDark.withAlpha(80)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.sm, horizontal: AppSizes.xs),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _barColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(item.serviceName,
                                      style: AppTextStyles.bodyMd,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text('${item.count}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelMd),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                CurrencyUtils.format(item.revenue),
                                textAlign: TextAlign.end,
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.success)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  // Totals row
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(
                            '${report.items.fold(0, (s, i) => s + i.count)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyUtils.format(report.totalRevenue),
                            textAlign: TextAlign.end,
                            style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Color _barColor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF26A69A),
      AppColors.warning,
    ];
    return colors[index % colors.length];
  }
}

// ── KPI Card ──

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTextStyles.labelLg.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}

// ── Bar Chart ──

class _ServicesBarChart extends StatelessWidget {
  final List<ServicesReportItemEntity> items;

  const _ServicesBarChart({required this.items});

  @override
  Widget build(BuildContext context) {
    // Show at most 6 services in the chart
    final chartItems = items.take(6).toList();
    final maxCount = chartItems.isEmpty
        ? 1
        : chartItems.map((i) => i.count).reduce((a, b) => a > b ? a : b);

    const colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF26A69A),
    ];

    return Column(
      children: chartItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final fraction = maxCount == 0 ? 0.0 : item.count / maxCount;
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  item.serviceName,
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Foreground bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 22,
                          width: constraints.maxWidth * fraction,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.count}',
                  style:
                      AppTextStyles.labelSm.copyWith(color: color),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
