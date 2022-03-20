package com.woshilll.book_app

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.os.Bundle
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.app.ActivityCompat
import java.lang.Exception
import java.util.*

class MainActivity : FlutterActivity() {
    private lateinit var woshilllPlugin: WoshilllPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        this.woshilllPlugin = WoshilllPlugin(this.flutterEngine?.dartExecutor?.binaryMessenger, this)
        receiveActionSend(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        receiveActionSend(intent)
    }

    private fun processIntent(intent: Intent): Map<String, String?> {
        try {
            // 这个会在下面进行解释
            val uri: Uri? = intent.getParcelableExtra(Intent.EXTRA_STREAM)
            // 进行权限请求
            val permission = ActivityCompat.checkSelfPermission(
                    this,
                    READ_EXTERNAL_STORAGE
            )
            val permissionStorage: Array<String> = arrayOf(READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
            if (permission != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                        this,
                        permissionStorage,
                        1
                )
            }
            // 获取Intent中携带的数据
            val resolver = this.contentResolver
            if (uri != null) {
                resolver.openInputStream(uri).use {
                    val reader = it?.reader()
                    val content = reader?.readText()
                    val name = uri.path?.substring(uri.path!!.lastIndexOf('/') + 1)
                    return mapOf("name" to name, "content" to content)
                }
            }
        } catch (e: Exception) {
        }
        return mapOf()
    }

    private fun receiveActionSend(intent: Intent) {
        val action: String? = intent.action
        val type: String = if (intent.type != null) intent.type!! else "unknown"
        // 判断Intent action，如果是SEND则调用下列代码，还有一个类型为ACTION_SEND_MULTIPLE
        if (Intent.ACTION_SEND == (action)) {
            // 如果是text类型
            if (type.startsWith("text/")) {
                val map = processIntent(intent)
                // 调用Flutter方法对接收的文件内容进行处理
                woshilllPlugin.sendBookPath(map)
            }
        }
    }


}
