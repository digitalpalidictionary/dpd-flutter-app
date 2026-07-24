package net.dpdict.dpd_flutter_app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.TextView
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

class SelectionAccessibilityService : AccessibilityService() {

    companion object {
        var instance: SelectionAccessibilityService? = null
        private const val SELECTION_FRESH_MS = 8000L
        const val PREFS = "dpd_bubble"
        const val PREF_VISIBLE = "visible"
        private const val PREF_X = "x"
        private const val PREF_Y = "y"
        const val PREF_BG = "bg"
        const val PREF_TEXT = "text"
        private const val DEFAULT_X = 24
        private const val DEFAULT_Y = 600
        // Fallbacks until Flutter pushes the live theme colours: amber + white.
        private const val DEFAULT_BG = 0xFFC27F29.toInt()
        private const val DEFAULT_TEXT = 0xFFFFFFFF.toInt()
    }

    private var windowManager: WindowManager? = null
    private var button: View? = null
    private var lastWord: String = ""
    private var lastWordAt: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        // The bubble is only shown while the DPD app is running (MainActivity
        // drives showButton on resume and hideButton on close), so it is not
        // auto-shown here.
    }

    // Tier 1: passive selection capture. Read the selected substring from the
    // EVENT's fromIndex/toIndex + text (never node.textSelectionStart/End, which
    // is -1 for WebView). Store it with a timestamp for the next bubble tap.
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_TEXT_SELECTION_CHANGED) return
        val text = event.text.joinToString("")
        val selected = extractSelection(text, event.fromIndex, event.toIndex)
        if (!selected.isNullOrBlank()) {
            lastWord = selected
            lastWordAt = SystemClock.elapsedRealtime()
        }
    }

    private fun extractSelection(text: String, start: Int, end: Int): String? {
        if (text.isEmpty()) return null
        if (start !in 0..text.length || end !in 0..text.length || start == end) return null
        return text.substring(min(start, end), max(start, end))
    }

    override fun onInterrupt() {}

    override fun onUnbind(intent: Intent?): Boolean {
        removeButton()
        instance = null
        return super.onUnbind(intent)
    }

    // A round "DPD" badge matching the in-app header logo: a circle in the theme
    // primary colour with the label in the theme's on-primary colour. Both
    // colours are pushed from Flutter (persisted) so it tracks light/dark/scheme.
    fun showButton() {
        if (button != null) return
        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val density = resources.displayMetrics.density
        val sizePx = (56 * density).toInt()
        val label = TextView(this).apply {
            text = "dpd"
            setTextColor(prefs.getInt(PREF_TEXT, DEFAULT_TEXT))
            textSize = 18f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            includeFontPadding = false
            setPadding(0, 0, 0, 0)
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(prefs.getInt(PREF_BG, DEFAULT_BG))
            }
        }
        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = prefs.getInt(PREF_X, DEFAULT_X)
            y = prefs.getInt(PREF_Y, DEFAULT_Y)
        }
        attachDragAndClick(label, params)
        windowManager?.addView(label, params)
        button = label
    }

    // Persist the theme colours and recolour the live bubble if it's showing.
    fun setColors(bg: Int, textColor: Int) {
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putInt(PREF_BG, bg)
            .putInt(PREF_TEXT, textColor)
            .apply()
        (button as? TextView)?.let {
            it.setTextColor(textColor)
            (it.background as? GradientDrawable)?.setColor(bg)
        }
    }

    fun hideButton() = removeButton()

    private fun removeButton() {
        button?.let { windowManager?.removeView(it) }
        button = null
    }

    private fun attachDragAndClick(view: View, params: WindowManager.LayoutParams) {
        var downX = 0f
        var downY = 0f
        var startX = 0
        var startY = 0
        var moved = false
        view.setOnTouchListener { _, e ->
            when (e.action) {
                MotionEvent.ACTION_DOWN -> {
                    downX = e.rawX; downY = e.rawY
                    startX = params.x; startY = params.y
                    moved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (e.rawX - downX).toInt()
                    val dy = (e.rawY - downY).toInt()
                    if (abs(dx) > 12 || abs(dy) > 12) moved = true
                    params.x = startX + dx
                    params.y = startY + dy
                    windowManager?.updateViewLayout(view, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (moved) {
                        getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                            .putInt(PREF_X, params.x)
                            .putInt(PREF_Y, params.y)
                            .apply()
                    } else {
                        onButtonTap()
                    }
                    true
                }
                else -> false
            }
        }
    }

    // Bubble tap: Tier 1 if we have a fresh passive selection (WebView / native
    // selectable text); otherwise Tier 2 — click the app's own visible "Copy"
    // button in the selection toolbar, foreground DPD, and read the clipboard.
    private fun onButtonTap() {
        val fresh = SystemClock.elapsedRealtime() - lastWordAt < SELECTION_FRESH_MS &&
            lastWord.isNotBlank()
        if (fresh) {
            val word = lastWord
            lastWord = ""
            launchApp { putExtra("bubble_text", word) }
            return
        }
        val copy = findCopyAcrossWindows()
        copy?.performAction(AccessibilityNodeInfo.ACTION_CLICK)
        Handler(Looper.getMainLooper()).postDelayed({
            launchApp { putExtra("from_a11y_button", true) }
        }, 400)
    }

    private fun launchApp(configure: Intent.() -> Unit) {
        val launch = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            configure()
        }
        if (launch != null) startActivity(launch)
    }

    // Tier 2: search the active window AND every other window (the system
    // floating selection toolbar can live in a separate window). Prefer a node
    // that actually offers ACTION_COPY; fall back to a "Copy"-labelled node.
    private fun findCopyAcrossWindows(): AccessibilityNodeInfo? {
        rootInActiveWindow?.let { r -> findCopyable(r)?.let { return it } }
        for (w in windows) {
            w.root?.let { r -> findCopyable(r)?.let { return it } }
        }
        rootInActiveWindow?.let { r -> findByLabel(r, "Copy")?.let { return it } }
        for (w in windows) {
            w.root?.let { r -> findByLabel(r, "Copy")?.let { return it } }
        }
        return null
    }

    private fun findCopyable(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.actionList.any { it.id == AccessibilityNodeInfo.ACTION_COPY }) return node
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            findCopyable(child)?.let { return it }
        }
        return null
    }

    private fun findByLabel(node: AccessibilityNodeInfo, label: String): AccessibilityNodeInfo? {
        val t = node.text?.toString()
        val cd = node.contentDescription?.toString()
        if (t == label || cd == label) return node
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            findByLabel(child, label)?.let { return it }
        }
        return null
    }
}
