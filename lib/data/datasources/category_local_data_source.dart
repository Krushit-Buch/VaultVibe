import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failures.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> saveCategory(CategoryModel category);
  Future<void> saveCategories(Iterable<CategoryModel> categories);
  Future<void> deleteCategory(String id);
}

class HiveCategoryLocalDataSource implements CategoryLocalDataSource {
  Box<CategoryModel> get _box =>
      Hive.box<CategoryModel>(AppConstants.categoryBoxName);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final categories = _box.values.toList(growable: false);
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    } catch (e) {
      throw LocalFailure('Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw LocalFailure('Failed to fetch category by id: $e');
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    try {
      await _box.put(category.id, category);
    } catch (e) {
      throw LocalFailure('Failed to save category: $e');
    }
  }

  @override
  Future<void> saveCategories(Iterable<CategoryModel> categories) async {
    try {
      final payload = {
        for (final category in categories) category.id: category
      };
      if (payload.isEmpty) return;
      await _box.putAll(payload);
    } catch (e) {
      throw LocalFailure('Failed to save categories: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw LocalFailure('Failed to delete category: $e');
    }
  }
}
