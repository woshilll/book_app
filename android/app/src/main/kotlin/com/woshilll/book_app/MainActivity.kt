package com.woshilll.book_app

import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private lateinit var woshilllPlugin: WoshilllPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.woshilllPlugin = WoshilllPlugin(flutterEngine.dartExecutor.binaryMessenger, this)
    }


    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        val volumeFlag: Boolean = woshilllPlugin.getConfigValue("volumeFlag", ConfigType.BOOLEAN) as Boolean
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && volumeFlag) {
            // 音量减
            woshilllPlugin.sendVolumeChange(false)
            return false
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP && volumeFlag) {
            // 音量加
            woshilllPlugin.sendVolumeChange(true)
            return false
        }
        return super.onKeyUp(keyCode, event)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        val volumeFlag: Boolean = woshilllPlugin.getConfigValue("volumeFlag", ConfigType.BOOLEAN) as Boolean
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && volumeFlag) {
            // 音量减
            return true
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP && volumeFlag) {
            // 音量加
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

}
