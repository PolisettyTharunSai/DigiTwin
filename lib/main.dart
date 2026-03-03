import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmttaxboppfkgwjrjmjv.supabase.co',
    anonKey: 'sb_publishable_ym-0DfmWA2Wyjn-6aXDAIQ_Wbw3-bOB',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final isUrdu = locale.languageCode == 'ur';
        return Directionality(
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
