/// Supported ways a transaction can be paid or received.
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  upi,
  wallet,
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
