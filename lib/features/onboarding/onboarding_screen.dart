import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Film-quality photos',
      'subtitle': 'Transform any photo into analog magic',
      'image': 'assets/onboarding/split.png', // Placeholder asset path
    },
    {
      'title': 'Curated presets',
      'subtitle': 'Each filter crafted to feel like real film',
      'image': 'assets/onboarding/grid.png',
    },
    {
      'title': 'One tap, ready to share',
      'subtitle': 'Export and share in seconds',
      'image': 'assets/onboarding/export.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: widget.onComplete,
                    child: Text(
                      'Skip',
                      style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 2. PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hero Image Placeholder
                            Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                child: Image.asset(
                                  _pages[index]['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 64,
                                      color: AppTheme.onBackgroundMuted.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing48),
                            
                            // Text
                            Text(
                              _pages[index]['title']!,
                              style: AppTheme.headingLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              _pages[index]['subtitle']!,
                              style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 3. Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing32),
                  child: Column(
                    children: [
                      // Page Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppTheme.accent
                                  : AppTheme.divider,
                            ),
                          ),
                        ),
                      ),
                      
                      // Get Started Button (Only on last page)
                      if (_currentPage == _pages.length - 1) ...[
                        const SizedBox(height: AppTheme.spacing32),
                        PrimaryButton(
                          text: 'Get Started',
                          onPressed: widget.onComplete,
                        ),
                      ] else ...[
                        // To keep layout stable
                        const SizedBox(height: AppTheme.spacing32 + 52),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
