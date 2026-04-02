import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/recurring_type.dart';

part 'expense_model.g.dart';

@HiveType(typeId: AppConstants.expenseModelTypeId)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final PaymentMethod paymentMethod;

  @HiveField(6)
  final bool isRecurring;

  @HiveField(7)
  final RecurringType recurringType;

  @HiveField(8)
  final DateTime? lastGeneratedDate;

  @HiveField(9)
  final int splitCount;

  @HiveField(10)
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    required this.isRecurring,
    required this.recurringType,
    this.lastGeneratedDate,
    this.splitCount = 0,
    required this.createdAt,
  });

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
    RecurringType? recurringType,
    DateTime? lastGeneratedDate,
    int? splitCount,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      splitCount: splitCount ?? this.splitCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ExpenseModel(id: $id, title: $title, amount: $amount)';
}
