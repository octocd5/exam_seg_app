package com.example.exam_seg_app

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.exam_seg_app/blocker"
    private var isLocked = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermissions" -> {
                    val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }

                    if (!canDraw && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                }
                "startLock" -> {
                    isLocked = true
                    try {
                        startLockTask()
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    result.success(null)
                }
                "stopLock" -> {
                    isLocked = false
                    try {
                        stopLockTask()
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    result.success(null)
                }
                "getInstalledApps" -> {
                    Thread {
                        try {
                            val pm = packageManager
                            val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
                                addCategory(Intent.CATEGORY_LAUNCHER)
                            }
                            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0L))
                            } else {
                                pm.queryIntentActivities(mainIntent, 0)
                            }

                            val appList = mutableListOf<Map<String, Any?>>()
                            val seenPackages = mutableSetOf<String>()

                            for (info in resolveInfos) {
                                val pkgName = info.activityInfo.packageName
                                if (pkgName == packageName) continue
                                if (seenPackages.contains(pkgName)) continue
                                seenPackages.add(pkgName)

                                val appName = info.loadLabel(pm).toString()
                                val isSystem = (info.activityInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

                                var iconBytes: ByteArray? = null
                                try {
                                    val drawable = info.loadIcon(pm)
                                    val width = drawable.intrinsicWidth.coerceIn(1, 96)
                                    val height = drawable.intrinsicHeight.coerceIn(1, 96)
                                    val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                                        Bitmap.createScaledBitmap(drawable.bitmap, width, height, true)
                                    } else {
                                        val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                                        val canvas = Canvas(bmp)
                                        drawable.setBounds(0, 0, width, height)
                                        drawable.draw(canvas)
                                        bmp
                                    }
                                    val stream = ByteArrayOutputStream()
                                    bitmap.compress(Bitmap.CompressFormat.PNG, 85, stream)
                                    iconBytes = stream.toByteArray()
                                } catch (_: Exception) {
                                }

                                appList.add(
                                    mapOf(
                                        "appName" to appName,
                                        "packageName" to pkgName,
                                        "isSystemApp" to isSystem,
                                        "iconBytes" to iconBytes
                                    )
                                )
                            }

                            appList.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }

                            runOnUiThread {
                                result.success(appList)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("ERROR", e.localizedMessage, null)
                            }
                        }
                    }.start()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (isLocked) {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            startActivity(intent)
        }
    }
}
