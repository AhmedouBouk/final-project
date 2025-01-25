package com.example.emploi_esp

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager.LayoutParams

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }
}
