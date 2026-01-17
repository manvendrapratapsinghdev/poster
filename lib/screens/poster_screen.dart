import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../widgets/gradient_background.dart';
import '../models/template_strip_model.dart';
import '../providers/template_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

// Providers for selected background and strip
final selectedBackgroundProvider = StateProvider<String?>((ref) => null);
final selectedStripProvider = StateProvider<TemplateStripModel?>((ref) => null);

class PosterScreen extends ConsumerStatefulWidget {
  final String templateId;
  final String initialBackgroundUrl;
  final List<String> backgrounds;
  final String? userLogoUrl;
  final String? userName;
  final String? userContact;
  final String? userAddress;
  final String? userOtherInfo;

  const PosterScreen({
    super.key,
    required this.templateId,
    required this.initialBackgroundUrl,
    required this.backgrounds,
    this.userLogoUrl,
    this.userName,
    this.userContact,
    this.userAddress,
    this.userOtherInfo,
  });

  @override
  ConsumerState<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends ConsumerState<PosterScreen> {
  final GlobalKey _posterKey = GlobalKey();

  Alignment parseAlignment(String? alignmentStr) {
    switch (alignmentStr) {
      case 'topCenter':
        return Alignment.topCenter;
      case 'center':
        return Alignment.center;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      default:
        return Alignment.bottomCenter;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialBg = (widget.initialBackgroundUrl.isNotEmpty)
          ? widget.initialBackgroundUrl
          : (widget.backgrounds.isNotEmpty ? widget.backgrounds.first : null);
      ref.read(selectedBackgroundProvider.notifier).state = initialBg;
    });
  }

