package com.example.run_tracker

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.view.WindowInsets
import android.view.WindowManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.insetsController?.hide(WindowInsets.Type.statusBars())
            } else {
                window.setFlags(
                        WindowManager.LayoutParams.FLAG_FULLSCREEN,
                        WindowManager.LayoutParams.FLAG_FULLSCREEN
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if(ContextCompat.checkSelfPermission(this,
                        Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_DENIED){
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val permission = arrayListOf<String>()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    permission.add(Manifest.permission.ACTIVITY_RECOGNITION)
                }
                requestPermissions(permission.toArray() as Array<out String>, 123)
            };
        }

    }
}
