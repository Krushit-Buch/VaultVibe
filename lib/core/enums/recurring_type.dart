import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

part 'recurring_type.g.dart';

@HiveType(typeId: AppConstants.recurringTypeTypeId)
enum RecurringType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  yearly;

  String get label {
    switch (this) {
      case RecurringType.none:
        return 'None';
      case RecurringType.daily:
        return 'Daily';
      case RecurringType.weekly:
        return 'Weekly';
      case RecurringType.monthly:
        return 'Monthly';
      case RecurringType.yearly:
        return 'Yearly';
    }
  }
}
