import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AuthScreen extends StatelessWidget {
  final VoidCallback onAppleSignIn;
  final VoidCallback onGoogleSignIn;
  final bool isLoading;
  final String? errorMessage;

  const AuthScreen({
    super.key,
    required this.onAppleSignIn,
    required this.onGoogleSignIn,
    this.isLoading = false,
    this.errorMessage,
  });

  static void show(BuildContext context, {
    required VoidCallback onAppleSignIn,
    required VoidCallback onGoogleSignIn,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthScreen(
        onAppleSignIn: onAppleSignIn,
        onGoogleSignIn: onGoogleSignIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      padding: EdgeInsets.only(
        top: AppTheme.spacing12,
        left: AppTheme.spacing24,
        right: AppTheme.spacing24,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
          
          // Headings
          const Text(
            'Sign in to sync\nyour favorites & purchases',
            textAlign: TextAlign.center,
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: AppTheme.spacing32),
          
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],
          
          // Apple Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAppleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, color: Colors.black), // Standard Material apple icon or use a custom asset
                  SizedBox(width: 8),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Google Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onGoogleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceVariant,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for Google logo
                  Icon(Icons.g_mobiledata, color: Colors.white), 
                  SizedBox(width: 8),
                  Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing32),
          
          // Legal Text
          const Text(
            'By continuing, you agree to\nTerms of Service & Privacy Policy',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
