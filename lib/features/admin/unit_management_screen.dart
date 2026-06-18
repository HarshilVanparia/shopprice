import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/unit.dart';
import '../../providers/unit_provider_firestore.dart';
import '../../widgets/custom_text_field.dart';

class UnitManagementScreen extends StatefulWidget {
  const UnitManagementScreen({super.key});

  @override
  State<UnitManagementScreen> createState() => _UnitManagementScreenState();
}

class _UnitManagementScreenState extends State<UnitManagementScreen> {
  void _showAddUnitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditUnitSheet(
        onSave: (unit) {
          try {
            context.read<UnitProvider>().addUnit(unit);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unit added successfully')),
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

  void _showEditUnitSheet(BuildContext context, Unit unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditUnitSheet(
        unit: unit,
        onSave: (updatedUnit) {
          try {
            context.read<UnitProvider>().updateUnit(updatedUnit);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unit updated successfully')),
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
        title: const Text('Unit Management'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUnitSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<UnitProvider>(
        builder: (context, unitProvider, _) {
          return unitProvider.units.isEmpty
              ? Center(
                  child: Text(
                    'No units found. Add one to get started!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: unitProvider.units.length,
                  itemBuilder: (context, index) {
                    final unit = unitProvider.units[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingSmall,
                      ),
                      child: ListTile(
                        title: Text(unit.name),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () => _showEditUnitSheet(context, unit),
                            ),
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () {
                                unitProvider.deleteUnit(unit.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unit deleted successfully'),
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

class _AddEditUnitSheet extends StatefulWidget {
  final Unit? unit;
  final Function(Unit) onSave;

  const _AddEditUnitSheet({
    this.unit,
    required this.onSave,
  });

  @override
  State<_AddEditUnitSheet> createState() => _AddEditUnitSheetState();
}

class _AddEditUnitSheetState extends State<_AddEditUnitSheet> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveUnit() {
    if (!_formKey.currentState!.validate()) return;

    final unit = Unit(
      id: widget.unit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
    );

    widget.onSave(unit);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.unit == null ? 'Add Unit' : 'Edit Unit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Form(
            key: _formKey,
            child: CustomTextField(
              label: 'Unit Name',
              hintText: 'e.g., kg, liter, piece',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unit name is required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          SizedBox(
            width: double.infinity,
            height: AppSizes.minimumTouchTarget,
            child: ElevatedButton(
              onPressed: _saveUnit,
              child: Text(widget.unit == null ? 'Add Unit' : 'Update Unit'),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
        ],
      ),
    );
  }
}
