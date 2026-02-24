package com.github.sathish76.flutter_dnd;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.provider.Settings;
import android.os.Build;

/**
 * FlutterDndPlugin
 */
public class FlutterDndPlugin implements FlutterPlugin, MethodCallHandler {

    private MethodChannel channel;
    private Context context;
    private NotificationManager notificationManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_dnd");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.error("ERROR: INCOMPATIBLE_ANDROID_VERSION", "This methods required android version above 23", null);
            return;
        }
        switch (call.method) {
            case "isNotificationPolicyAccessGranted":
                result.success(isNotificationPolicyAccessGranted());
                break;
            case "gotoPolicySettings":
                gotoPolicySettings();
                result.success(null);
                break;
            case "setInterruptionFilter":
                int interruptionFilter = call.arguments();
                result.success(setInterruptionFilter(interruptionFilter));
                break;
            case "getCurrentInterruptionFilter":
                result.success(getCurrentInterruptionFilter());
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean isNotificationPolicyAccessGranted() {
        return notificationManager.isNotificationPolicyAccessGranted();
    }

    private void gotoPolicySettings() {
        Intent intent = new Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private boolean setInterruptionFilter(int interruptionFilter) {
        if (notificationManager.isNotificationPolicyAccessGranted()) {
            notificationManager.setInterruptionFilter(interruptionFilter);
            return true;
        }
        return false;
    }

    private int getCurrentInterruptionFilter() {
        return notificationManager.getCurrentInterruptionFilter();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
    }
}