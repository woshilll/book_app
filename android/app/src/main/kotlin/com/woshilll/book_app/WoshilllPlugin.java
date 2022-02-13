package com.woshilll.book_app;

import android.content.res.Resources;
import android.provider.Settings;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

public class WoshilllPlugin implements MethodChannel.MethodCallHandler {
    private final MethodChannel channel;
    private final MainActivity activity;
    /**
     * 存放配置信息
     */
    private final Map<String, Object> configMap = new HashMap<>(16);

    /**
     * 插件初始化
     *
     * @param messenger
     * @param activity
     */
    public WoshilllPlugin(BinaryMessenger messenger, MainActivity activity) {
        channel = new MethodChannel(messenger, "woshill/plugin");
        channel.setMethodCallHandler(this);
        this.activity = activity;

    }

    /**
     * 方法响应
     *
     * @param call
     * @param result
     */
    @Override
    public void onMethodCall(@NonNull @NotNull MethodCall call, @NonNull @NotNull MethodChannel.Result result) {
        try {
            switch (call.method) {
                case "setBrightness":
                    setBrightness((Double) call.arguments);
                    break;
                case "setConfig":
                    configMap.put(call.argument("key"), call.argument("value"));
                    break;
                case "getBrightness":
                    getBrightness(result);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 获取屏幕亮度
     */
    private void getBrightness(MethodChannel.Result result) throws Settings.SettingNotFoundException {
        int res = Settings.System.getInt(activity.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
        result.success(res / (double) getBrightnessMax());
    }

    /**
     * 音量物理键改变
     *
     * @param up true加音量 false减音量
     */
    public void sendVolumeChange(boolean up) {
        channel.invokeMethod("bookVolumeChange", up);
    }

    /**
     * 获取配置信息 有默认值
     *
     * @param key
     * @param configType
     * @return
     */
    public Object getConfigValue(String key, ConfigType configType) {
        Object res = configMap.get(key);
        if (res == null) {
            switch (configType) {
                case INT:
                    res = 0;
                    break;
                case MAP:
                    res = new HashMap<>(2);
                    break;
                case BOOLEAN:
                    res = false;
                    break;
                case DOUBLE:
                    res = 0.0d;
                    break;
            }
        }
        return res;
    }
    private void setBrightness(double value) {
        Window window = activity.getWindow();
        WindowManager.LayoutParams lp = window.getAttributes();
        lp.screenBrightness = (float) value;
        window.setAttributes(lp);
    }

    /**
     * 获取最大亮度
     * @return max
     */
    private int getBrightnessMax() {
        try {
            Resources system = Resources.getSystem();
            int resId = system.getIdentifier("config_screenBrightnessSettingMaximum", "integer", "android");
            if (resId != 0) {
                return system.getInteger(resId);
            }
        }catch (Exception ignore){}
        return 255;
    }
}