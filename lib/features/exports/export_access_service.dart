import 'package:filmica/core/constants.dart';

class ExportAccessDecision {
  const ExportAccessDecision({
    required this.canExport,
    required this.requiresWatermark,
    required this.remainingFreeExports,
    this.blockReason,
  });

  final bool canExport;
  final bool requiresWatermark;
  final int remainingFreeExports;
  final String? blockReason;
}

class ExportAccessService {
  const ExportAccessService();

  ExportAccessDecision resolve({
    required bool isPremium,
    required int dailyExportCount,
    required bool hasFullResolutionAccess,
  }) {
    if (isPremium) {
      return const ExportAccessDecision(
        canExport: true,
        requiresWatermark: false,
        remainingFreeExports: -1,
      );
    }

    final remaining = AppConstants.freeExportLimit - dailyExportCount;
    if (remaining <= 0) {
      return const ExportAccessDecision(
        canExport: false,
        requiresWatermark: true,
        remainingFreeExports: 0,
        blockReason: 'Daily free export limit reached',
      );
    }

    return ExportAccessDecision(
      canExport: true,
      requiresWatermark: !hasFullResolutionAccess,
      remainingFreeExports: remaining,
    );
  }
}
