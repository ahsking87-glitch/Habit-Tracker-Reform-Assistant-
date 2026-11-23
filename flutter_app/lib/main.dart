import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/theme/mizan_theme.dart';
import 'features/shell/presentation/mizan_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge rendering across Android & iOS system bars.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await StorageService.instance.init();
  runApp(
    const ProviderScope(
      child: MizanApp(),
    ),
  );
}

class MizanApp extends StatelessWidget {
  const MizanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mīzān (ميزان) — Offline Islamic Habit & Wellbeing',
      debugShowCheckedModeBanner: false,
      theme: MizanTypography.darkTheme(),
      home: const MizanShellScreen(),
    );
  }
}
