import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_profile.dart';
import '../providers/logo_provider.dart';

class BusinessProfileDetailScreen extends ConsumerWidget {
  final BusinessProfile profile;
  const BusinessProfileDetailScreen({Key? key, required this.profile}) : super(key: key);

  Future<void> _showLogoPopup(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 320,
            child: Consumer(
              builder: (ctx, ref, _) {
                final logoState = ref.watch(logoProvider({
                  'userId': profile.userId,
                  'promotionId': profile.id,
                }));
                final logoNotifier = ref.read(logoProvider({
                  'userId': profile.userId,
                  'promotionId': profile.id,
                }).notifier);
                final logo = logoState.logos.isNotEmpty ? logoState.logos.last : null;
                final logoUrl = (logo != null && logo.fileUrl.isNotEmpty)
                    ? logo.fileUrl
                    : 'assets/images/logo/logo-only.png';
                final cacheBustedUrl = logoUrl.startsWith('http')
                    ? '${logoUrl}?v=${DateTime.now().millisecondsSinceEpoch}'
                    : logoUrl;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Logo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      logoState.loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Center(
                              child: logoUrl.startsWith('http')
                                  ? CircleAvatar(radius: 48, backgroundImage: CachedNetworkImageProvider(cacheBustedUrl))
                                  : CircleAvatar(radius: 48, backgroundImage: AssetImage(logoUrl)),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.upload),
                              label: const Text('Upload Logo'),
                              onPressed: logoState.loading
                                  ? null
                                  : () async {
                                      final picker = ImagePicker();
                                      final picked = await picker.pickImage(source: ImageSource.gallery);
                                      if (picked == null) return;
                                      final file = File(picked.path);
                                      final oldUrl = logo?.fileUrl;
                                      try {
                                        await logoNotifier.uploadLogo(file);
                                        if (oldUrl != null && oldUrl.isNotEmpty) {
                                          await CachedNetworkImage.evictFromCache(oldUrl);
                                        }
                                        await logoNotifier.loadLogos();
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo uploaded successfully')));
                                        }
                                      } catch (e) {
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                        }
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete Logo'),
                              onPressed: logoState.loading || logo == null
                                  ? null
                                  : () async {
                                      final oldUrl = logo.fileUrl;
                                      final confirm = await showDialog<bool>(
                                        context: ctx,
                                        builder: (dctx) => AlertDialog(
                                          title: const Text('Delete Logo'),
                                          content: const Text('Are you sure you want to delete this logo?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Delete')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await logoNotifier.deleteLogo(logo.id);
                                          if (oldUrl.isNotEmpty) {
                                            await CachedNetworkImage.evictFromCache(oldUrl);
                                          }
                                          await logoNotifier.loadLogos();
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo deleted successfully')));
                                          }
                                        } catch (e) {
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = profile.logoUrl != null && profile.logoUrl!.isNotEmpty
        ? profile.logoUrl!
        : 'assets/images/logo/logo-only.png';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: const Text('Business Profile Details', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _showLogoPopup(context, ref),
                child: logoUrl.startsWith('http')
                    ? CircleAvatar(radius: 48, backgroundImage: NetworkImage(logoUrl))
                    : CircleAvatar(radius: 48, backgroundImage: AssetImage(logoUrl)),
              ),
            ),
            const SizedBox(height: 16),
            Text(profile.businessName, style: Theme.of(context).textTheme.headlineSmall),
            Text(profile.tagline, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 32),
            Text('Contact', style: Theme.of(context).textTheme.titleMedium),
            Text('Phone: ${profile.contact.phone}'),
            Text('Email: ${profile.contact.email}'),
            Text('Website: ${profile.contact.website}'),
            const Divider(height: 32),
            Text('Socials', style: Theme.of(context).textTheme.titleMedium),
            ...profile.socials.map((url) => Text(url)).toList(),
            const Divider(height: 32),
            Text('Promotion', style: Theme.of(context).textTheme.titleMedium),
            Text('Headline: ${profile.promotion.headline}'),
            Text('Details: ${profile.promotion.details}'),
            Text('Validity: ${profile.promotion.validity}'),
          ],
        ),
      ),
    );
  }
}
