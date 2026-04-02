import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/time_filter.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../providers/category_provider.dart';
import '../providers/export_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/expense_list_card.dart';
import 'category_management_screen.dart';
import 'expense_form_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final totalIncomeAsync = ref.watch(totalIncomeProvider);
    final totalExpenseAsync = ref.watch(totalExpenseProvider);
    final netBalanceAsync = ref.watch(netBalanceProvider);
    final selectedFilter = ref.watch(selectedTimeFilterProvider);
    final selectedDateRange = ref.watch(selectedDateRangeProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    Category? selectedCategory;
    for (final category in categories) {
      if (category.id == selectedCategoryId) {
        selectedCategory = category;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            onPressed: () => _openCategoryManagement(context),
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
          ),
          IconButton(
            onPressed: () => _exportExpenses(context, ref),
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(expensesProvider);
            ref.invalidate(categoriesProvider);
          },
          child: expensesAsync.when(
            loading: () => const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 480,
                child: AppLoadingIndicator(message: 'Loading expenses...'),
              ),
            ),
            error: (error, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 480,
                child: AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(expensesProvider),
                ),
              ),
            ),
            data: (expenses) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  _SummaryHeader(
                    netBalanceAsync: netBalanceAsync,
                    totalIncomeAsync: totalIncomeAsync,
                    totalExpenseAsync: totalExpenseAsync,
                  ),
                  const SizedBox(height: 20),
                  _FilterChips(
                    selectedFilter: selectedFilter,
                    onFilterSelected: (filter) {
                      ref.read(selectedTimeFilterProvider.notifier).state =
                          filter;
                      ref.read(selectedDateRangeProvider.notifier).state = null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdvancedFiltersBar(
                    selectedDateRange: selectedDateRange,
                    selectedCategory: selectedCategory,
                    onSelectDateRange: () => _pickDateRange(context, ref),
                    onSelectCategory: () => _showCategoryFilterSheet(
                      context,
                      ref,
                      categories,
                    ),
                    onClearFilters: () {
                      ref.read(selectedDateRangeProvider.notifier).state = null;
                      ref.read(selectedCategoryFilterProvider.notifier).state =
                          null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense List',
                        style: AppTextStyles.headingSmall,
                      ),
                      Text(
                        '${expenses.length} items',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Expenses Yet',
                        subtitle:
                            'Tap the add button to create your first expense.',
                      ),
                    )
                  else
                    _ExpenseList(expenses: expenses),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openExpenseForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  Future<void> _openExpenseForm(
    BuildContext context, {
    Expense? expense,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );
  }

  Future<void> _openCategoryManagement(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CategoryManagementScreen(),
      ),
    );
  }

  Future<void> _exportExpenses(BuildContext context, WidgetRef ref) async {
    try {
      final path =
          await ref.read(exportControllerProvider.notifier).exportAllExpenses();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exported to $path')),
      );
    } catch (error) {
      if (!context.mounted) return;
      final message = error is Failure ? error.message : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDateRange: current == null
          ? null
          : DateTimeRange(start: current.start, end: current.end),
    );

    if (picked == null) return;

    ref.read(selectedDateRangeProvider.notifier).state = ExpenseDateRangeFilter(
      start: picked.start,
      end: picked.end,
    );
    ref.read(selectedTimeFilterProvider.notifier).state = TimeFilter.all;
  }

  Future<void> _showCategoryFilterSheet(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All categories'),
                onTap: () {
                  ref.read(selectedCategoryFilterProvider.notifier).state =
                      null;
                  Navigator.of(context).pop();
                },
              ),
              ...categories.map(
                (category) => ListTile(
                  leading: Text(category.icon),
                  title: Text(category.name),
                  onTap: () {
                    ref.read(selectedCategoryFilterProvider.notifier).state =
                        category.id;
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.netBalanceAsync,
    required this.totalIncomeAsync,
    required this.totalExpenseAsync,
  });

  final AsyncValue<double> netBalanceAsync;
  final AsyncValue<double> totalIncomeAsync;
  final AsyncValue<double> totalExpenseAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Balance', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            netBalanceAsync.when(
              data: (value) => Text(
                CurrencyFormatter.format(value),
                style: AppTextStyles.amountMedium,
              ),
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Text('--'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Income',
                    color: AppColors.income,
                    value: totalIncomeAsync,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Expense',
                    color: AppColors.expense,
                    value: totalExpenseAsync,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.color,
    required this.value,
  });

  final String label;
  final Color color;
  final AsyncValue<double> value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          value.when(
            data: (amount) => Text(
              CurrencyFormatter.format(amount),
              style: AppTextStyles.labelLarge.copyWith(color: color),
            ),
            loading: () => const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Text('--'),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final TimeFilter selectedFilter;
  final ValueChanged<TimeFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TimeFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = TimeFilter.values[index];
          return ChoiceChip(
            label: Text(filter.label),
            selected: selectedFilter == filter,
            onSelected: (_) => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}

class _AdvancedFiltersBar extends StatelessWidget {
  const _AdvancedFiltersBar({
    required this.selectedDateRange,
    required this.selectedCategory,
    required this.onSelectDateRange,
    required this.onSelectCategory,
    required this.onClearFilters,
  });

  final ExpenseDateRangeFilter? selectedDateRange;
  final Category? selectedCategory;
  final VoidCallback onSelectDateRange;
  final VoidCallback onSelectCategory;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedDateRange != null || selectedCategory != null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onSelectDateRange,
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(
            selectedDateRange == null
                ? 'Date Range'
                : '${DateHelper.formatShort(selectedDateRange!.start)} - ${DateHelper.formatShort(selectedDateRange!.end)}',
          ),
        ),
        OutlinedButton.icon(
          onPressed: onSelectCategory,
          icon: const Icon(Icons.category_outlined, size: 18),
          label: Text(selectedCategory?.name ?? 'Category'),
        ),
        if (hasFilters)
          TextButton(
            onPressed: onClearFilters,
            child: const Text('Clear Filters'),
          ),
      ],
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryMapAsync = ref.watch(categoryMapProvider);

    return categoryMapAsync.when(
      data: (categoryMap) => Column(
        children: expenses
            .take(AppConstants.maxRecentTransactions)
            .map(
              (expense) => ExpenseListCard(
                expense: expense,
                category: categoryMap[expense.categoryId],
                onTap: () => _openEdit(context, expense),
                onDelete: () => _confirmDelete(context, ref, expense),
              ),
            )
            .toList(),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: AppLoadingIndicator(message: 'Loading categories...'),
      ),
      error: (error, _) => AppErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Expense expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final categoryMap =
        ref.read(categoryMapProvider).valueOrNull ?? <String, Category>{};
    final category = categoryMap[expense.categoryId];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Delete "${expense.title}" from ${category?.name ?? 'this category'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(expenseActionControllerProvider.notifier)
        .deleteExpense(expense.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted successfully.')),
    );
  }
}
