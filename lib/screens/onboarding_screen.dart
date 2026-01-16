import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

// The GradientBackground class is now imported from widgets/gradient_background.dart

// Reusable app button for primary actions
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double? width;
  const AppButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.isPrimary = true,
      this.width});

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        height: 40,
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF662D8C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          onPressed: onPressed,
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.w600)),
      );
    }
  }
}

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/splash/onboarding1.png',
      'title': 'Create Stunning Posts',
      'subtitle':
          'Choose from hundreds of templates to boost your social presence.'
    },
    {
      'image': 'assets/images/splash/onboarding2.png',
      'title': 'Customize Easily',
      'subtitle': 'Edit text, colors, and images to match your brand.'
    },
    {
      'image': 'assets/images/splash/onboarding3.png',
      'title': 'Share Instantly',
      'subtitle': 'Download and share your creations in seconds.'
    },
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return OnboardingSlide(
                      image: slide['image']!,
                      title: slide['title']!,
                      subtitle: slide['subtitle']!,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      label: 'Skip',
                      onPressed: _skip,
                      isPrimary: false,
                    ),
                    PageIndicator(
                      count: _slides.length,
                      currentIndex: _currentPage,
                    ),
                    AppButton(
                      label: _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _next,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  const OnboardingSlide(
      {super.key,
      required this.image,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: media.size.height * 0.35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const PageIndicator(
      {super.key, required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: currentIndex == i ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == i ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
