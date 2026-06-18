import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/models.dart' show Category;
import '../../providers/category_provider_firestore.dart';
import '../../widgets/custom_text_field.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditCategorySheet(
        onSave: (category) {
          try {
            context.read<CategoryProvider>().addCategory(category);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category added successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
      ),
    );
  }

  void _showEditCategorySheet(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditCategorySheet(
        category: category,
        onSave: (updatedCategory) {
          try {
            context.read<CategoryProvider>().updateCategory(updatedCategory);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category updated successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategorySheet(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          return categoryProvider.categories.isEmpty
              ? Center(
                  child: Text(
                    'No categories found. Add one to get started!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingSmall,
                      ),
                      child: ListTile(
                        leading: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(category.name),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () =>
                                  _showEditCategorySheet(context, category),
                            ),
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () {
                                categoryProvider.deleteCategory(category.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Category deleted successfully'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class _AddEditCategorySheet extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const _AddEditCategorySheet({
    this.category,
    required this.onSave,
  });

  @override
  State<_AddEditCategorySheet> createState() => _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends State<_AddEditCategorySheet> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: widget.category?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      icon: _iconController.text,
      hexColor: '#6B8E6F',
    );

    widget.onSave(category);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: AppSizes.paddingLarge,
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category == null ? 'Add Category' : 'Edit Category',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Category Name',
                hintText: 'Enter category name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Icon Emoji',
                hintText: 'e.g., 📦 or 🛍️',
                controller: _iconController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Icon is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              SizedBox(
                width: double.infinity,
                height: AppSizes.minimumTouchTarget,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text(
                    widget.category == null ? 'Add Category' : 'Update Category',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }
}
