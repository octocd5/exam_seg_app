package com.example.exam_seg_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class FocusOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "focus_overlay_channel"
        const val NOTIFICATION_ID = 90210
        const val ACTION_STOP = "STOP"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isOverlayShowing = false
    private var currentBlockedAppLabel: String? = null

    private var blockedList: List<String> = emptyList()
    private var isPhoneWideBan: Boolean = false

    private val mainHandler = Handler(Looper.getMainLooper())
    private var monitorThread: HandlerThread? = null
    private var monitorHandler: Handler? = null

    private val monitorRunnable = object : Runnable {
        override fun run() {
            checkForegroundApp()
            monitorHandler?.postDelayed(this, 350)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()

        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)

        monitorThread = HandlerThread("FocusOverlayMonitor").apply { start() }
        monitorHandler = Handler(monitorThread!!.looper)
        monitorHandler?.post(monitorRunnable)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopMonitoringAndOverlay()
            stopSelf()
            return START_NOT_STICKY
        }

        intent?.let {
            blockedList = it.getStringArrayListExtra("packages") ?: emptyList()
            isPhoneWideBan = it.getBooleanExtra("isPhoneWideBan", false)
        }

        return START_STICKY
    }

    private fun stopMonitoringAndOverlay() {
        monitorHandler?.removeCallbacks(monitorRunnable)
        monitorThread?.quitSafely()
        monitorThread = null
        monitorHandler = null

        mainHandler.post {
            removeOverlay()
        }
    }

    override fun onDestroy() {
        stopMonitoringAndOverlay()
        super.onDestroy()
    }

    private fun checkForegroundApp() {
        val topPackage = getForegroundPackage() ?: return

        // 1. Never block our own application
        if (topPackage == packageName) {
            mainHandler.post { removeOverlay() }
            return
        }

        // 2. Never block launcher/home screen
        if (isLauncherPackage(topPackage)) {
            mainHandler.post { removeOverlay() }
            return
        }

        // 3. Never block system critical packages (telecom, emergency dialer, systemui, settings)
        if (isSystemCriticalPackage(topPackage)) {
            mainHandler.post { removeOverlay() }
            return
        }

        val appLabel = getAppLabel(topPackage)
        val isMatch = matchesList(topPackage, appLabel, blockedList)

        val shouldBlock = if (isPhoneWideBan) {
            // In phone-wide ban, apps on the list are excluded (allowed). All others are blocked.
            !isMatch
        } else {
            // In blocklist mode, only apps on the list are blocked.
            isMatch
        }

        if (shouldBlock) {
            mainHandler.post {
                showOverlay(topPackage, appLabel, isPhoneWideBan)
            }
        } else {
            mainHandler.post {
                removeOverlay()
            }
        }
    }

    private fun getForegroundPackage(): String? {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return null
        val now = System.currentTimeMillis()

        // Check events in the last 6 seconds
        val events = usm.queryEvents(now - 6000, now)
        val event = UsageEvents.Event()
        var topPkg: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                topPkg = event.packageName
            }
        }

        if (topPkg != null) return topPkg

        // Fallback to recent usage stats
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, now - 6000, now)
        if (!stats.isNullOrEmpty()) {
            val mostRecent = stats.maxByOrNull { it.lastTimeUsed }
            if (mostRecent != null && (now - mostRecent.lastTimeUsed) < 6000) {
                return mostRecent.packageName
            }
        }

        return null
    }

    private fun isLauncherPackage(pkg: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            resolveInfo?.activityInfo?.packageName == pkg
        } catch (_: Exception) {
            false
        }
    }

    private fun isSystemCriticalPackage(pkg: String): Boolean {
        val lower = pkg.lowercase()
        return lower == "com.android.systemui" ||
                lower == "com.android.settings" ||
                lower.contains("telecom") ||
                lower.contains("dialer") ||
                lower.contains("incallui") ||
                lower == "com.android.phone"
    }

    private fun getAppLabel(pkg: String): String {
        return try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(pkg, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (_: Exception) {
            pkg
        }
    }

    private fun matchesList(pkg: String, label: String, list: List<String>): Boolean {
        val lowerPkg = pkg.lowercase()
        val lowerLabel = label.lowercase()

        for (item in list) {
            val lowerItem = item.trim().lowercase()
            if (lowerItem.isEmpty()) continue
            if (lowerPkg == lowerItem || lowerLabel == lowerItem) return true
            if (lowerPkg.contains(lowerItem) || lowerItem.contains(lowerLabel)) return true
        }
        return false
    }

    private fun showOverlay(pkg: String, appLabel: String, phoneWide: Boolean) {
        if (!canDrawOverlays()) return

        if (isOverlayShowing) {
            // Already showing. If app changed, update text
            if (currentBlockedAppLabel != appLabel) {
                currentBlockedAppLabel = appLabel
                updateOverlayContent(appLabel, phoneWide)
            }
            return
        }

        try {
            currentBlockedAppLabel = appLabel
            val view = buildOverlayView(appLabel, phoneWide)
            overlayView = view

            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                type,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.CENTER
            }

            windowManager?.addView(view, params)
            isOverlayShowing = true
        } catch (e: Exception) {
            e.printStackTrace()
            isOverlayShowing = false
        }
    }

    private fun removeOverlay() {
        if (!isOverlayShowing || overlayView == null) return
        try {
            windowManager?.removeView(overlayView)
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isOverlayShowing = false
            overlayView = null
            currentBlockedAppLabel = null
        }
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            resources.displayMetrics
        ).toInt()
    }

    private val isSpanish: Boolean
        get() = java.util.Locale.getDefault().language.equals("es", ignoreCase = true)

    private fun getOverlayMessage(appLabel: String, phoneWide: Boolean): String {
        return if (phoneWide) {
            if (isSpanish) {
                "Bloqueo Total del Teléfono Activo\n\n\"$appLabel\" está restringida. Solo las aplicaciones excluidas en tu lista están accesibles."
            } else {
                "Phone-Wide Focus Ban Active\n\n\"$appLabel\" is restricted. Only apps excluded in your study list are accessible."
            }
        } else {
            if (isSpanish) {
                "\"$appLabel\" está bloqueada\n\nEsta app está en tu lista de distracciones. ¡Mantén tu concentración!"
            } else {
                "\"$appLabel\" is Blocked\n\nThis app is on your study distraction list. Stay in your focus zone!"
            }
        }
    }

    private fun buildOverlayView(appLabel: String, phoneWide: Boolean): View {
        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#F51D1C1A")) // Standby background
            isClickable = true
            isFocusable = true
        }

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dpToPx(28f), dpToPx(32f), dpToPx(28f), dpToPx(32f))

            val cardBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(24f).toFloat()
                setColor(Color.parseColor("#282724")) // Standby card background
                setStroke(dpToPx(1.5f), Color.parseColor("#383633")) // Standby card border
            }
            background = cardBg
        }

        val cardParams = FrameLayout.LayoutParams(
            dpToPx(340f).coerceAtMost((resources.displayMetrics.widthPixels * 0.90f).toInt()),
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }

        // Icon
        val iconContainer = FrameLayout(this).apply {
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#33312E"))
                setStroke(dpToPx(2f), Color.parseColor("#C4BDDD")) // Standby accent
            }
            background = bg
        }
        val iconParams = LinearLayout.LayoutParams(dpToPx(64f), dpToPx(64f)).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            bottomMargin = dpToPx(16f)
        }

        val iconView = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_lock_idle_lock)
            setColorFilter(Color.parseColor("#C4BDDD")) // Standby accent
            val p = dpToPx(16f)
            setPadding(p, p, p, p)
        }
        iconContainer.addView(iconView)
        card.addView(iconContainer, iconParams)

        // Title
        val titleView = TextView(this).apply {
            text = if (isSpanish) "Focus Guard Activo" else "Focus Guard Active"
            textSize = 21f
            setTextColor(Color.parseColor("#FAF8F6")) // Standby text
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        val titleParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = dpToPx(8f)
        }
        card.addView(titleView, titleParams)

        // Subtitle / message
        val messageView = TextView(this).apply {
            id = View.generateViewId()
            tag = "message_view"
            textSize = 14f
            setTextColor(Color.parseColor("#A6A4A2")) // Standby text secondary
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.25f)
            text = getOverlayMessage(appLabel, phoneWide)
        }
        val messageParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = dpToPx(24f)
        }
        card.addView(messageView, messageParams)

        // Primary Button: Return to Focus Timer
        val returnButton = Button(this).apply {
            text = if (isSpanish) "VOLVER AL TEMPORIZADOR" else "RETURN TO FOCUS TIMER"
            textSize = 14f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.parseColor("#1D1C1A")) // Standby button text

            val btnBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(14f).toFloat()
                setColor(Color.parseColor("#C4BDDD")) // Standby button color
            }
            background = btnBg

            setOnClickListener {
                val intent = Intent(this@FocusOverlayService, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                startActivity(intent)
            }
        }
        val btnParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            dpToPx(50f)
        ).apply {
            bottomMargin = dpToPx(10f)
        }
        card.addView(returnButton, btnParams)

        // Secondary Button: Exit to Home Screen
        val homeButton = Button(this).apply {
            text = if (isSpanish) "Ir a la Pantalla de Inicio" else "Go to Home Screen"
            textSize = 13f
            setTextColor(Color.parseColor("#FAF8F6")) // Standby text

            val homeBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(14f).toFloat()
                setColor(Color.parseColor("#1D1C1A")) // Standby background
                setStroke(dpToPx(1.2f), Color.parseColor("#383633")) // Standby card border
            }
            background = homeBg

            setOnClickListener {
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(homeIntent)
            }
        }
        val homeParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            dpToPx(44f)
        )
        card.addView(homeButton, homeParams)

        root.addView(card, cardParams)
        return root
    }

    private fun updateOverlayContent(appLabel: String, phoneWide: Boolean) {
        val messageView = overlayView?.findViewWithTag<TextView>("message_view")
        messageView?.text = getOverlayMessage(appLabel, phoneWide)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                if (isSpanish) "Servicio de Bloqueo Focus Guard" else "Focus Guard Blocker Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = if (isSpanish) {
                    "Mantiene las distracciones bloqueadas durante las sesiones de enfoque"
                } else {
                    "Keeps distractions blocked while focus sessions are active"
                }
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle(if (isSpanish) "Focus Guard Activo" else "Focus Guard Active")
            .setContentText(if (isSpanish) "Protección de superposición de distracciones en ejecución" else "Distraction overlay protection running")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}
