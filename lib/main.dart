import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/theme.dart';
import 'package:filmica/core/router.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/core/auth_sync_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Firebase & RevenueCat only work on native platforms
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }

    try {
      final rcApiKey = Platform.isIOS
          ? AppConstants.revenueCatApiKeyIos
          : AppConstants.revenueCatApiKeyAndroid;
      await Purchases.configure(PurchasesConfiguration(rcApiKey));

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        await Purchases.logIn(currentUser.id);
      }
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const FilmicaApp(),
    ),
  );
}

class FilmicaApp extends ConsumerWidget {
  const FilmicaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authSyncProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Filmica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
