import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:sheaa_path_app/main.dart';
import 'package:sheaa_path_app/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory hiveTempDir;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    hiveTempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(hiveTempDir.path);
    await Hive.openBox<bool>('habits');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveTempDir.delete(recursive: true);
  });

  testWidgets('App launches and displays title', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppProvider(
          prefs,
          enableAuth: false,
          enableNotifications: false,
        ),
        child: ShowCaseWidget(
          builder: (context) => const SheaaPathApp(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    // Verify that our title is present.
    expect(find.text('مسار الائمة'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}

