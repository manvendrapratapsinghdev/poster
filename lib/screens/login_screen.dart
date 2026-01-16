import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:social_post_mobile/config/api_config.dart';
import '../services/google_sign_in_service.dart';
import '../widgets/gradient_background.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';

var logger = Logger();

// Gradient background widget for Poster Shaala theme
// The GradientBackground class is now imported from widgets/gradient_background.dart

// Custom text field for Poster Shaala
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.label,
      this.obscureText = false,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(1)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

// AppButton for primary and secondary actions
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Widget? icon;
  final bool loading;
  const AppButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.isPrimary = true,
      this.icon,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black12,
            foregroundColor: const Color(0xFF662D8C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onPressed: onPressed,
          child: loading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(label),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600)),
      );
    }
  }
}

// Social login button
class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const SocialButton(
      {super.key, required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black12.withOpacity(0.12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          foregroundColor: Colors.black87,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: const Color(0xFF662D8C), size: 22),
        ),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const String _serverClientId =
      '662345242016-bsresceee71rmria6qgs18v1l95eftlr.apps.googleusercontent.com';
  late final GoogleSignInService _googleSignInService =
      GoogleSignInService(serverClientId: _serverClientId);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _loginWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final account = await _googleSignInService.signIn();
      if (account != null) {
        final authCode = account.serverAuthCode;
        if (authCode == null) {
          setState(() {
            _error = 'Failed to get server auth code.';
          });
          return;
        }
        final dio = Dio();
        final response = await dio.post(
          '${ApiConfig.backedBaseUrl}/auth/google',
          data: {'auth_code': authCode},
        );
        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Google sign-in successful and token stored!')),
          );
          final accessToken = response.data['access_token'];
          final refreshToken = response.data['refresh_token'];
          await ref.read(authProvider.notifier).login(accessToken);
          // Optionally store refresh token if needed
          await const FlutterSecureStorage().write(key: 'access_token', value: accessToken);
          await const FlutterSecureStorage().write(key: 'refresh_token', value: refreshToken);
          // Invalidate sensitive providers
          ref.invalidate(categoriesProvider);
          // No manual navigation needed; AuthGate will handle it
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        } else {
          setState(() {
            _error = 'Backend rejected the auth code.';
          });
        }
      } else {
        setState(() {
          _error = 'Google sign-in failed.';
        });
      }
    } catch (e) {
      logger.e('Google sign-in failed', error: e);
      setState(() {
        _error = 'Google sign-in failed. Please try again.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = Dio();
      dio.options.baseUrl = ApiConfig.backedBaseUrl;
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );
      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      await ref.read(authProvider.notifier).login(accessToken);
      await const FlutterSecureStorage().write(key: 'access_token', value: accessToken);
      await const FlutterSecureStorage().write(key: 'refresh_token', value: refreshToken);
      ref.invalidate(categoriesProvider);
      // Manual navigation to HomeScreen after successful login
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      logger.e("User Logged in failed", error: e);
      setState(() {
        _error = 'Login failed. Please try again.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // App logo
                  Image.asset(
                    'assets/images/logo/logo1.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Login',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6
                        ? null
                        : 'Password too short',
                  ),
                  const SizedBox(height: 18),
                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                  ],
                  AppButton(
                    label: 'Login',
                    onPressed: _loading ? null : _login,
                    loading: _loading,
                  ),
                  const SizedBox(height: 16),
                  SocialButton(
                    label: 'Login with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: _loading ? null : _loginWithGoogle,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: "Don't have an account? Sign Up",
                    isPrimary: false,
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
