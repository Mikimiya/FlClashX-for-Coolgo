package com.follow.clashx

import android.os.Build
import android.os.Bundle
import android.provider.Settings
import com.follow.clashx.plugins.AppPlugin
import com.follow.clashx.plugins.ServicePlugin
import com.follow.clashx.plugins.TilePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.attributes.preferredDisplayModeId = getHighestRefreshRateDisplayMode()
        }
    }

    private fun getHighestRefreshRateDisplayMode(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val modes = windowManager.defaultDisplay.supportedModes
            var maxRefreshRate = 60f
            var modeId = 0
            
            for (mode in modes) {
                if (mode.refreshRate > maxRefreshRate) {
                    maxRefreshRate = mode.refreshRate
                    modeId = mode.modeId
                }
            }
            return modeId
        }
        return 0
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Platform Channel for getting Android ID
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.follow.clashx/device_id")
            .setMethodCallHandler { call, result ->
                if (call.method == "getAndroidId") {
                    try {
                        val androidId = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ANDROID_ID
                        )
                        result.success(androidId)
                    } catch (e: Exception) {
                        result.error("ANDROID_ID_ERROR", "Failed to get Android ID: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
        
        flutterEngine.plugins.add(AppPlugin())
        flutterEngine.plugins.add(ServicePlugin)
        flutterEngine.plugins.add(TilePlugin())
        GlobalState.flutterEngine = flutterEngine
    }

    override fun onDestroy() {
        GlobalState.flutterEngine = null
        GlobalState.runState.value = RunState.STOP
        super.onDestroy()
    }
}