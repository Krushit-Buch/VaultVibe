import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_helper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/recurring_type.dart';

class ExpenseFormFields extends StatelessWidget {
  const ExpenseFormFields({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.amountController,
    required this.splitCountController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.selectedDate,
    required this.onPickDate,
    required this.isRecurring,
    required this.onRecurringChanged,
    required this.recurringType,
    required this.onRecurringTypeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController splitCountController;
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final PaymentMethod paymentMethod;
  final ValueChanged<PaymentMethod?> onPaymentMethodChanged;
  final DateTime selectedDate;
  final Future<void> Function() onPickDate;
  final bool isRecurring;
  final ValueChanged<bool> onRecurringChanged;
  final RecurringType recurringType;
  final ValueChanged<RecurringType?> onRecurringTypeChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveCategoryId =
        categories.any((category) => category.id == selectedCategoryId)
            ? selectedCategoryId
            : (categories.isNotEmpty ? categories.first.id : null);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Groceries, Rent, Uber...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: AppConstants.defaultCurrencySymbol,
            ),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Amount must be greater than 0.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: effectiveCategoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text('${category.icon} ${category.name}'),
                  ),
                )
                .toList(),
            onChanged: onCategoryChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Category is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: paymentMethod,
            decoration: const InputDecoration(labelText: 'Payment Method'),
            items: PaymentMethod.values
                .map(
                  (method) => DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(method.label),
                  ),
                )
                .toList(),
            onChanged: onPaymentMethodChanged,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                DateHelper.format(selectedDate),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: isRecurring,
            onChanged: onRecurringChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text('Recurring Expense'),
          ),
          if (isRecurring) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<RecurringType>(
              initialValue: recurringType,
              decoration: const InputDecoration(labelText: 'Recurring Type'),
              items: RecurringType.values
                  .where((type) => type != RecurringType.none)
                  .map(
                    (type) => DropdownMenuItem<RecurringType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
              onChanged: onRecurringTypeChanged,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: splitCountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Split Count',
              hintText: 'Optional',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final parsed = int.tryParse(value);
              if (parsed == null || parsed < 0) {
                return 'Split count must be 0 or more.';
              }
              if (parsed == 1) {
                return 'Split count must be empty, 0, or at least 2.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
