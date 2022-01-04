package com.woshilll.book_app;

import android.content.ContentResolver;
import android.provider.Settings;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.jetbrains.annotations.NotNull;

public class WoshilllPlugin implements MethodChannel.MethodCallHandler {
    private MethodChannel channel;
    private MainActivity activity;
    public WoshilllPlugin(BinaryMessenger messenger, MainActivity activity) {
        channel = new MethodChannel(messenger, "woshill/plugin");
        channel.setMethodCallHandler(this);
        this.activity = activity;

    }

    @Override
    public void onMethodCall(@NonNull @NotNull MethodCall call, @NonNull @NotNull MethodChannel.Result result) {
        if (call.method.equals("setBrightness")) {
            Window window = activity.getWindow();
            WindowManager.LayoutParams lp = window.getAttributes();
            lp.screenBrightness = Double.valueOf(String.valueOf(call.arguments)).floatValue();
            window.setAttributes(lp);
        }

    }
}