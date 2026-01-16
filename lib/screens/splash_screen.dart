import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'responsive_splash_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSplashScreen();
  }
}
