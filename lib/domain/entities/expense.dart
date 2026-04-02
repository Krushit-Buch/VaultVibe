import '../../core/enums/transaction_type.dart';
import 'payment_method.dart';
import 'recurring_type.dart';

/// Pure domain entity representing a single financial transaction.
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final bool isRecurring;
  final RecurringType recurringType;
  final DateTime? lastGeneratedDate;
  final int splitCount;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    required this.paymentMethod,
    required this.isRecurring,
    required this.recurringType,
    this.lastGeneratedDate,
    this.splitCount = 0,
    required this.createdAt,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    TransactionType? type,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
    RecurringType? recurringType,
    DateTime? lastGeneratedDate,
    int? splitCount,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      splitCount: splitCount ?? this.splitCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Expense && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amount, type: $type)';
}
