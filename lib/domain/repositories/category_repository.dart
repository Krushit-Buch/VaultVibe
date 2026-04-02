import '../entities/category.dart';

/// Abstract contract for category data operations (domain layer).
abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);

  /// Seeds default categories on first launch.
  Future<void> seedDefaultCategories();
}
