package ai.amani.amanisdk

import AmaniSDKUI
import ai.amani.base.util.SessionManager
import ai.amani.base.utility.AmaniVersion
import ai.amani.base.utility.AppConstants
import ai.amani.sdk.model.KYCResult
import ai.amani.sdk.utils.AppConstant
import ai.amani.sdk.utils.ProfileStatus
import ai.amani.sdk.DynamicFeature
import ai.amani.sdk.UploadSource
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.google.gson.JsonObject
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** AmanisdkPlugin  */
class AmanisdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null
    private var currentActivity: Activity? = null
    private var currentContext: Context? = null
    private var resultLauncher: ActivityResultLauncher<Intent>? = null
    private var isConfigured: Boolean = false

    // Call result to use in onActivityResult
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        currentContext = flutterPluginBinding.getApplicationContext()
        channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "amanisdk")
        channel!!.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "startAmaniSDKWithToken") {
            startAmaniSDKWithToken(call, result)
        } else if (call.method == "startAmaniSDKWithCredentials") {
//            startAmaniSDKWithCreds(call, result)
            result.notImplemented()
        } else if (call.method == "setConfigure") {
            setConfigure(call, result)
        } else if (call.method == "startAmaniSDKWithConfigure") {
           startAmaniSDKWithConfigure(call, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
    }

    // Gets currentActivity to pass startKYCProcess
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity

        resultLauncher = (currentActivity as FlutterFragmentActivity)!!.registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            Log.d("Flutter Bridge", "KYC Result")
            if (result.resultCode == Activity.RESULT_OK) {
                // There are no request codes
                val data: Intent? = result.data
                data?.let {
                    //Result of the KYC process
                    val kycResult: KYCResult? = it.parcelable(AppConstant.KYC_RESULT)
                    Log.d("Flutter Bridge", "KYC Result")
                    try {
                        val resultMap = JsonObject()
                        if (data != null) {
                            Log.d("Flutter Bridge", "KYC Result not null")
                            resultMap.addProperty(
                                "isVerificationCompleted",
                                kycResult!!.profileStatus == ProfileStatus.APPROVED
                            )
                            resultMap.addProperty(
                                "isTokenExpired",
                                kycResult!!.errorCode == 403
                            )
                            resultMap.addProperty(
                                "apiExceptionCode",
                                kycResult!!.errorCode,
                            )
//                            val stepList: Map<String?, String?>?
//                            stepList = SessionManager.getRules()
//                            val stepRules = JsonObject()
//                            if (stepList != null) {
//                                for ((key, value) in stepList) {
//                                    stepRules.addProperty(key, value)
//                                }
//                            }
//                            resultMap.add("rules", stepRules)
                            channel!!.invokeMethod("onSuccess", resultMap.toString())
                            true
                        } else {
                            resultMap.addProperty("isVerificationCompleted", false)
                            resultMap.addProperty("isTokenExpired", false)
                            resultMap.addProperty("apiExceptionCode", 1000)
//                                resultMap.addProperty("networkError", false)
                            channel!!.invokeMethod("onSuccess", resultMap.toString())
                        }
                    } catch (e: Exception) {
                        channel!!.invokeMethod(
                            "onError",
                            "Error happened while returning the result:$e"
                        )
                    }
                }
            }
        }
    }

    private fun setConfigure(call: MethodCall, result: MethodChannel.Result) {
    val context = currentContext
    if (context == null) {
        result.error("NO_CONTEXT", "Current context is null. Plugin is not attached to engine.", null)
        return
    }

    val server = call.argument<String>("server")
    if (server.isNullOrBlank()) {
        result.error("INVALID_ARGUMENT", "Argument 'server' must not be null or empty.", null)
        return
    }

   
    val features = call.argument<List<String>>("enabledFeatures") ?: emptyList()

    val dynamicFeatures = features.mapNotNull { featureName ->
        when (featureName) {
            "idCapture" -> DynamicFeature.ID_CAPTURE
            "idHologramDetection" -> DynamicFeature.ID_HOLOGRAM_DETECTION
            "nfcScan" -> DynamicFeature.NFC_SCAN
            "selfieAuto" -> DynamicFeature.SELFIE_AUTO
            "selfiePoseEstimation" -> DynamicFeature.SELFIE_POSE_ESTIMATION
            else -> null 
        }
    }

    
    val sharedSecret = call.argument<String>("sharedSecret")
    val uploadSourceString = call.argument<String>("uploadSource")
    val uploadSource = when (uploadSourceString) {
        "VIDEO" -> UploadSource.VIDEO
        "PASSWORD" -> UploadSource.PASSWORD
        "KYC", null -> UploadSource.KYC
        else -> UploadSource.KYC
    }

    val apiVersionString = call.argument<String>("apiVersion")
    val amaniVersion = when (apiVersionString) {
        "v1" -> AmaniVersion.V1
        "v2", null -> AmaniVersion.V2
        else -> AmaniVersion.V2
    }

    try {
        AmaniSDKUI.configure(
            applicationContext = context,
            serverURL = server,
            sharedSecret = sharedSecret,          
            amaniVersion = amaniVersion,
            uploadSource = uploadSource,
            enabledFeatures = dynamicFeatures    
        )
        isConfigured = true
        result.success(null)
    } catch (e: Exception) {
        result.error("CONFIGURE_FAILED", "AmaniSDKUI.configure failed: ${e.message}", null)
    }
}

