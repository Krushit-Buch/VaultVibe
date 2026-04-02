import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

part 'payment_method.g.dart';

@HiveType(typeId: AppConstants.paymentMethodTypeId)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  card,
  @HiveField(2)
  bankTransfer,
  @HiveField(3)
  upi,
  @HiveField(4)
  wallet,
  @HiveField(5)
  other;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}
