package com.wakil_training_.enigma

import io.flutter.embedding.android.FlutterActivity
import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wakil_training_.enigma/ram"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getRamUsage") {
                val ramUsage = getRamUsage()
                result.success(ramUsage)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getRamUsage(): String {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)

        val totalRam = memoryInfo.totalMem / (1024 * 1024) // Convert to MB
        val availableRam = memoryInfo.availMem / (1024 * 1024) // Convert to MB
        val usedRam = totalRam - availableRam
        val usagePercent = (usedRam.toFloat() / totalRam * 100).toInt()

        return "Used: $usedRam MB / Total: $totalRam MB ($usagePercent%)"
    }
}
