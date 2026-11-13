package com.cargonomade.sipho

import android.content.Context
import android.content.pm.ApplicationInfo
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val isDebuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (!isDebuggable) return

        readAndroidAppCheckDebugSecret()?.let { secret ->
            Log.i("SiphoAI", "Android App Check Debug Token: $secret")
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cargonomade.sipho/app_check_debug"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDebugToken") {
                result.success(readAndroidAppCheckDebugSecret())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun readAndroidAppCheckDebugSecret(): String? {
        return try {
            val prefsDir = File(applicationInfo.dataDir, "shared_prefs")
            val files = prefsDir.listFiles() ?: return null
            for (file in files) {
                val name = file.name
                if (name.startsWith("com.google.firebase.appcheck.debug.store") &&
                    name.endsWith(".xml")
                ) {
                    val prefName = name.removeSuffix(".xml")
                    val prefs = getSharedPreferences(prefName, Context.MODE_PRIVATE)
                    val secret = prefs.getString(
                        "com.google.firebase.appcheck.debug.DEBUG_SECRET",
                        null
                    )
                    if (!secret.isNullOrBlank()) {
                        return secret
                    }
                }
            }
            null
        } catch (_: Exception) {
            null
        }
    }
}
