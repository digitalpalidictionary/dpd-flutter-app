package net.dpdict.dpd_flutter_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/// Transparent trampoline that receives ACTION_PROCESS_TEXT from the text
/// selection menu, forwards the selected text to MainActivity, and finishes.
/// This avoids the singleTask + startActivityForResult incompatibility.
class ProcessTextActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val text = intent
            ?.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            ?.toString()?.trim()

        if (!text.isNullOrEmpty()) {
            val mainIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_PROCESS_TEXT
                putExtra(Intent.EXTRA_PROCESS_TEXT, text as CharSequence)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            startActivity(mainIntent)
        }

        finish()
    }
}
