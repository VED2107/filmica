import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/before_after_split.dart';
import '../../shared/widgets/plan_card.dart';
import '../../shared/widgets/primary_button.dart';

enum PaywallMode {
  preset, // Triggered by tapping a locked preset
  full,   // Triggered by export limit, watermark check, or profile
}

class PaywallScreen extends StatefulWidget {
  final PaywallMode mode;
  final String? presetName; // Required for preset mode
  final String? presetPrice; // Required for preset mode
  final ImageProvider beforeImage;
  final ImageProvider afterImage;
  final VoidCallback onClose;
  final VoidCallback onBuyPreset; // Only for preset mode
  final Function(String planId) onSubscribe;
  final VoidCallback onRestorePurchases;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final bool isLoading;

  const PaywallScreen({
    super.key,
    required this.mode,
    this.presetName,
    this.presetPrice,
    required this.beforeImage,
    required this.afterImage,
    required this.onClose,
    required this.onBuyPreset,
    required this.onSubscribe,
    required this.onRestorePurchases,
    required this.onTerms,
    required this.onPrivacy,
    this.isLoading = false,
  }) : assert(mode == PaywallMode.full || (presetName != null && presetPrice != null));

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlanId = 'yearly'; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.onBackgroundMuted),
                    onPressed: widget.onClose,
                  ),
                ),

                // 2. Before/After Split Image
                Container(
                  height: 240,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: BeforeAfterSplit(
                    beforeImage: widget.beforeImage,
                    afterImage: widget.afterImage,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),

                // 3. Heading & Subtext
                Text(
                  widget.mode == PaywallMode.preset
                      ? 'Unlock "${widget.presetName}"'
                      : 'Unlock All Presets',
                  style: AppTheme.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  widget.mode == PaywallMode.preset
                      ? 'Use this preset forever'
                      : 'Export without watermark',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing32),

                // 4. Preset Purchase Option (Only in Mode A)
                if (widget.mode == PaywallMode.preset) ...[
                  PrimaryButton(
                    text: 'Buy This Preset — ${widget.presetPrice}',
                    onPressed: widget.onBuyPreset,
                    isLoading: widget.isLoading,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppTheme.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                        child: Text(
                          'or unlock all',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.onBackgroundMuted),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppTheme.divider)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                ],

                // 5. Subscription Plan Cards
                PlanCard(
                  planName: 'YEARLY',
                  price: '\$19.99/yr',
                  badge: 'SAVE 58%',
                  isSelected: _selectedPlanId == 'yearly',
                  onTap: () => setState(() => _selectedPlanId = 'yearly'),
                ),
                PlanCard(
                  planName: 'MONTHLY',
                  price: '\$3.99/mo',
                  isSelected: _selectedPlanId == 'monthly',
                  onTap: () => setState(() => _selectedPlanId = 'monthly'),
                ),
                PlanCard(
                  planName: 'LIFETIME',
                  price: '\$49.99',
                  isSelected: _selectedPlanId == 'lifetime',
                  onTap: () => setState(() => _selectedPlanId = 'lifetime'),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // 6. Subscription CTA
                widget.mode == PaywallMode.preset
                    ? SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: widget.isLoading ? null : () => widget.onSubscribe(_selectedPlanId),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.accent, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                          ),
                          child: Text(
                            'Subscribe',
                            style: AppTheme.buttonText.copyWith(color: AppTheme.accent),
                          ),
                        ),
                      )
                    : PrimaryButton(
                        text: _selectedPlanId == 'yearly' ? 'Start Free Trial' : 'Subscribe',
                        onPressed: () => widget.onSubscribe(_selectedPlanId),
                        isLoading: widget.isLoading,
                      ),
                
                const SizedBox(height: AppTheme.spacing24),

                // 7. Footer Links
                GestureDetector(
                  onTap: widget.onRestorePurchases,
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: AppTheme.onBackgroundMuted,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.onTerms,
                      child: const Text('Terms', style: AppTheme.bodySmall),
                    ),
                    const Text(' · ', style: AppTheme.bodySmall),
                    GestureDetector(
                      onTap: widget.onPrivacy,
                      child: const Text('Privacy', style: AppTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
