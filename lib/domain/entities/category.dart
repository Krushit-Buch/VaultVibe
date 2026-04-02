import '../../core/enums/transaction_type.dart';

/// Pure domain entity representing an expense/income category.
class Category {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final TransactionType? transactionType;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.icon = '📁',
    this.colorValue = 0xFF6C63FF,
    this.transactionType,
    this.isDefault = false,
    required this.createdAt,
  });

  bool supports(TransactionType transactionType) {
    return this.transactionType == null ||
        this.transactionType == transactionType;
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    TransactionType? transactionType,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      transactionType: transactionType ?? this.transactionType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
