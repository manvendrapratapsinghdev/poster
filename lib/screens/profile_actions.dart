import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/profile.dart';
import '../providers/profile_provider.dart';

Future<void> pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(profileProvider.notifier).uploadAvatar(picked.path);
      await ref.read(profileProvider.notifier).fetchProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
    } finally {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

void showEditProfileDialog(BuildContext context, WidgetRef ref, Profile profile) {
  final nameCtrl = TextEditingController(text: profile.name);
  final emailCtrl = TextEditingController(text: profile.email);
  final phoneCtrl = TextEditingController(text: profile.phone ?? '');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const Center(child: CircularProgressIndicator()),
            );
            try {
              final result = await ref.read(profileProvider.notifier).updateProfile({
                'name': nameCtrl.text,
                'email': emailCtrl.text,
                'phone': phoneCtrl.text,
              });
              Navigator.of(ctx, rootNavigator: true).pop(); // Remove loading
              Navigator.pop(ctx); // Remove dialog
              if (result != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully.')),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Failed to update profile.')),
                );
              }
            } catch (e) {
              Navigator.of(ctx, rootNavigator: true).pop();
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Failed to update profile: $e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showChangePasswordDialog(BuildContext context, WidgetRef ref) {
  final oldPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPwdCtrl, decoration: const InputDecoration(labelText: 'Old Password'), obscureText: true),
            TextField(controller: newPwdCtrl, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const Center(child: CircularProgressIndicator()),
            );
            try {
              final message = await ref.read(profileProvider.notifier).changePassword(oldPwdCtrl.text, newPwdCtrl.text);
              Navigator.of(ctx, rootNavigator: true).pop();
              Navigator.pop(ctx);
              if (message != null && message == 'Password changed successfully') {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully.')),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Failed to change password.')),
                );
              }
            } catch (e) {
              Navigator.of(ctx, rootNavigator: true).pop();
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Failed to change password: $e')),
              );
            }
          },
          child: const Text('Change'),
        ),
      ],
    ),
  );
}

void showPreferencesDialog(BuildContext context, WidgetRef ref, Profile profile) {
  final prefsCtrl = TextEditingController(text: jsonEncode(profile.preferences));
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Preferences (JSON)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: prefsCtrl, maxLines: 5),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const Center(child: CircularProgressIndicator()),
            );
            try {
              final prefs = prefsCtrl.text.isNotEmpty
                  ? jsonDecode(prefsCtrl.text) as Map<String, dynamic>
                  : <String, dynamic>{};
              final result = await ref.read(profileProvider.notifier).updatePreferences(prefs);
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(ctx);
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences updated successfully.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update preferences.')),
                );
              }
            } catch (e) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid JSON or failed to update: $e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
