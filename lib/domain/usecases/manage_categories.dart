import '../../core/utils/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Encapsulates category business rules and CRUD operations.
class ManageCategoriesUseCase {
  final CategoryRepository _repository;

  const ManageCategoriesUseCase(this._repository);

  Future<List<Category>> getAll() async {
    return _repository.getAllCategories();
  }

  Future<void> add(Category category) async {
    _validate(category);
    await _repository.addCategory(category);
  }

  Future<void> update(Category category) async {
    _validate(category);
    await _repository.updateCategory(category);
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationFailure('Category id cannot be empty.');
    }
    await _repository.deleteCategory(id);
  }

  void _validate(Category category) {
    if (category.name.trim().isEmpty) {
      throw const ValidationFailure('Category name cannot be empty.');
    }
  }
}
