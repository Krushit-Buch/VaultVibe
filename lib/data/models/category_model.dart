import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'category_model.g.dart';

@HiveType(typeId: AppConstants.categoryModelTypeId)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}
