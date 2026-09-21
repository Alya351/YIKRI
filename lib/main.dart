import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_service.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Désactiver le chargement réseau des polices — utilise les polices système
  GoogleFonts.config.allowRuntimeFetching = true;
  await AppService().init();
  runApp(
    const ProviderScope(
      child: YikriApp(),
    ),
  );
}

class YikriApp extends StatelessWidget {
  const YikriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yikri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
