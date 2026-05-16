import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/gallery/gallery_screen.dart';

final _galleryPermissionProvider = FutureProvider<bool>((ref) async {
  final status = await Permission.photos.status;
  return status.isGranted || status.isLimited;
});

class GalleryPage extends HookConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permAsync = ref.watch(_galleryPermissionProvider);
    final hasPermission = permAsync.valueOrNull ?? true;

    return GalleryScreen(
      hasPermission: hasPermission,
      onBack: () => context.pop(),
      onRequestPermission: () async {
        final status = await Permission.photos.request();
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        ref.invalidate(_galleryPermissionProvider);
      },
    );
  }
}

Future<void> pickAndEditImage(BuildContext context) async {
  AnalyticsService.instance.logGalleryOpened();
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null && context.mounted) {
    context.push(AppConstants.routeEditor, extra: image.path);
  }
}
