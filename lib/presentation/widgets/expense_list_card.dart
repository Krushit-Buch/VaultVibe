import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

class ExpenseListCard extends StatelessWidget {
  const ExpenseListCard({
    super.key,
    required this.expense,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        expense.isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = expense.isExpense ? '-' : '+';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(category?.colorValue ?? amountColor.toARGB32())
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  category?.icon ?? (expense.isExpense ? '💸' : '💰'),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      category?.name ?? 'Uncategorized',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.format(expense.date),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${CurrencyFormatter.format(expense.amount)}',
                    style:
                        AppTextStyles.amountSmall.copyWith(color: amountColor),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