  Widget _buildLogo(String? logoUrl, double size) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        radius: size / 2,
        child: const Icon(Icons.person, color: Colors.black),
      );
    }
    if (logoUrl.startsWith('http')) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(logoUrl),
      );
    }
    if (File(logoUrl).existsSync()) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(logoUrl)),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      radius: size / 2,
      child: const Icon(Icons.person, color: Colors.black),
    );
  }

  Future<File?> _capturePoster() async {
    try {
      if (_posterKey.currentContext == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poster not ready to capture. Please try again.')),
        );
        return null;
      }
      RenderRepaintBoundary boundary = _posterKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing poster: $e')),
      );
      return null;
    }
  }

  void _onEditPoster() {
    // TODO: Implement edit poster functionality
  }

  void _onAudio() {
    // TODO: Implement audio functionality
  }

  Future<void> _onWhatsApp() async {

  }

  Future<void> _onShare() async {
    final file = await _capturePoster();
    if (file != null) {
      try {
        await Share.shareXFiles([
          XFile(file.path)
        ], text: 'Check out my new poster!');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing poster: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBackground = ref.watch(selectedBackgroundProvider);
    final backgrounds = widget.backgrounds;
    final backgroundUrl = (selectedBackground != null && selectedBackground.isNotEmpty)
        ? selectedBackground
        : (backgrounds.isNotEmpty ? backgrounds.first : null);
    final selectedStrip = ref.watch(selectedStripProvider);
    final stripsAsync = ref.watch(templateStripsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text('Poster Editor', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Section: Background selector
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: backgrounds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final bgUrl = backgrounds[idx];
                    final isSelected = selectedBackground == bgUrl;
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedBackgroundProvider.notifier).state = bgUrl;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            bgUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Middle Section: Poster Preview
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: RepaintBoundary(
                      key: _posterKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double width = constraints.maxWidth;
                          final double height = constraints.maxHeight;
                          double relX(double x) => (x / 400.0) * width;
                          double relY(double y) => (y / 400.0) * height;
                          // Poster preview stack
                          return Stack(
                            children: [
                              // Background
                              Positioned.fill(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: (backgroundUrl != null && backgroundUrl.isNotEmpty)
                                      ? Stack(
                                          children: [
                                            Image.network(
                                              backgroundUrl,
                                              key: ValueKey(backgroundUrl),
                                              fit: BoxFit.cover,
                                              width: width,
                                              height: height,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.broken_image, size: 48),
                                              ),
                                            ),
                                            if (selectedStrip == null)
                                              Container(
                                                color: Colors.black.withAlpha(50),
                                                width: width,
                                                height: height,
                                              ),
                                          ],
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Center(child: Icon(Icons.broken_image, size: 48)),
                                        ),
                                ),
                              ),
                              // Template Strip
                              if (selectedStrip != null)
                                Builder(builder: (context) {
                                  // --- STRIP GEOMETRY ---
                                  final double stripWidth = width;
                                  final double aspectRatio = 4 / 1;
                                  final double stripHeight = stripWidth / aspectRatio;
                                  final double maxHeight = height * (selectedStrip.metadata.heightFactor.clamp(0.0, 1.0));
                                  final double finalHeight = stripHeight > maxHeight ? maxHeight : stripHeight;
                                  final double stripLeft = 0;
                                  final double stripTop = height - finalHeight;
                                  
                                  // --- Overlay element sizes ---
                                  const double textHeight = 28;
                                  const double textWidth = 220;
                                  const double logoSize = 48;
                                  
                                  // --- STRIP-LOCAL COORDINATE HELPERS (metadata is 0-400 normalized) ---
                                  // Convert metadata coordinates (0-400) to strip-local pixels (0-stripWidth/finalHeight)
                                  double toStripLocalX(double metadataX) => (metadataX / 400.0) * stripWidth;
                                  double toStripLocalY(double metadataY) => (metadataY / 400.0) * finalHeight;
                                  
                                  // Clamp within strip bounds
                                  double clampLocalX(double localX, double elementWidth) => 
                                    localX.clamp(0, stripWidth - elementWidth);
                                  double clampLocalY(double localY, double elementHeight) => 
                                    localY.clamp(0, finalHeight - elementHeight);
                                  
                                  return Positioned(
                                    left: stripLeft,
                                    top: stripTop,
                                    width: stripWidth,
                                    height: finalHeight,
                                    child: Stack(
                                      children: [
                                        // Strip Image (fills entire positioned container)
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: selectedStrip.metadata.opacity,
                                            child: (selectedStrip.fileUrl.isNotEmpty)
                                                ? Image.network(
                                                    selectedStrip.fileUrl,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: Colors.grey[400],
                                                      child: const Icon(Icons.broken_image, size: 32),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(child: Icon(Icons.image_not_supported)),
                                                  ),
                                          ),
                                        ),
                                        // Name - positioned relative to strip container (0,0)
                                        Positioned(
                                          left: clampLocalX(toStripLocalX(selectedStrip.metadata.namePosition.x), textWidth),
                                          top: clampLocalY(toStripLocalY(selectedStrip.metadata.namePosition.y), textHeight),
                                          width: textWidth,
                                          height: textHeight,
                                          child: Text(
                                            widget.userName ?? 'Name',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: selectedStrip.metadata.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: selectedStrip.metadata.fontSize,
                                              shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                        ),
                                        // Contact
                                        Positioned(
                                          left: clampLocalX(toStripLocalX(selectedStrip.metadata.contactPosition.x), textWidth),
                                          top: clampLocalY(toStripLocalY(selectedStrip.metadata.contactPosition.y), textHeight),
                                          width: textWidth,
                                          height: textHeight,
                                          child: Text(
                                            widget.userContact ?? 'Contact',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: selectedStrip.metadata.color,
                                              fontSize: selectedStrip.metadata.fontSize * 0.8,
                                              shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                        ),
                                        // Address
                                        Positioned(
                                          left: clampLocalX(toStripLocalX(selectedStrip.metadata.addressPosition.x), textWidth),
                                          top: clampLocalY(toStripLocalY(selectedStrip.metadata.addressPosition.y), textHeight),
                                          width: textWidth,
                                          height: textHeight,
                                          child: Text(
                                            widget.userAddress ?? 'Address',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: selectedStrip.metadata.color,
                                              fontSize: selectedStrip.metadata.fontSize * 0.8,
                                              shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                        ),
                                        // Other Info
                                        Positioned(
                                          left: clampLocalX(toStripLocalX(selectedStrip.metadata.otherInfoPosition.x), textWidth),
                                          top: clampLocalY(toStripLocalY(selectedStrip.metadata.otherInfoPosition.y), textHeight),
                                          width: textWidth,
                                          height: textHeight,
                                          child: Text(
                                            widget.userOtherInfo ?? 'Other Info',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: selectedStrip.metadata.color,
                                              fontSize: selectedStrip.metadata.fontSize * 0.8,
                                              shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                        ),
                                        // Logo
                                        Positioned(
                                          left: clampLocalX(toStripLocalX(selectedStrip.metadata.logoPosition.x), logoSize),
                                          top: clampLocalY(toStripLocalY(selectedStrip.metadata.logoPosition.y), logoSize),
                                          width: logoSize,
                                          height: logoSize,
                                          child: _buildLogo(widget.userLogoUrl, logoSize),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Section: Template Strip Selector
              SizedBox(
                height: 100,
                child: stripsAsync.when(
                  data: (strips) {
                    if (strips.isEmpty) {
                      return const Center(child: Text('No template strips found'));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: strips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final strip = TemplateStripModel.fromJson(strips[idx]);
                        final isSelected = selectedStrip?.id == strip.id;
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedStripProvider.notifier).state = strip;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.transparent,
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 8),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                strip.sampleFileUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
              // Action Buttons Row
              Container(
                width: double.infinity,
                color: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _onDownload,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _onWhatsApp,
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _onShare,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDownload() {
  }
}
