import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_logo.dart';
import '../providers/logo_provider.dart';

class LogoScreen extends ConsumerWidget {
  final String userId;
  final String promotionId;
  const LogoScreen({Key? key, required this.userId, required this.promotionId}) : super(key: key);

  Future<void> _pickAndUploadLogo(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    try {
      await ref.read(logoProvider({'userId': userId, 'promotionId': promotionId}).notifier).uploadLogo(file);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo uploaded successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateLogo(BuildContext context, WidgetRef ref, String logoId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    try {
      await ref.read(logoProvider({'userId': userId, 'promotionId': promotionId}).notifier).updateLogo(logoId, file);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo updated successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteLogo(BuildContext context, WidgetRef ref, String logoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Logo'),
        content: const Text('Are you sure you want to delete this logo?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(logoProvider({'userId': userId, 'promotionId': promotionId}).notifier).deleteLogo(logoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo deleted successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoState = ref.watch(logoProvider({'userId': userId, 'promotionId': promotionId}));
    return Scaffold(
      appBar: AppBar(title: const Text('Business Logos')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(logoProvider({'userId': userId, 'promotionId': promotionId}).notifier).loadLogos();
        },
        child: logoState.loading
            ? const Center(child: CircularProgressIndicator())
            : logoState.error != null
                ? Center(child: Text('Error: ${logoState.error}'))
                : logoState.logos.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          const CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage('assets/images/logo/logo-only.png'),
                          ),
                          const SizedBox(height: 16),
                          const Text('No logos found', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: logoState.logos.length,
                        itemBuilder: (ctx, idx) {
                          final logo = logoState.logos[idx];
                          return Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                logo.fileUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: logo.fileUrl,
                                        imageBuilder: (ctx, imgProvider) => CircleAvatar(
                                          radius: 48,
                                          backgroundImage: imgProvider,
                                        ),
                                        placeholder: (ctx, _) => const CircularProgressIndicator(),
                                        errorWidget: (ctx, _, __) => const CircleAvatar(
                                          radius: 48,
                                          backgroundImage: AssetImage('assets/images/logo/logo-only.png'),
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 48,
                                        backgroundImage: AssetImage('assets/images/logo/logo-only.png'),
                                      ),
                                const SizedBox(height: 8),
                                Text(logo.fileName, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Update Logo',
                                      onPressed: () => _updateLogo(context, ref, logo.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete Logo',
                                      onPressed: () => _deleteLogo(context, ref, logo.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUploadLogo(context, ref),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Upload Logo'),
      ),
    );
  }
}
