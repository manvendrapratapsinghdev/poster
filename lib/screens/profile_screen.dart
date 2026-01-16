import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../screens/profile_actions.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final auth = ref.watch(authProvider);
    final isEmailAuth = true; // Fallback: always show Change Password for now

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (profileAsync is AsyncLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (profileAsync is AsyncError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load profile.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(profileProvider.notifier).fetchProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final profile = profileAsync.profile;
            if (profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(profileProvider.notifier).fetchProfile();
              });
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(profile.avatarUrl!)
                            : const AssetImage('assets/images/avatar.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () async {
                              await pickAndUploadAvatar(context, ref);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    profile.role ?? '-',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    profile.email ?? '-',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      profile.phone!,
                      style: const TextStyle(fontSize: 15, color: Colors.black45),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: Chip(
                    label: Text(profile.name ?? 'Free User'),
                    backgroundColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () async {
                    showEditProfileDialog(context, ref, profile);
                  },
                ),
                if (isEmailAuth) ...[
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () async {
                      showChangePasswordDialog(context, ref);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Edit Preferences'),
                  enabled: false,
                  onTap: () async {
                    showPreferencesDialog(context, ref, profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Manage Business Profiles'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manage Business Profiles not implemented.')),
                    );
                  },
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    ref.invalidate(categoriesProvider);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
