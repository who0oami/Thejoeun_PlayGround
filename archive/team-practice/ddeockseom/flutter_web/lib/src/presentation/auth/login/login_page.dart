import 'package:flutter/material.dart';

import '../../../core/utils/input_validators.dart';
import '../../../data/services/auth_api_service.dart';
import '../auth_routes.dart';
import '../widgets/auth_page_shell.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _apiError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    var valid = true;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _apiError = null;
    });

    if (email.isEmpty) {
      _emailError = 'Please enter your email address.';
      valid = false;
    } else if (!InputValidators.isValidEmail(email)) {
      _emailError = 'Please enter a valid email address.';
      valid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Please enter your password.';
      valid = false;
    }

    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final result = await AuthApiService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.pushReplacementNamed(context, AuthRoutes.dashboard);
        return;
      }

      setState(() {
        _apiError = result.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _apiError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      leftTitle: 'Admin Access',
      leftSubtitle: 'This web console is for developers and administrators only.',
      leftCaption: 'Sign in with an administrator account to continue.',
      leftImageAsset: 'images/park_view_photo_4.jpg',
      formCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sign in to manage the admin dashboard.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            errorText: _passwordError,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            ),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
          const SizedBox(height: 20),
          if (_apiError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _apiError!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          PrimaryButton(
            label: 'Login to Dashboard',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