private fun startAmaniSDKWithConfigure(call: MethodCall, result: MethodChannel.Result) {
    if (!isConfigured) {
        result.error(
            "NOT_CONFIGURED",
            "AmaniSDKUI is not configured. Call 'setConfigure' before starting KYC.",
            null
        )
        return
    }

    val activity = currentActivity
    val launcher = resultLauncher

    if (activity == null || launcher == null) {
        result.error(
            "NO_ACTIVITY",
            "Current Activity or resultLauncher is null.",
            null
        )
        return
    }

    val componentActivity = activity as? ComponentActivity
    if (componentActivity == null) {
        result.error(
            "INVALID_ACTIVITY",
            "Current Activity must be a ComponentActivity.",
            null
        )
        return
    }

    val idNumber = call.argument<String>("id")
    val token = call.argument<String>("token")

    if (idNumber.isNullOrBlank() || token.isNullOrBlank()) {
        result.error(
            "INVALID_ARGUMENT",
            "Arguments 'id' and 'token' must not be null or empty.",
            null
        )
        return
    }

    val birthDate = call.argument<String>("birthDate")
    val expireDate = call.argument<String>("expireDate")
    val documentNo = call.argument<String>("documentNo")

    val geoLocation = call.argument<Boolean>("geoLocation") ?: false
    val lang = call.argument<String>("lang")
        ?: call.argument<String>("language")
        ?: "en"

    val email = call.argument<String>("email")
    val phone = call.argument<String>("phone")
    val name = call.argument<String>("name")

    try {
        result.success(null)

        AmaniSDKUI.goToKycActivity(
            activity = componentActivity,
            resultLauncher = launcher,
            idNumber = idNumber,
            authToken = token,
            language = lang,
            geoLocation = geoLocation,
            birthDate = birthDate,
            expireDate = expireDate,
            documentNumber = documentNo,
            userEmail = email,
            userPhoneNumber = phone,
            userFullName = name
        )

    } catch (e: Exception) {
        Log.e("AmaniFlutterBridge", "Failed to start KYC activity", e)

        channel?.invokeMethod(
            "onError",
            "Failed to start KYC activity: ${e.message}"
        )
    }
}



   private fun startAmaniSDKWithToken(call: MethodCall, result: MethodChannel.Result) {
    val activity = currentActivity
    val launcher = resultLauncher

    if (activity == null || launcher == null) {
        result.error(
            "NO_ACTIVITY",
            "Current Activity or resultLauncher is null.",
            null
        )
        return
    }

    val componentActivity = activity as? ComponentActivity
    if (componentActivity == null) {
        result.error(
            "INVALID_ACTIVITY",
            "Current Activity must be a ComponentActivity.",
            null
        )
        return
    }

    val context = currentContext ?: activity.applicationContext

    val server = call.argument<String>("server")
    val token = call.argument<String>("token")
    val idNumber = call.argument<String>("id")

    if (server.isNullOrBlank()) {
        result.error(
            "INVALID_ARGUMENT",
            "Argument 'server' must not be null or empty.",
            null
        )
        return
    }

    if (token.isNullOrBlank()) {
        result.error(
            "INVALID_ARGUMENT",
            "Argument 'token' must not be null or empty.",
            null
        )
        return
    }

    if (idNumber.isNullOrBlank()) {
        result.error(
            "INVALID_ARGUMENT",
            "Argument 'id' must not be null or empty.",
            null
        )
        return
    }

    val birthDate = call.argument<String>("birthDate")
    val expireDate = call.argument<String>("expireDate")
    val documentNo = call.argument<String>("documentNo")

    val geoLocation = call.argument<Boolean>("geoLocation") ?: false

    // Hem mevcut "lang" key'ini hem de eski/alternatif "language" key'ini destekle.
    val lang = call.argument<String>("lang")
        ?: call.argument<String>("language")
        ?: "tr"

    val email = call.argument<String>("email")
    val phone = call.argument<String>("phone")
    val name = call.argument<String>("name")

    val apiVersionString = call.argument<String>("apiVersion")
    val apiVersion = when (apiVersionString) {
        "v1" -> AmaniVersion.V1
        "v2", null -> AmaniVersion.V2
        else -> AmaniVersion.V2
    }

    try {
        AmaniSDKUI.init(
            applicationContext = context,
            serverURL = server,
            amaniVersion = apiVersion
        )

        result.success(null)

        AmaniSDKUI.goToKycActivity(
            activity = componentActivity,
            resultLauncher = launcher,
            idNumber = idNumber,
            authToken = token,
            language = lang,
            geoLocation = geoLocation,
            birthDate = birthDate,
            expireDate = expireDate,
            documentNumber = documentNo,
            userEmail = email,
            userPhoneNumber = phone,
            userFullName = name
        )

    } catch (e: Exception) {
        Log.e("AmaniFlutterBridge", "Failed to start KYC activity with token", e)

        result.error(
            "START_KYC_FAILED",
            "Failed to start KYC activity: ${e.message}",
            null
        )
    }
}

    // Keep for ActivityAware implementation
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
}