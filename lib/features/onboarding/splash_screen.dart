import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initialization time, matching the loading bar animation duration
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // True black for cinematic feel
      body: Stack(
        children: [
          // 1. Center Logo with Pulse/Glow
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing backdrop
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.15),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1500.ms, curve: Curves.easeInOutSine)
                .fade(begin: 0.5, end: 1.0, duration: 1500.ms, curve: Curves.easeInOutSine),

                // FILMICA Text
                const Text(
                  'FILMICA',
                  style: TextStyle(
                    fontFamily: 'Inter', // Using Inter per Stitch spec for the logo drop shadow
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 12.0, // Wide tracking (tracking-[0.4em] in HTML approx)
                    color: AppTheme.accent,
                    shadows: [
                      Shadow(
                        color: Color(0x99FDBA49), // Amber glow
                        blurRadius: 15,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                .slideY(begin: 0.1, end: 0, duration: 1000.ms, curve: Curves.easeOut),
              ],
            ),
          ),

          // 2. Loading Indicator and Text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Loading Bar
                Container(
                  width: 128,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 128, // Max width
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .scaleX(
                      begin: 0.0, 
                      end: 1.0, 
                      alignment: Alignment.centerLeft, 
                      duration: 2200.ms, 
                      curve: Curves.easeInOutQuart
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),

                const SizedBox(height: AppTheme.spacing24),

                // Status Text
                Text(
                  'INITIALIZING OPTICS',
                  style: AppTheme.labelLg.copyWith(
                    color: AppTheme.onBackgroundMuted.withOpacity(0.4),
                    letterSpacing: 2.0,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
