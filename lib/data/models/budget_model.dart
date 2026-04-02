import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'budget_model.g.dart';

@HiveType(typeId: AppConstants.budgetModelTypeId)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final double monthlyLimit;

  BudgetModel({
    required this.monthlyLimit,
  });

  BudgetModel copyWith({
    double? monthlyLimit,
  }) {
    return BudgetModel(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  @override
  String toString() => 'BudgetModel(monthlyLimit: $monthlyLimit)';
}
