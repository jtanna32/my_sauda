import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_sauda/config/router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://frsfgjqtvtnhvefsqimf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyc2ZnanF0dnRuaHZlZnNxaW1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2Mzk5NzUsImV4cCI6MjA5MzIxNTk3NX0.pFK3fZOQcSbuZCldN_wdE5TnlFCGNZWPZd-Aj9tQZ2U',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Sauda',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
