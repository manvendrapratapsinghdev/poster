import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_profile.dart';
import '../providers/business_profile_provider.dart';

class EditBusinessProfileScreen extends ConsumerStatefulWidget {
  final BusinessProfile profile;
  final String profileId;
  const EditBusinessProfileScreen({Key? key, required this.profile, required this.profileId}) : super(key: key);

  @override
  ConsumerState<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends ConsumerState<EditBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _socialsCtrl;
  late TextEditingController _headlineCtrl;
  late TextEditingController _detailsCtrl;
  late TextEditingController _ctaCtrl;
  late TextEditingController _validityCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _businessNameCtrl = TextEditingController(text: p.businessName);
    _taglineCtrl = TextEditingController(text: p.tagline);
    _phoneCtrl = TextEditingController(text: p.contact.phone);
    _emailCtrl = TextEditingController(text: p.contact.email);
    _websiteCtrl = TextEditingController(text: p.contact.website);
    _socialsCtrl = TextEditingController(text: p.socials.join(", "));
    _headlineCtrl = TextEditingController(text: p.promotion.headline);
    _detailsCtrl = TextEditingController(text: p.promotion.details);
    _ctaCtrl = TextEditingController(text: p.promotion.cta);
    _validityCtrl = TextEditingController(text: p.promotion.validity);
  }

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

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = BusinessProfile(
        id: widget.profile.id,
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
      try {
        await ref.read(businessProfileProvider.notifier).updateProfile(updatedProfile, widget.profileId);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Business Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

