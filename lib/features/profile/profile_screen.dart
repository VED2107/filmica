import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final String? email;
  final bool isPremium;
  final VoidCallback onBack;
  final VoidCallback onSubscriptionTap;
  final VoidCallback onRestorePurchases;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsOfService;
  final VoidCallback onDeleteAccount;
  final VoidCallback? onSignIn;
  final String appVersion;

  const ProfileScreen({
    super.key,
    this.avatarUrl,
    required this.username,
    this.email,
    required this.isPremium,
    required this.onBack,
    required this.onSubscriptionTap,
    required this.onRestorePurchases,
    required this.onPrivacyPolicy,
    required this.onTermsOfService,
    required this.onDeleteAccount,
    this.onSignIn,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: onBack,
        ),
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.surfaceVariant,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: AppTheme.headingLarge,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Name & Email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            child: Text(
              username,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (email != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
              child: Text(
                email!,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          if (onSignIn != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing48),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppTheme.spacing48),
          
          // List Items
          _buildListTile(
            title: 'Subscription',
            trailingText: isPremium ? 'Pro' : 'Free',
            onTap: onSubscriptionTap,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildListTile(
            title: 'Restore Purchases',
            showArrow: true,
            onTap: onRestorePurchases,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildListTile(
            title: 'Privacy Policy',
            showArrow: true,
            onTap: onPrivacyPolicy,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildListTile(
            title: 'Terms of Service',
            showArrow: true,
            onTap: onTermsOfService,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          
          if (onSignIn == null) ...[
            const SizedBox(height: AppTheme.spacing32),
            ListTile(
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppTheme.error, fontSize: 16),
              ),
              onTap: onDeleteAccount,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            ),
          ],
          
          const SizedBox(height: AppTheme.spacing48),
          
          // App Version
          Center(
            child: Text(
              appVersion,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? trailingText,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: AppTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
            ),
          if (showArrow) ...[
            if (trailingText != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.onBackgroundMuted, size: 20),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: 4),
    );
  }
}
