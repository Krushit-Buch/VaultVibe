import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../providers/dependency_providers.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/app_loading_indicator.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Loading categories...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No Categories Yet',
              subtitle: 'Create a category to start organizing expenses.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                child: ListTile(
                  leading:
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(category.name, style: AppTextStyles.bodyLarge),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _showCategoryDialog(
                          context,
                          ref,
                          existingCategory: category,
                        );
                      } else if (value == 'delete') {
                        await _handleDelete(context, ref, category, categories);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? existingCategory,
  }) async {
    final controller =
        TextEditingController(text: existingCategory?.name ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            existingCategory == null ? 'Create Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Category name is required.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref
                  .read(categoryActionControllerProvider.notifier)
                  .saveCategory(
                    name: controller.text,
                    existingCategory: existingCategory,
                  );
              final result = ref.read(categoryActionControllerProvider);
              if (result.hasError) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.error.toString())),
                );
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    existingCategory == null
                        ? 'Category created.'
                        : 'Category updated.',
                  ),
                ),
              );
            },
            child: Text(existingCategory == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
    List<Category> allCategories,
  ) async {
    final expenses = await ref.read(getAllExpensesUseCaseProvider).call();
    if (!context.mounted) return;
    final isUsed = expenses.any((expense) => expense.categoryId == category.id);

    if (!isUsed) {
      await _deleteCategory(context, ref, category);
      return;
    }

    final alternatives = allCategories
        .where((item) => item.id != category.id)
        .toList(growable: false);
    if (alternatives.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This category is in use and cannot be deleted without another category for reassignment.',
          ),
        ),
      );
      return;
    }

    String selectedCategoryId = alternatives.first.id;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This category is used by existing expenses. Reassign them before deleting "${category.name}".',
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Reassign to',
                  ),
                  items: alternatives
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(categoryActionControllerProvider.notifier)
                  .deleteCategory(
                    category: category,
                    reassignmentCategoryId: selectedCategoryId,
                  );
              final result = ref.read(categoryActionControllerProvider);
              if (result.hasError) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.error.toString())),
                );
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Category deleted and expenses reassigned.')),
              );
            },
            child: const Text('Reassign & Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(categoryActionControllerProvider.notifier)
        .deleteCategory(category: category);
    if (!context.mounted) return;
    final result = ref.read(categoryActionControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error.toString())),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category deleted.')),
    );
  }
}
