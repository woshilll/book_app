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
                case "setConfig":
                    configMap.put(call.argument("key"), call.argument("value"));
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
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
     * 发送小说解析
     *
     * @param book 小说对象
     */
    public void sendBookPath(Map book) {
        channel.invokeMethod("bookPath", book);
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
}