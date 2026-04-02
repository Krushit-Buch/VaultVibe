import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Retrieves all categories.
class GetAllCategoriesUseCase {
  final CategoryRepository _repository;
  const GetAllCategoriesUseCase(this._repository);

  Future<List<Category>> call() async {
    return _repository.getAllCategories();
  }
}
