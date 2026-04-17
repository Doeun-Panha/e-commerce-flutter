import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../logic/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine loading state from provider
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(isLoading),
                  const SizedBox(height: 16),
                  _buildToggleModeButton(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.shopping_cart_checkout_rounded, size: 80, color: Colors.blue),
        const SizedBox(height: 20),
        Text(
          _isLogin ? "Welcome Back" : "Create Account",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? "Sign in to manage your inventory" : "Join our admin team today",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _usernameController,
          label: "Username",
          icon: Icons.person_outline,
          validator: AppValidators.required(message: "Username is required"),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
          validator: AppValidators.required(message: "Password is required"),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(_isLogin ? "LOGIN" : "REGISTER",
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildToggleModeButton(bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => setState(() => _isLogin = !_isLogin),
      child: Text(
        _isLogin ? "Don't have an account? Register" : "Already have an account? Login",
        style: const TextStyle(color: Colors.blueGrey),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = _isLogin
        ? await authProvider.login(_usernameController.text.trim(), _passwordController.text)
        : await authProvider.register(_usernameController.text.trim(), _passwordController.text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Invalid credentials' : 'Registration failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}