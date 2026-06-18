import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/models.dart';
import '../../providers/item_provider_firestore.dart';
import '../../providers/category_provider_firestore.dart';
import '../../providers/unit_provider_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/custom_text_field.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditItemSheet(
        onSave: (item) async {
          final itemProvider = context.read<ItemProvider>();
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final success = await itemProvider.addItem(item);
          if (!mounted) return false;
          if (success) {
            navigator.pop();
            messenger.showSnackBar(
              const SnackBar(content: Text('Item added successfully')),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(content: Text(itemProvider.errorMessage ?? 'Failed to add item')),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showEditItemSheet(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditItemSheet(
        item: item,
        onSave: (updatedItem) async {
          final itemProvider = context.read<ItemProvider>();
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final success = await itemProvider.updateItem(updatedItem);
          if (!mounted) return false;
          if (success) {
            navigator.pop();
            messenger.showSnackBar(
              const SnackBar(content: Text('Item updated successfully')),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(content: Text(itemProvider.errorMessage ?? 'Failed to update item')),
            );
          }
          return success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: (() {
                  final searchQuery = _searchController.text.toLowerCase().trim();
                  final filteredItems = searchQuery.isEmpty
                      ? itemProvider.items
                      : itemProvider.items.where((item) {
                          return [
                            item.name,
                            item.brand,
                            item.category,
                            item.unit,
                            item.description,
                          ].any((field) => field.toLowerCase().contains(searchQuery));
                        }).toList();

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No items found. Add one to get started!'
                            : 'No items match your search. Try another term.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingSmall,
                        ),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.brand} • ${item.category} • ₹${item.price}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await itemProvider.deleteItem(item.id);
                              if (!mounted) return;

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Item deleted successfully'),
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      itemProvider.errorMessage ??
                                          'Unable to delete item. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          onTap: () => _showEditItemSheet(context, item),
                        ),
                      );
                    },
                  );
                })(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddEditItemSheet extends StatefulWidget {
  final Item? item;
  final Future<bool> Function(Item) onSave;

  const _AddEditItemSheet({
    this.item,
    required this.onSave,
  });

  @override
  State<_AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<_AddEditItemSheet> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _imageUrl;
  bool _isUploading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _brandController = TextEditingController(text: widget.item?.brand ?? '');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _imageUrl = widget.item?.imageUrl;
    // Always start with null - let dropdowns manage their own state
    _selectedCategory = null;
    _selectedUnit = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryProvider = context.read<CategoryProvider>();
    final unitProvider = context.read<UnitProvider>();

    String? selectedCategoryId = _selectedCategory;
    String? selectedUnitId = _selectedUnit;

    if (selectedCategoryId == null && widget.item != null) {
      final match = categoryProvider.categories.where(
        (category) => category.name.toLowerCase() == widget.item!.category.toLowerCase(),
      );
      selectedCategoryId = match.isNotEmpty ? match.first.id : null;
    }

    if (selectedUnitId == null && widget.item != null) {
      final match = unitProvider.units.where(
        (unit) => unit.name.toLowerCase() == widget.item!.unit.toLowerCase(),
      );
      selectedUnitId = match.isNotEmpty ? match.first.id : null;
    }

    if (selectedCategoryId == null || selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and unit')),
      );
      return;
    }

    final categoryName = categoryProvider.categories
        .firstWhere((c) => c.id == selectedCategoryId)
        .name;
    final unitName = unitProvider.units
        .firstWhere((u) => u.id == selectedUnitId)
        .name;

    final itemId = widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    String? imageUrl = _imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select and upload an image before submitting.')),
      );
      return;
    }

    final item = Item(
      id: itemId,
      name: _nameController.text,
      category: categoryName,
      price: double.parse(_priceController.text),
      unit: unitName,
      brand: _brandController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
    );

    final success = await widget.onSave(item);
    if (!mounted) return;
    if (!success) {
      // Keep the sheet open for retry if saving failed.
    }
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
                widget.item == null ? 'Add Item' : 'Edit Item',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Item Name',
                hintText: 'Enter item name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Brand',
                hintText: 'Enter brand name',
                controller: _brandController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Brand is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Price',
                hintText: 'Enter price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Price must be a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Image Selection
              Text(
                'Item Photo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: _isUploading ? const Text('Uploading...') : const Text('Gallery'),
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _isUploading = true);
                              final url = await CloudinaryService().uploadFromGallery();
                              setState(() => _isUploading = false);
                              if (url != null) {
                                setState(() => _imageUrl = url);
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Image uploaded successfully')),
                                );
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Failed to upload image. Please try again.')),
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: _isUploading ? const Text('Uploading...') : const Text('Camera'),
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _isUploading = true);
                              final url = await CloudinaryService().uploadFromCamera();
                              setState(() => _isUploading = false);
                              if (url != null) {
                                setState(() => _imageUrl = url);
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Image uploaded successfully')),
                                );
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Failed to upload image. Please try again.')),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              // Description Field
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter item description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Category Dropdown
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, _) {
                  if (categoryProvider.categories.isEmpty) {
                    // Show loading state while data is being fetched
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMedium,
                            horizontal: AppSizes.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Loading categories...'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  
                  // Categories loaded - render dropdown
                  String? effectiveCategoryId = _selectedCategory;
                  if (effectiveCategoryId == null && widget.item != null) {
                    final matches = categoryProvider.categories
                        .where((c) =>
                            c.name.toLowerCase() ==
                            widget.item!.category.toLowerCase())
                        .toList();
                    if (matches.isNotEmpty) {
                      effectiveCategoryId = matches.first.id;
                    }
                  }

                  // Ensure value is always valid or null
                  final isValueValid = effectiveCategoryId == null ||
                      categoryProvider.categories
                          .any((c) => c.id == effectiveCategoryId);
                  
                  return DropdownButtonFormField<String>(
                    initialValue: isValueValid ? effectiveCategoryId : null,
                    hint: const Text('Select Category'),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: categoryProvider.categories
                        .map((category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Unit Dropdown
              Consumer<UnitProvider>(
                builder: (context, unitProvider, _) {
                  if (unitProvider.units.isEmpty) {
                    // Show loading state while data is being fetched
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMedium,
                            horizontal: AppSizes.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Loading units...'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  
                  // Units loaded - render dropdown
                  String? effectiveUnitId = _selectedUnit;
                  if (effectiveUnitId == null && widget.item != null) {
                    final matches = unitProvider.units
                        .where((u) =>
                            u.name.toLowerCase() == widget.item!.unit.toLowerCase())
                        .toList();
                    if (matches.isNotEmpty) {
                      effectiveUnitId = matches.first.id;
                    }
                  }

                  // Ensure value is always valid or null
                  final isValueValid = effectiveUnitId == null ||
                      unitProvider.units.any((u) => u.id == effectiveUnitId);
                  
                  return DropdownButtonFormField<String>(
                    initialValue: isValueValid ? effectiveUnitId : null,
                    hint: const Text('Select Unit'),
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: unitProvider.units
                        .map((unit) => DropdownMenuItem(
                              value: unit.id,
                              child: Text(unit.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedUnit = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a unit';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              SizedBox(
                width: double.infinity,
                height: AppSizes.minimumTouchTarget,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveItem,
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.item == null ? 'Add Item' : 'Update Item'),
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
