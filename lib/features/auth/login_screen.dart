import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider_firebase.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone_number');
    final savedPassword = prefs.getString('saved_password');

    if (savedPhone != null) _phoneController.text = savedPhone;
    if (savedPassword != null) _passwordController.text = savedPassword;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9]{10,}$')
        .hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid phone number (10+ digits)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return AppStrings.invalidPassword;
    return null;
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider
        .login(_phoneController.text, _passwordController.text)
        .then((success) {
      if (!mounted) return;
      if (success) {
        final targetRoute = authProvider.isAdmin ? '/admin' : '/home';
        Navigator.pushNamedAndRemoveUntil(context, targetRoute, (r) => false);
        return;
      }

      final errorMessage = authProvider.errorMessage ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / Header
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('🛒', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Text('ShopPrice', style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text('Find the best prices', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),

                const SizedBox(height: 12), // reduced gap

                // Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhoneNumber,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        CustomTextField(
                          label: AppStrings.password,
                          hintText: AppStrings.passwordHint,
                          controller: _passwordController,
                          isPassword: _obscurePassword,
                          validator: _validatePassword,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),

                        Consumer<AuthProvider>(builder: (context, authProvider, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: AppSizes.minimumTouchTarget,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              child: authProvider.isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                  : Text(AppStrings.login.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
                            ),
                          );
                        }),

                        const SizedBox(height: AppSizes.paddingMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
