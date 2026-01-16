import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clears tokens and navigates to the login screen, removing all previous routes.
Future<void> handleUnauthorized() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');
  // Optionally clear all
  // await storage.deleteAll();

  // Navigate to login and remove all previous routes
  // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

