import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/transaction_type.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/recurring_type.dart';
import '../../domain/usecases/add_expense.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/expense_form_fields.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({
    super.key,
    this.expense,
    this.initialType = TransactionType.expense,
  });

  final Expense? expense;
  final TransactionType initialType;

  bool get isEditing => expense != null;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _splitCountController = TextEditingController();

  late TransactionType _type;
  late DateTime _selectedDate;
  late PaymentMethod _paymentMethod;
  late bool _isRecurring;
  late RecurringType _recurringType;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _type = expense?.type ?? widget.initialType;
    _selectedDate = expense?.date ?? DateTime.now();
    _paymentMethod = expense?.paymentMethod ?? PaymentMethod.cash;
    _isRecurring = expense?.isRecurring ?? false;
    _recurringType = expense?.recurringType ?? RecurringType.monthly;
    _selectedCategoryId = expense?.categoryId;
    _titleController.text = expense?.title ?? '';
    _amountController.text = expense?.amount.toStringAsFixed(2) ?? '';
    _splitCountController.text = expense != null && expense.splitCount > 0
        ? '${expense.splitCount}'
        : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _splitCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));
    final actionState = ref.watch(expenseActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit ${widget.expense!.type.label}'
              : 'Add ${_type.label}',
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: actionState.isLoading ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () =>
              const AppLoadingIndicator(message: 'Loading categories...'),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return const AppErrorWidget(
                message:
                    'No categories available. Please create a category first.',
              );
            }

            final effectiveCategories = categories;
            if (effectiveCategories.isNotEmpty &&
                !effectiveCategories.any(
                  (category) => category.id == _selectedCategoryId,
                )) {
              _selectedCategoryId = effectiveCategories.first.id;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                ExpenseFormFields(
                  formKey: _formKey,
                  titleController: _titleController,
                  amountController: _amountController,
                  splitCountController: _splitCountController,
                  categories: effectiveCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  paymentMethod: _paymentMethod,
                  onPaymentMethodChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _paymentMethod = value;
                    });
                  },
                  selectedDate: _selectedDate,
                  onPickDate: _pickDate,
                  isRecurring: _isRecurring,
                  onRecurringChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!_isRecurring) {
                        _recurringType = RecurringType.monthly;
                      }
                    });
                  },
                  recurringType: _recurringType,
                  onRecurringTypeChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _recurringType = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: actionState.isLoading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: actionState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing
                            ? 'Update ${widget.expense!.type.label}'
                            : 'Add ${_type.label}'),
                  ),
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: actionState.isLoading ? null : _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Delete Expense'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final splitCount = int.tryParse(_splitCountController.text.trim()) ?? 0;

    await ref.read(expenseActionControllerProvider.notifier).saveExpense(
          SaveExpenseParams(
            id: widget.expense?.id ?? '',
            title: _titleController.text,
            amount: amount,
            date: _selectedDate,
            categoryId: _selectedCategoryId ?? '',
            type: _type,
            paymentMethod: _paymentMethod,
            isRecurring: _isRecurring,
            recurringType: _isRecurring ? _recurringType : RecurringType.none,
            lastGeneratedDate: widget.expense?.lastGeneratedDate,
            splitCount: splitCount,
          ),
          existingExpense: widget.expense,
        );

    if (!mounted) return;
    final actionState = ref.read(expenseActionControllerProvider);
    if (actionState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionState.error.toString())),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Expense updated successfully.'
              : 'Expense added successfully.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('This expense will be removed permanently.'),
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

    if (confirmed != true || widget.expense == null) return;

    await ref
        .read(expenseActionControllerProvider.notifier)
        .deleteExpense(widget.expense!.id);

    if (!mounted) return;
    final actionState = ref.read(expenseActionControllerProvider);
    if (actionState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionState.error.toString())),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted successfully.')),
    );
    Navigator.of(context).pop(true);
  }
}
