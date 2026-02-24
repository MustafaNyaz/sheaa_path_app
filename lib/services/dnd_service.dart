import 'package:flutter_dnd/flutter_dnd.dart';
import '../utils/platform_utils.dart';

class DndService {
  static Future<bool> isPermissionGranted() async {
    if (!PlatformUtils.supportsDnd) return false;
    return await FlutterDnd.isNotificationPolicyAccessGranted ?? false;
  }

  static Future<void> gotoPolicySettings() async {
    if (!PlatformUtils.supportsDnd) return;
    FlutterDnd.gotoPolicySettings();
  }

  static Future<void> enableDnd() async {
    if (!PlatformUtils.supportsDnd) return;
    if (await isPermissionGranted()) {
      await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_PRIORITY);
    }
  }

  static Future<void> disableDnd() async {
    if (!PlatformUtils.supportsDnd) return;
    if (await isPermissionGranted()) {
      await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
    }
  }
}