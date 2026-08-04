package com.vozovoz.app.updater.vozovoz_app_updater

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** VozovozAppUpdaterPlugin */
class VozovozAppUpdaterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    Application.ActivityLifecycleCallbacks,
    PluginRegistry.ActivityResultListener {

    private companion object {
        const val TAG = "VozovozAppUpdater"
        const val CHANNEL_NAME = "vozovoz_app_updater"
        const val REQUEST_CODE_START_UPDATE = 1276

        const val ERROR_REQUIRE_CHECK = "REQUIRE_CHECK_FOR_UPDATE"
        const val ERROR_REQUIRE_ACTIVITY = "REQUIRE_FOREGROUND_ACTIVITY"
        const val ERROR_UPDATE_IN_PROGRESS = "UPDATE_IN_PROGRESS"
        const val ERROR_USER_DENIED = "USER_DENIED_UPDATE"
        const val ERROR_UPDATE_FAILED = "IN_APP_UPDATE_FAILED"
        const val ERROR_NO_UPDATE = "NO_UPDATE_AVAILABLE"
        const val ERROR_TASK_FAILURE = "TASK_FAILURE"
    }

    private var channel: MethodChannel? = null
    private var applicationContext: Context? = null
    private var activityBinding: ActivityPluginBinding? = null

    private var appUpdateManager: AppUpdateManager? = null

    /** Результат последнего успешного `checkForUpdate`, нужен для запуска flow. */
    private var appUpdateInfo: AppUpdateInfo? = null

    /** Тип запущенного сейчас обновления, `null` если ни одно не запущено. */
    private var runningUpdateType: Int? = null

    /**
     * Result запущенного обновления. Отвечаем на него ровно один раз — из
     * [onActivityResult] либо из [installStateListener], поэтому все обращения
     * идут через [finishUpdate].
     */
    private var updateResult: Result? = null

    private val installStateListener = InstallStateUpdatedListener { state ->
        when (state.installStatus()) {
            InstallStatus.DOWNLOADED -> finishUpdate { it.success(null) }
            InstallStatus.CANCELED -> finishUpdate {
                it.error(ERROR_USER_DENIED, "User canceled the flexible update", null)
            }

            InstallStatus.FAILED -> finishUpdate {
                it.error(ERROR_UPDATE_FAILED, "Flexible update failed", state.installErrorCode().toString())
            }

            else -> Unit
        }
    }

    private val activity: Activity?
        get() = activityBinding?.activity

    // region FlutterPlugin

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
        // Отвечаем на незавершённый flow (и снимаем listener) до того, как
        // обнулим appUpdateManager, иначе listener останется висеть на нём.
        finishUpdate { it.error(ERROR_UPDATE_FAILED, "Plugin detached from engine", null) }
        unregisterInstallStateListener()
        appUpdateManager = null
        appUpdateInfo = null
    }

    // endregion

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachActivity(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun attachActivity(binding: ActivityPluginBinding) {
        detachActivity()
        activityBinding = binding
        binding.addActivityResultListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
    }

    private fun detachActivity() {
        activityBinding?.let {
            it.removeActivityResultListener(this)
            it.activity.application.unregisterActivityLifecycleCallbacks(this)
        }
        activityBinding = null
    }

    // endregion

    // region Application.ActivityLifecycleCallbacks
    //
    // Play требует возобновлять прерванное IMMEDIATE-обновление при возврате в
    // приложение, иначе пользователь может остаться в частично обновлённом состоянии.

    override fun onActivityResumed(activity: Activity) {
        if (runningUpdateType != AppUpdateType.IMMEDIATE || activity !== this.activity) {
            return
        }
        appUpdateManager?.appUpdateInfo?.addOnSuccessListener { info ->
            if (info.updateAvailability() !=
                UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS
            ) {
                return@addOnSuccessListener
            }
            try {
                appUpdateManager?.startUpdateFlowForResult(
                    info,
                    activity,
                    AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                    REQUEST_CODE_START_UPDATE,
                )
            } catch (e: Exception) {
                Log.e(TAG, "Could not resume immediate update flow", e)
            }
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit

    override fun onActivityStarted(activity: Activity) = Unit

    override fun onActivityPaused(activity: Activity) = Unit

    override fun onActivityStopped(activity: Activity) = Unit

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

    override fun onActivityDestroyed(activity: Activity) = Unit

    // endregion

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkForUpdate" -> checkForUpdate(result)
            "performImmediateUpdate" -> startUpdate(AppUpdateType.IMMEDIATE, result)
            "startFlexibleUpdate" -> startUpdate(AppUpdateType.FLEXIBLE, result)
            "completeFlexibleUpdate" -> completeFlexibleUpdate(result)
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "getPackageDetail" -> getPackageDetails(result)
            "getDeviceInfo" -> getDeviceInfo(result)
            else -> result.notImplemented()
        }
    }

    private fun checkForUpdate(result: Result) {
        val context = applicationContext
        if (context == null) {
            result.error(ERROR_REQUIRE_CHECK, "Plugin is not attached to an engine", null)
            return
        }

        val manager = appUpdateManager ?: AppUpdateManagerFactory.create(context).also {
            appUpdateManager = it
        }

        manager.appUpdateInfo
            .addOnSuccessListener { info ->
                appUpdateInfo = info
                result.success(
                    mapOf(
                        "updateAvailability" to info.updateAvailability(),
                        "immediateAllowed" to info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE),
                        "flexibleAllowed" to info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE),
                        "availableVersionCode" to info.availableVersionCode(),
                        "installStatus" to info.installStatus(),
                        "packageName" to info.packageName(),
                        // Nullable по документации Play Core.
                        "clientVersionStalenessDays" to info.clientVersionStalenessDays(),
                        "updatePriority" to info.updatePriority(),
                    )
                )
            }
            .addOnFailureListener { e ->
                result.error(ERROR_TASK_FAILURE, e.message, null)
            }
    }

    private fun startUpdate(@AppUpdateType type: Int, result: Result) {
        val manager = appUpdateManager
        val info = appUpdateInfo
        if (manager == null || info == null) {
            result.error(ERROR_REQUIRE_CHECK, "Call checkForUpdate first!", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                ERROR_REQUIRE_ACTIVITY,
                "vozovoz_app_updater requires a foreground activity",
                null,
            )
            return
        }

        if (updateResult != null) {
            result.error(ERROR_UPDATE_IN_PROGRESS, "Another update flow is already running", null)
            return
        }

        val availability = info.updateAvailability()
        val resumable = availability == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS &&
            type == AppUpdateType.IMMEDIATE
        if (!resumable &&
            (availability != UpdateAvailability.UPDATE_AVAILABLE || !info.isUpdateTypeAllowed(type))
        ) {
            result.error(ERROR_NO_UPDATE, "No update available", null)
            return
        }

        runningUpdateType = type
        updateResult = result
        if (type == AppUpdateType.FLEXIBLE) {
            manager.registerListener(installStateListener)
        }

        try {
            // Именно `startUpdateFlowForResult`, а не `startUpdateFlow`: только он
            // доставляет результат в `onActivityResult` этого плагина.
            manager.startUpdateFlowForResult(
                info,
                currentActivity,
                AppUpdateOptions.newBuilder(type).build(),
                REQUEST_CODE_START_UPDATE,
            )
        } catch (e: Exception) {
            unregisterInstallStateListener()
            finishUpdate { it.error(ERROR_UPDATE_FAILED, "Could not start update flow", e.message) }
        }
    }

    private fun completeFlexibleUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error(ERROR_REQUIRE_CHECK, "Call checkForUpdate first!", null)
            return
        }
        manager.completeUpdate()
        result.success(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_START_UPDATE) {
            return false
        }

        when (resultCode) {
            Activity.RESULT_OK -> if (runningUpdateType == AppUpdateType.FLEXIBLE) {
                // Для flexible RESULT_OK означает только согласие пользователя:
                // ждём окончания загрузки в installStateListener.
                return true
            } else {
                finishUpdate { it.success(null) }
            }

            Activity.RESULT_CANCELED -> finishUpdate {
                it.error(ERROR_USER_DENIED, resultCode.toString(), null)
            }

            ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> finishUpdate {
                it.error(
                    ERROR_UPDATE_FAILED,
                    "Some other error prevented either the user from providing consent " +
                        "or the update to proceed.",
                    null,
                )
            }

            else -> finishUpdate { it.error(ERROR_UPDATE_FAILED, resultCode.toString(), null) }
        }
        return true
    }

    /**
     * Отвечает на [updateResult] не более одного раза и сбрасывает состояние
     * запущенного обновления.
     */
    private fun finishUpdate(reply: (Result) -> Unit) {
        val pending = updateResult ?: return
        updateResult = null
        runningUpdateType = null
        unregisterInstallStateListener()
        reply(pending)
    }

    private fun unregisterInstallStateListener() {
        try {
            appUpdateManager?.unregisterListener(installStateListener)
        } catch (e: Exception) {
            Log.w(TAG, "Could not unregister install state listener", e)
        }
    }

    private fun getPackageDetails(result: Result) {
        val context = applicationContext
        if (context == null) {
            result.error(ERROR_REQUIRE_CHECK, "Plugin is not attached to an engine", null)
            return
        }
        try {
            val packageManager = context.packageManager
            val info = packageManager.packageInfo(context.packageName)

            result.success(
                mapOf(
                    "appName" to (info.applicationInfo?.loadLabel(packageManager)?.toString()
                        ?: "Unknown"),
                    "packageName" to context.packageName,
                    "version" to (info.versionName ?: "N/A"),
                    "buildNumber" to info.longVersionCodeCompat().toString(),
                )
            )
        } catch (ex: PackageManager.NameNotFoundException) {
            result.error("Name not found", ex.message, null)
        }
    }

    private fun getDeviceInfo(result: Result) {
        result.success(
            mapOf(
                "manufacturer" to Build.MANUFACTURER,
                "brand" to Build.BRAND,
                "model" to Build.MODEL,
                "device" to Build.DEVICE,
                "systemVersion" to Build.VERSION.RELEASE,
                "sdkInt" to Build.VERSION.SDK_INT,
            )
        )
    }

    @Suppress("DEPRECATION")
    private fun PackageManager.packageInfo(packageName: String): PackageInfo =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            getPackageInfo(packageName, 0)
        }

    @Suppress("DEPRECATION")
    private fun PackageInfo.longVersionCodeCompat(): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) longVersionCode else versionCode.toLong()
}
