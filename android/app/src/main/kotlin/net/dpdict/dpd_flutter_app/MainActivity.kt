package net.dpdict.dpd_flutter_app

import android.content.ClipboardManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val methodChannelName = "net.dpdict.app/intent"
    private val eventChannelName = "net.dpdict.app/intent/stream"
    private val bubbleChannelName = "net.dpdict.app/bubble"

    private var eventSink: EventChannel.EventSink? = null

    // A word captured by the bubble may arrive before Flutter attaches its
    // stream listener (cold start). Buffer it and flush on onListen.
    private var pendingWord: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialText") {
                    result.success(extractText(intent))
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bubbleChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEnabled" -> result.success(isAccessibilityEnabled())
                    "isBubbleOn" -> result.success(
                        getSharedPreferences(
                            SelectionAccessibilityService.PREFS,
                            Context.MODE_PRIVATE
                        ).getBoolean(SelectionAccessibilityService.PREF_VISIBLE, false)
                    )
                    "openAccessibilitySettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    }
                    "showBubble" -> {
                        setBubbleVisiblePref(true)
                        applyBubbleColors(call)
                        SelectionAccessibilityService.instance?.showButton()
                        result.success(SelectionAccessibilityService.instance != null)
                    }
                    "setBubbleColor" -> {
                        applyBubbleColors(call)
                        result.success(null)
                    }
                    "hideBubble" -> {
                        setBubbleVisiblePref(false)
                        SelectionAccessibilityService.instance?.hideButton()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    pendingWord?.let { emitWord(it) }
                    pendingWord = null
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val text = extractText(intent)
        if (text != null) {
            emitWord(text)
        }
        handleBubbleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleBubbleIntent(intent)
        // Show the bubble while the app is in the foreground (it stays visible
        // over other apps while DPD is merely backgrounded; it is removed in
        // onDestroy when the app is actually closed).
        if (bubbleVisiblePref()) SelectionAccessibilityService.instance?.showButton()
    }

    override fun onDestroy() {
        // Closing the app (back-to-exit or swiped from recents) removes the
        // bubble, even though the accessibility service process lives on. The
        // on/off intent is kept, so the bubble returns next time DPD is opened.
        if (isFinishing) SelectionAccessibilityService.instance?.hideButton()
        super.onDestroy()
    }

    private fun bubbleVisiblePref(): Boolean =
        getSharedPreferences(SelectionAccessibilityService.PREFS, Context.MODE_PRIVATE)
            .getBoolean(SelectionAccessibilityService.PREF_VISIBLE, false)

    // Words routed in by the floating accessibility bubble. Tier 1 delivers the
    // selected word directly as an extra; Tier 2 clicks the app's Copy button,
    // so we read it from the clipboard once DPD is foregrounded.
    private fun handleBubbleIntent(intent: Intent?) {
        intent ?: return
        val bubbleText = intent.getStringExtra("bubble_text")
        if (!bubbleText.isNullOrBlank()) {
            intent.removeExtra("bubble_text")
            emitWord(bubbleText)
        }
        if (intent.getBooleanExtra("from_a11y_button", false)) {
            intent.removeExtra("from_a11y_button")
            Handler(Looper.getMainLooper()).postDelayed({ readClipboardAndEmit() }, 250)
        }
    }

    private fun readClipboardAndEmit() {
        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = cm.primaryClip ?: return
        if (clip.itemCount == 0) return
        val text = clip.getItemAt(0)?.coerceToText(this)?.toString()?.trim()
        if (!text.isNullOrEmpty()) emitWord(text)
    }

    private fun emitWord(text: String) {
        val sink = eventSink
        if (sink != null) {
            sink.success(text)
        } else {
            pendingWord = text
        }
    }

    // Theme colours pushed from Flutter (ARGB ints). Persisted so showButton and
    // onServiceConnected can restore them; applied live if the bubble is showing.
    private fun applyBubbleColors(call: MethodCall) {
        val bg = (call.argument<Any>("bg") as? Number)?.toInt()
        val text = (call.argument<Any>("text") as? Number)?.toInt()
        if (bg == null || text == null) return
        getSharedPreferences(SelectionAccessibilityService.PREFS, Context.MODE_PRIVATE)
            .edit()
            .putInt(SelectionAccessibilityService.PREF_BG, bg)
            .putInt(SelectionAccessibilityService.PREF_TEXT, text)
            .apply()
        SelectionAccessibilityService.instance?.setColors(bg, text)
    }

    private fun setBubbleVisiblePref(visible: Boolean) {
        getSharedPreferences(
            SelectionAccessibilityService.PREFS,
            Context.MODE_PRIVATE
        ).edit().putBoolean(SelectionAccessibilityService.PREF_VISIBLE, visible).apply()
    }

    private fun isAccessibilityEnabled(): Boolean {
        val expected = ComponentName(this, SelectionAccessibilityService::class.java)
        val enabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabled)
        while (splitter.hasNext()) {
            val cn = ComponentName.unflattenFromString(splitter.next())
            if (cn == expected) return true
        }
        return false
    }

    private fun extractText(intent: Intent?): String? {
        if (intent == null) return null
        return when (intent.action) {
            Intent.ACTION_SEND ->
                intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()?.takeIf { it.isNotEmpty() }
            Intent.ACTION_PROCESS_TEXT ->
                intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
                    ?.toString()?.trim()?.takeIf { it.isNotEmpty() }
            Intent.ACTION_VIEW ->
                intent.data?.lastPathSegment?.trim()?.takeIf { it.isNotEmpty() }
            else -> null
        }
    }
}
