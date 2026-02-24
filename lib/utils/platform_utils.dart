import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;

  static bool get supportsDnd => isAndroid;
  static bool get supportsAlarms => isAndroid; // iOS needs local notifications
}
