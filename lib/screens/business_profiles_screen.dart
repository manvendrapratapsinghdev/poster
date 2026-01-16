import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_profile.dart';
import '../providers/business_profile_provider.dart';
import 'edit_business_profile_screen.dart';
import 'business_profile_detail_screen.dart';

class BusinessProfilesScreen extends ConsumerWidget {
  const BusinessProfilesScreen({Key? key}) : super(key: key);

  void _showAddProfileForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: BusinessProfileForm(
          onSubmit: (profile) async {
            Navigator.of(context).pop();
            await ref.read(businessProfileProvider.notifier).addProfile(profile);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: const Text('Business Profiles', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Refresh',
            onPressed: () => ref.read(businessProfileProvider.notifier).loadProfiles(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.profiles.isEmpty) {
            return const Center(child: Text('No business profiles found.'));
          }
          return ListView.builder(
            itemCount: state.profiles.length,
            itemBuilder: (context, idx) {
              final profile = state.profiles[idx];
              final profileId = profile.id ?? '';
              final logoUrl = profile.logoUrl != null && profile.logoUrl.isNotEmpty
                  ? profile.logoUrl
                  : 'assets/images/logo/logo-only.png';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BusinessProfileDetailScreen(profile: profile),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            logoUrl.startsWith('http')
                                ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(logoUrl))
                                : CircleAvatar(radius: 28, backgroundImage: AssetImage(logoUrl)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.businessName, style: Theme.of(context).textTheme.titleMedium),
                                  Text(profile.tagline, style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(profile.promotion.headline, style: Theme.of(context).textTheme.bodySmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditBusinessProfileScreen(
                                      profile: profile,
                                      profileId: profileId,
                                    ),
                                  ),
                                );
                                // Refresh after edit
                                ref.read(businessProfileProvider.notifier).loadProfiles();
                              },
                              child: const Text('Update'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Profile'),
                                    content: const Text('Are you sure you want to delete this profile?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await ref.read(businessProfileProvider.notifier).deleteProfile(profileId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Profile deleted successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProfileForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BusinessProfileForm extends StatefulWidget {
  final void Function(BusinessProfile) onSubmit;
  const BusinessProfileForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<BusinessProfileForm> createState() => _BusinessProfileFormState();
}

class _BusinessProfileFormState extends State<BusinessProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _socialsCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();
  final _validityCtrl = TextEditingController();

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _taglineCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _socialsCtrl.dispose();
    _headlineCtrl.dispose();
    _detailsCtrl.dispose();
    _ctaCtrl.dispose();
    _validityCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = BusinessProfile(
        id: '',
        businessName: _businessNameCtrl.text,
        tagline: _taglineCtrl.text,
        contact: Contact(
          phone: _phoneCtrl.text,
          email: _emailCtrl.text,
          website: _websiteCtrl.text,
        ),
        socials: _socialsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        promotion: Promotion(
          headline: _headlineCtrl.text,
          details: _detailsCtrl.text,
          cta: _ctaCtrl.text,
          validity: _validityCtrl.text,
        ),
      );
      widget.onSubmit(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Business Profile', style: Theme.of(context).textTheme.titleLarge),
            TextFormField(
              controller: _businessNameCtrl,
              decoration: const InputDecoration(labelText: 'Business Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _taglineCtrl,
              decoration: const InputDecoration(labelText: 'Tagline'),
            ),
            const SizedBox(height: 8),
            Text('Contact', style: Theme.of(context).textTheme.titleMedium),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _websiteCtrl,
              decoration: const InputDecoration(labelText: 'Website'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _socialsCtrl,
              decoration: const InputDecoration(labelText: 'Socials (comma separated URLs)'),
            ),
            const SizedBox(height: 8),
            Text('Promotion', style: Theme.of(context).textTheme.titleMedium),
            TextFormField(
              controller: _headlineCtrl,
              decoration: const InputDecoration(labelText: 'Headline'),
            ),
            TextFormField(
              controller: _detailsCtrl,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            TextFormField(
              controller: _ctaCtrl,
              decoration: const InputDecoration(labelText: 'CTA'),
            ),
            TextFormField(
              controller: _validityCtrl,
              decoration: const InputDecoration(labelText: 'Validity'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
