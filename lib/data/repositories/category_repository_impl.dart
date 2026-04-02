import '../../core/constants/app_colors.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/enums/category_type.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/utils/failures.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

/// Concrete implementation of [CategoryRepository].
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<Category>> getAllCategories() async {
    final models = await _localDataSource.getAllCategories();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final model = await _localDataSource.getCategoryById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<void> addCategory(Category category) async {
    final model = _entityToModel(category);
    await _localDataSource.saveCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final existing = await _localDataSource.getCategoryById(category.id);
    if (existing == null) throw const NotFoundFailure('Category not found.');
    await _localDataSource.saveCategory(_entityToModel(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
  }

  @override
  Future<void> seedDefaultCategories() async {
    // Intentionally no-op. Categories are user-managed only.
  }

  // ── Mappers ───────────────────────────────────────────────

  Category _modelToEntity(CategoryModel m) {
    final preset = _presetForName(m.name);
    return Category(
      id: m.id,
      name: m.name,
      icon: preset.icon,
      colorValue: preset.colorValue,
      transactionType: preset.transactionType,
      isDefault: preset.isDefault,
      createdAt: m.createdAt,
    );
  }

  CategoryModel _entityToModel(Category c) {
    return CategoryModel(
      id: c.id,
      name: c.name,
      createdAt: c.createdAt,
    );
  }

  _CategoryPreset _presetForName(String name) {
    final categoryType = CategoryType.fromLabel(name);
    if (categoryType == null) {
      return const _CategoryPreset(
        icon: '📁',
        colorValue: 0xFF6C63FF,
        transactionType: null,
        isDefault: false,
      );
    }

    return _CategoryPreset(
      icon: categoryType.icon,
      colorValue: AppColors.categoryColors[categoryType.colorIndex].toARGB32(),
      transactionType:
          categoryType.supportsBoth ? null : categoryType.transactionType,
      isDefault: true,
    );
  }
}

class _CategoryPreset {
  final String icon;
  final int colorValue;
  final TransactionType? transactionType;
  final bool isDefault;

  const _CategoryPreset({
    required this.icon,
    required this.colorValue,
    required this.transactionType,
    required this.isDefault,
  });
}
