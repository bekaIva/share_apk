package com.bSoft.share_apk.share_apk
import android.Manifest
import android.app.AppOpsManager
import android.app.AppOpsManager.MODE_ALLOWED
import android.app.AppOpsManager.OPSTR_GET_USAGE_STATS
import android.app.usage.StorageStats
import android.app.usage.StorageStatsManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.PersistableBundle
import android.os.Process
import android.os.storage.StorageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)

    }
    private val CHANNEL = "com.bSoft.share_apk/packageChannel"
    private val CHANNELSTREAM = "com.bSoft.share_apk/appPremissionsStream"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        android.os.Process.myUserHandle()
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNELSTREAM).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any, events: EventSink) {
                        val packageInfo = packageManager.getPackageInfo(args as String, PackageManager.GET_PERMISSIONS)

                        for (i in packageInfo.requestedPermissions.indices) {
                            if (packageInfo.requestedPermissionsFlags[i] and PackageInfo.REQUESTED_PERMISSION_GRANTED != 0) {
                                val permission = packageInfo.requestedPermissions[i]
                               events.success(permission)
                            }
                        }

                    }
                    override fun onCancel(args: Any) {

                    }
                }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when(call.method)
            {
                "appPremissions"->  {
                    val appPemissions = getPermissionsByPackageName(call.argument("packageName"))
                    result.success(appPemissions)
                }
                "launchPackageOnMarket"->  {
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=${call.argument<String>("packageName")}")))
                    } catch (anfe: ActivityNotFoundException) {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=${call.argument<String>("packageName")}")))
                    }
                }
                "appSize"->  {
                    val appSize = getSizesByPackageName(call.argument("packageName")!!)
                    result.success(appSize)
                }
                "getGrantStatus"->  {
                    result.success(getGrantStatus())
                }
                "requestUsageAccessPermission"->  {
                    requestUsageAccessPermission()
                    result.success(null)
                }
                else-> {
                    result.notImplemented()
                }

            }
        }
    }
    private fun getGrantStatus(): Boolean {
        val appOps: AppOpsManager = applicationContext
                .getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode: Int = appOps.checkOpNoThrow(OPSTR_GET_USAGE_STATS,
                Process.myUid(), applicationContext.packageName)
        return if (mode == AppOpsManager.MODE_DEFAULT) {
            applicationContext.checkCallingOrSelfPermission(Manifest.permission.PACKAGE_USAGE_STATS) == PackageManager.PERMISSION_GRANTED
        } else {
            mode == MODE_ALLOWED
        }
    }
    private fun requestUsageAccessPermission() {
        startActivity( Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS));
    }
    private  fun getSizesByPackageName(packageName: String):Map<String,Long>
    {
        val storageStatsManager: StorageStatsManager = getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val stats: StorageStats = storageStatsManager.queryStatsForPackage(
                StorageManager.UUID_DEFAULT, packageName, Process.myUserHandle())
        return mapOf<String,Long>("app Size" to stats.appBytes,"cache Size" to stats.cacheBytes,"data Size" to stats.dataBytes);

    }
    private fun getPermissionsByPackageName(packageName: String?): List<String> {
        val list = mutableListOf<String>()
        try {
            val packageInfo = packageManager.getPackageInfo(packageName!!, PackageManager.GET_PERMISSIONS)
            for (i in packageInfo.requestedPermissions.indices) {
                if (packageInfo.requestedPermissionsFlags[i] and PackageInfo.REQUESTED_PERMISSION_GRANTED != 0) {
                    val permission = packageInfo.requestedPermissions[i]
                    list.add(permission);
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return  list;
    }


}
