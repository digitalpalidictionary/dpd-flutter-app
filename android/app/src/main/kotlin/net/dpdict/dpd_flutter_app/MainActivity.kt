package net.dpdict.dpd_flutter_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "net.dpdict.app/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "getProcessText") {
                    val text = intent
                        ?.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
                        ?.toString()
                    result.success(text)
                } else {
                    result.notImplemented()
                }
            }
    }
}
