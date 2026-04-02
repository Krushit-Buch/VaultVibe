/// Repeat cadence for recurring transactions.
enum RecurringType {
  none,
  daily,
  weekly,
  monthly,
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
