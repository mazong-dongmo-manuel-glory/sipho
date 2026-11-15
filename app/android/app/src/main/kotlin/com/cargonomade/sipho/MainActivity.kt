package com.cargonomade.sipho

import android.content.Context
import android.content.pm.ApplicationInfo
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Debuggable builds only: imposes the dev App Check debug token chosen in Dart, so it
        // survives reinstalls and is the same on every emulator.
        val isDebuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (!isDebuggable) return

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cargonomade.sipho/app_check_debug"
        ).setMethodCallHandler { call, result ->
            val token = call.arguments as? String
            if (call.method == "seedDebugToken" && !token.isNullOrBlank()) {
                seedDebugSecret(token)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * The Firebase App Check debug provider keeps its secret in SharedPreferences named after the
     * Firebase app's persistence key (base64url(name) + "+" + base64url(appId)). Writing it before
     * `activate` makes the provider use our token instead of generating a random one.
     */
    private fun seedDebugSecret(secret: String) {
        val flags = Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP
        val appId = getString(resources.getIdentifier("google_app_id", "string", packageName))
        val persistenceKey =
            Base64.encodeToString("[DEFAULT]".toByteArray(Charsets.UTF_8), flags) +
                "+" + Base64.encodeToString(appId.toByteArray(Charsets.UTF_8), flags)
        getSharedPreferences(
            "com.google.firebase.appcheck.debug.store.$persistenceKey",
            Context.MODE_PRIVATE
        ).edit()
            .putString("com.google.firebase.appcheck.debug.DEBUG_SECRET", secret)
            .commit()
    }
}
