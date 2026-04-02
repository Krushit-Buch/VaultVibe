import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../domain/entities/monthly_summary.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/app_loading_indicator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final breakdownAsync = ref.watch(monthlyExpenseBreakdownProvider);
    final topCategoriesAsync = ref.watch(topSpendingCategoriesProvider);
    final dailyAverageAsync = ref.watch(dailyAverageSpendingProvider);
    final budgetHealthAsync = ref.watch(budgetHealthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () => _showBudgetDialog(context, ref),
            child: const Text('Set Budget'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(monthlySummaryProvider);
            ref.invalidate(monthlyExpenseBreakdownProvider);
            ref.invalidate(topSpendingCategoriesProvider);
            ref.invalidate(dailyAverageSpendingProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              summaryAsync.when(
                loading: () =>
                    const _CardLoading(message: 'Loading summary...'),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(monthlySummaryProvider),
                ),
                data: (summary) => _MonthlySummaryCard(
                  monthLabel: DateHelper.formatMonthYear(summary.month),
                  summary: summary,
                  dailyAverageAsync: dailyAverageAsync,
                  budgetHealthAsync: budgetHealthAsync,
                  onSetBudget: () => _showBudgetDialog(context, ref),
                ),
              ),
              const SizedBox(height: 20),
              breakdownAsync.when(
                loading: () => const _CardLoading(
                    message: 'Loading category breakdown...'),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(monthlyExpenseBreakdownProvider),
                ),
                data: (breakdown) {
                  if (breakdown.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: AppEmptyState(
                          icon: Icons.pie_chart_outline_rounded,
                          title: 'No spending this month',
                          subtitle: 'Your category breakdown will appear here.',
                        ),
                      ),
                    );
                  }

                  return _CategoryBreakdownCard(breakdown: breakdown);
                },
              ),
              const SizedBox(height: 20),
              topCategoriesAsync.when(
                loading: () =>
                    const _CardLoading(message: 'Loading top categories...'),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(topSpendingCategoriesProvider),
                ),
                data: (topCategories) => _TopCategoriesCard(
                  categories: topCategories,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final actionState = ref.read(budgetActionControllerProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Monthly Budget'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monthly Budget',
                    prefixText: '\$',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid budget amount.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: actionState.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final parsed = double.parse(controller.text.trim());
                          await ref
                              .read(budgetActionControllerProvider.notifier)
                              .setMonthlyBudget(parsed);
                          final result =
                              ref.read(budgetActionControllerProvider);
                          if (result.hasError) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.error.toString()),
                              ),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Monthly budget saved.'),
                            ),
                          );
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.monthLabel,
    required this.summary,
    required this.dailyAverageAsync,
    required this.budgetHealthAsync,
    required this.onSetBudget,
  });

  final String monthLabel;
  final MonthlySummary summary;
  final AsyncValue<double> dailyAverageAsync;
  final AsyncValue<BudgetHealth> budgetHealthAsync;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final budget = summary.monthlyBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Total Expense',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 10),
            Text(
              CurrencyFormatter.format(summary.expense),
              style: AppTextStyles.amountLarge.copyWith(
                color: AppColors.expense,
              ),
            ),
            const SizedBox(height: 16),
            if (budget != null)
              _BudgetOverview(
                summary: summary,
                budgetHealthAsync: budgetHealthAsync,
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'No monthly budget set yet.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: onSetBudget,
                      child: const Text('Set now'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_view_day_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily average',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  dailyAverageAsync.when(
                    data: (value) => Text(
                      CurrencyFormatter.format(value),
                      style: AppTextStyles.labelLarge,
                    ),
                    loading: () => const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text('--'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  const _BudgetOverview({
    required this.summary,
    required this.budgetHealthAsync,
  });

  final MonthlySummary summary;
  final AsyncValue<BudgetHealth> budgetHealthAsync;

  @override
  Widget build(BuildContext context) {
    return budgetHealthAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (health) {
        final color = switch (health) {
          BudgetHealth.safe => AppColors.income,
          BudgetHealth.warning => AppColors.warning,
          BudgetHealth.danger => AppColors.error,
        };
        final progress = summary.budgetUsedPercentage.clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Budget vs Actual',
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                  const Spacer(),
                  Text(
                    '${(summary.budgetUsedPercentage * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Budget',
                      value:
                          CurrencyFormatter.format(summary.monthlyBudget ?? 0),
                    ),
                  ),
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Spent',
                      value: CurrencyFormatter.format(summary.expense),
                    ),
                  ),
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Remaining',
                      value: CurrencyFormatter.format(summary.budgetRemaining),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.breakdown});

  final List<CategorySpending> breakdown;

  @override
  Widget build(BuildContext context) {
    final total = breakdown.fold<double>(0, (sum, item) => sum + item.amount);
    final chartItems = breakdown.take(5).toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 3,
                  sections: chartItems
                      .map(
                        (item) => PieChartSectionData(
                          value: item.amount,
                          color: Color(
                            item.category?.colorValue ??
                                AppColors.primary.toARGB32(),
                          ),
                          showTitle: false,
                          radius: 32,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...breakdown.map(
              (item) {
                final share = total == 0 ? 0 : (item.amount / total) * 100;
                final color = Color(
                  item.category?.colorValue ?? AppColors.primary.toARGB32(),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.category?.name ?? 'Uncategorized',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Text(
                        '${share.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        CurrencyFormatter.format(item.amount),
                        style: AppTextStyles.labelLarge,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({required this.categories});

  final List<CategorySpending> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 3 Spending Categories',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 12),
            ...List.generate(categories.length, (index) {
              final item = categories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.category?.name ?? 'Uncategorized',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.amount),
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: AppLoadingIndicator(message: message),
      ),
    );
  }
}
