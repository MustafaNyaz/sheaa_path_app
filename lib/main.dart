import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';
import 'utils/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix System UI (Navbar/Statusbar color)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Desktop Window Size (Basic)
  if (PlatformUtils.isDesktop) {
    // Note: To truly control window size, we'd need 'window_manager' or 'bitsdojo_window' package.
    // For now, we rely on default OS behavior, but this block is ready for future window logic.
    debugPrint("Running on Desktop Platform");
  }

  // Init Firebase
  try {
    if (PlatformUtils.isWeb || PlatformUtils.isDesktop) {
      // Ideally: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      // Since we don't have the generated file yet, we stick to default or let it fail gracefully for now on desktop.
      // For Web, index.html usually handles it or we need the options.
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // Init Date Formatting
  await initializeDateFormatting('ar', null);

  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox<bool>('habits');

  final prefs = await SharedPreferences.getInstance();
  HijriCalendar.setLocal('ar');
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(prefs),
      child: ShowCaseWidget(
        builder: (context) => const SheaaPathApp(),
      ),
    ),
  );
}

class SheaaPathApp extends StatelessWidget {
  const SheaaPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: provider.tr('app_title'),
      locale: Locale(provider.locale),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(provider.fontScale),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.accent,
        canvasColor: AppColors.bgSoft,
        cardColor: AppColors.card,
        dividerColor: Colors.white.withValues(alpha: 0.08),
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          contentTextStyle: GoogleFonts.cairo(color: Colors.white),
          actionTextColor: AppColors.accent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: AppColors.surface,
          onPrimary: AppColors.bg,
          onSecondary: AppColors.bg,
          onSurface: Colors.white,
          error: AppColors.danger,
        ),
      ),
      home: const HomePage(),
    );
  }
}
