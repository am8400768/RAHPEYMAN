package ir.rahpeyman.app

import android.provider.Settings
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "rahpeyman/device_attestation"
    private var integrityProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceId" -> {
                        val deviceId = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ANDROID_ID,
                        )
                        if (deviceId.isNullOrBlank()) {
                            result.error("DEVICE_ID_UNAVAILABLE", "Android ID is unavailable", null)
                        } else {
                            result.success(deviceId)
                        }
                    }
                    "prepareIntegrity" -> prepareIntegrity(
                        call.argument<String>("projectNumber"),
                        result,
                    )
                    "getIntegrityToken" -> requestIntegrityToken(
                        call.argument<String>("requestHash"),
                        result,
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun prepareIntegrity(projectNumber: String?, result: MethodChannel.Result) {
        val cloudProjectNumber = projectNumber?.toLongOrNull()
        if (cloudProjectNumber == null) {
            result.error("INVALID_PROJECT_NUMBER", "A Google Cloud project number is required", null)
            return
        }

        val manager = IntegrityManagerFactory.createStandard(applicationContext)
        manager.prepareIntegrityToken(
            StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build(),
        ).addOnSuccessListener {
            integrityProvider = it
            result.success(true)
        }.addOnFailureListener {
            result.error("INTEGRITY_PREPARE_FAILED", it.message, null)
        }
    }

    private fun requestIntegrityToken(requestHash: String?, result: MethodChannel.Result) {
        val provider = integrityProvider
        if (provider == null || requestHash.isNullOrBlank()) {
            result.error(
                "INTEGRITY_NOT_READY",
                "Prepare Play Integrity before requesting a token",
                null,
            )
            return
        }

        provider.request(
            StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                .setRequestHash(requestHash)
                .build(),
        ).addOnSuccessListener {
            result.success(it.token())
        }.addOnFailureListener {
            result.error("INTEGRITY_TOKEN_FAILED", it.message, null)
        }
    }
}
