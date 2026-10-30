package com.example.control_financiero

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val verificationExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mi_presupuesto/updates")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "canInstall" -> result.success(canInstall())
                        "permission" -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                    Uri.parse("package:$packageName")))
                            }
                            result.success(null)
                        }
                        "verify", "install" -> {
                            verificationExecutor.execute {
                                try {
                                    val file = verifiedApk(call)
                                    runOnUiThread {
                                        try {
                                            if (call.method == "install") {
                                                check(canInstall()) { "Autorice la instalación desde esta aplicación." }
                                                val uri = FileProvider.getUriForFile(this,
                                                    "$packageName.updates", file)
                                                startActivity(Intent(Intent.ACTION_VIEW).apply {
                                                    setDataAndType(uri, "application/vnd.android.package-archive")
                                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                                })
                                            }
                                            result.success(null)
                                        } catch (error: Exception) {
                                            result.error("INSTALL_FAILED", error.message, null)
                                        }
                                    }
                                } catch (error: Exception) {
                                    runOnUiThread { result.error("INVALID_APK", error.message, null) }
                                }
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("UPDATE_FAILED", error.message, null)
                }
            }
    }

    private fun canInstall(): Boolean = Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
        packageManager.canRequestPackageInstalls()

    @Suppress("DEPRECATION")
    private fun verifiedApk(call: MethodCall): File {
        val path = requireNotNull(call.argument<String>("path"))
        val file = File(path).canonicalFile
        val directory = File(cacheDir, "app_updates").canonicalFile
        require(file.parentFile == directory && file.isFile &&
            Regex("update-[0-9]+\\.apk").matches(file.name)) { "Archivo de actualización inválido." }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
            PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val archive = requireNotNull(packageManager.getPackageArchiveInfo(file.path, flags)) {
            "El APK no es válido."
        }
        val installed = packageManager.getPackageInfo(packageName, flags)
        require(archive.packageName == packageName && !packageName.endsWith(".dev")) {
            "El APK no corresponde a esta aplicación."
        }
        require(archive.versionName == call.argument<String>("version") &&
            versionCode(archive) == call.argument<Number>("buildNumber")?.toLong() &&
            versionCode(archive) > versionCode(installed)) {
            "El APK no contiene la versión de actualización esperada."
        }
        fun signatures(info: PackageInfo): Set<String> {
            val values = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                info.signingInfo?.apkContentsSigners else info.signatures
            return values?.map { it.toCharsString() }?.toSet() ?: emptySet()
        }
        val expected = signatures(installed)
        require(expected.isNotEmpty() && signatures(archive) == expected) {
            "La firma del APK no coincide con la aplicación instalada."
        }
        return file
    }

    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode
        else info.versionCode.toLong()

    override fun onDestroy() {
        verificationExecutor.shutdown()
        super.onDestroy()
    }
}
