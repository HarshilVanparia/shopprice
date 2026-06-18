import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../providers/user_provider_firestore.dart';
import '../../widgets/custom_text_field.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  void _showAddWorkerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditWorkerSheet(
        onSave: (worker) {
          try {
            context.read<UserProvider>().addUser(worker);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User added successfully')),
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

  void _showEditWorkerSheet(BuildContext context, User worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEditWorkerSheet(
        worker: worker,
        onSave: (updatedWorker) {
          try {
            context.read<UserProvider>().updateUser(updatedWorker);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Worker updated successfully')),
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
        title: const Text('User Management'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkerSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final users = userProvider.users;
          return users.isEmpty
              ? Center(
                  child: Text(
                    'No users found. Add one to get started!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingSmall,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isActive
                              ? AppColors.primary
                              : AppColors.neutral,
                          child: Icon(
                            user.role == UserRole.admin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          '${user.phoneNumber} • ${user.role.name.toUpperCase()}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(
                                user.isActive ? 'Deactivate' : 'Activate',
                              ),
                              onTap: () {
                                userProvider.toggleUserActive(user.id);
                              },
                            ),
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () => _showEditWorkerSheet(context, user),
                            ),
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () {
                                userProvider.deleteUser(user.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User deleted successfully'),
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

class _AddEditWorkerSheet extends StatefulWidget {
  final User? worker;
  final Function(User) onSave;

  const _AddEditWorkerSheet({
    this.worker,
    required this.onSave,
  });

  @override
  State<_AddEditWorkerSheet> createState() => _AddEditWorkerSheetState();
}

class _AddEditWorkerSheetState extends State<_AddEditWorkerSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  UserRole _selectedRole = UserRole.worker;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker?.name ?? '');
    _phoneController = TextEditingController(text: widget.worker?.phoneNumber ?? '');
    _passwordController =
        TextEditingController(text: widget.worker?.password ?? '');
    _selectedRole = widget.worker?.role ?? UserRole.worker;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveWorker() {
    if (!_formKey.currentState!.validate()) return;

    final worker = User(
      id: widget.worker?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
      role: _selectedRole,
      isActive: widget.worker?.isActive ?? true,
    );

    widget.onSave(worker);
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone number validation (10+ digits)
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid phone number (10+ digits)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
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
                widget.worker == null ? 'Add Worker' : 'Edit Worker',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Worker Name',
                hintText: 'Enter worker name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Phone Number',
                hintText: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role == UserRole.admin ? 'Admin' : 'Worker'),
                      ),
                    )
                    .toList(),
                onChanged: (role) {
                  if (role != null) {
                    setState(() => _selectedRole = role);
                  }
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              CustomTextField(
                label: 'Password',
                hintText: 'Enter password',
                controller: _passwordController,
                isPassword: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              SizedBox(
                width: double.infinity,
                height: AppSizes.minimumTouchTarget,
                child: ElevatedButton(
                  onPressed: _saveWorker,
                  child: Text(
                    widget.worker == null ? 'Add Worker' : 'Update Worker',
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
