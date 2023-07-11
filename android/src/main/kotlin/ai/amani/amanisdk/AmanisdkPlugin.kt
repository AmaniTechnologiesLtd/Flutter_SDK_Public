package ai.amani.amanisdk

import AmaniSDKUI
import ai.amani.base.util.SessionManager
import ai.amani.base.utility.AmaniVersion
import ai.amani.base.utility.AppConstants
import ai.amani.sdk.model.KYCResult
import ai.amani.sdk.utils.AppConstant
import ai.amani.sdk.utils.ProfileStatus
import android.app.Activity
import android.content.Context
import android.content.Intent
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
            if (result.resultCode == Activity.RESULT_OK) {
                // There are no request codes
                val data: Intent? = result.data
                data?.let {
                    //Result of the KYC process
                    val kycResult: KYCResult? = it.parcelable(AppConstant.KYC_RESULT)
                    try {
                        val resultMap = JsonObject()
                        if (data != null) {
                            resultMap.addProperty(
                                "isVerificationCompleted",
                                kycResult!!.profileStatus == ProfileStatus.APPROVED
                            )
                            resultMap.addProperty(
                                "isTokenExpired",
                                kycResult!!.httpErrorCode == 403
                            )
                            resultMap.addProperty(
                                "apiExceptionCode",
                                kycResult!!.httpErrorCode,
                            )
                            val stepList: Map<String?, String?>?
                            stepList = SessionManager.getRules()
                            val stepRules = JsonObject()
                            if (stepList != null) {
                                for ((key, value) in stepList) {
                                    stepRules.addProperty(key, value)
                                }
                            }
                            resultMap.add("rules", stepRules)
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

    private fun startAmaniSDKWithToken(call: MethodCall, result: MethodChannel.Result) {
        var birthDate: String? = null
        var expireDate: String? = null
        var documentNo: String? = null
        var geoLocation = false
        var lang: String? = null
        var email: String? = null
        var phone: String? = null
        var name: String? = null
        if (call.hasArgument("birthDate")) {
            birthDate = call.argument<String>("birthDate")
        }
        if (call.hasArgument("expireDate")) {
            expireDate = call.argument<String>("expireDate")
        }
        if (call.hasArgument("documentNo")) {
            documentNo = call.argument<String>("documentNo")
        }
        geoLocation = if (call.hasArgument("geoLocation")) {
            call.argument<Boolean>("geoLocation")!!
        } else {
            false
        }
        if (call.hasArgument("lang")) {
            lang = call.argument<String>("lang")
        }
        if (call.hasArgument("email")) {
            email = call.argument<String>("email")
        }
        if (call.hasArgument("phone")) {
            phone = call.argument<String>("phone")
        }
        if (call.hasArgument("name")) {
            name = call.argument<String>("name")
        }
        AmaniSDKUI.init(
            activity = currentActivity!!,
            serverURL = call.argument("server")!!,
            amaniVersion = AmaniVersion.V2,
        )
        if (email != null && phone != null && name != null) {
            if (birthDate != null && expireDate != null && documentNo != null) {
                AmaniSDKUI.goToKycActivity(
                    activity = currentActivity as ComponentActivity, //Activity pointer
                    resultLauncher = resultLauncher!!, //Requires for listening the activity result, sample resultLauncher is below
                    idNumber = call.argument<String>("id")!!,
                    authToken = call.argument("token")!!,
                    language = lang!!,
                    geoLocation = true, //Giving permission to access SDK user's location data to process that data
                    birthDate = birthDate, //YYMMDD format. (For Example: 20 May 1990 is 900520). If NFC not used not mandatory
                    expireDate = expireDate, //YYMMDD format. Expire date of SDK user's ID Card, If NFC not used not mandatory
                    documentNumber = documentNo, // Document number of SDK user's ID Card, If NFC not used not mandatory
                    userEmail = email, // Email of the SDK user, non mandatory field
                    userPhoneNumber = phone, //Phone number of the SDK user, non mandatory field,
                    userFullName = name //Full name of the SDK user, non mandatory field
                )
            } else {
                AmaniSDKUI.goToKycActivity(
                    activity = currentActivity as ComponentActivity,
                    resultLauncher = resultLauncher!!,
                    idNumber =  call.argument("id")!!,
                    authToken = call.argument("token")!!,
                    language = lang!!,
                    birthDate = null,
                    expireDate = null,
                    documentNumber = null,
                    userEmail = email,
                    userPhoneNumber = phone,
                    userFullName = name
                )

            }
        } else {
            if (birthDate != null && expireDate != null && documentNo != null) {
                AmaniSDKUI.goToKycActivity(
                    activity = currentActivity as ComponentActivity,
                    resultLauncher = resultLauncher!!,
                    idNumber = call.argument("id")!!,
                    authToken = call.argument("token")!!,
                    language = lang!!,
                    birthDate = birthDate,
                    expireDate = expireDate,
                    documentNumber = documentNo,
                    geoLocation = geoLocation,
                    userEmail = null,
                    userPhoneNumber = null,
                    userFullName = null,
                )
            } else {
                AmaniSDKUI.goToKycActivity(
                    activity = currentActivity!!,
                    resultLauncher = resultLauncher!!,
                    idNumber = call.argument("id")!!,
                    authToken = call.argument("token")!!
                )
            }
        }
    }

//    private fun startAmaniSDKWithCreds(call: MethodCall, result: MethodChannel.Result) {
//        var birthDate: String? = null
//        var expireDate: String? = null
//        var documentNo: String? = null
//        var geoLocation = false
//        var lang: String? = null
//        var email: String? = null
//        var phone: String? = null
//        var name: String? = null
//        if (call.hasArgument("birthDate")) {
//            birthDate = call.argument<String>("birthDate")
//        }
//        if (call.hasArgument("expireDate")) {
//            expireDate = call.argument<String>("expireDate")
//        }
//        if (call.hasArgument("documentNo")) {
//            documentNo = call.argument<String>("documentNo")
//        }
//        geoLocation = if (call.hasArgument("geoLocation")) {
//            call.argument<Boolean>("geoLocation")!!
//        } else {
//            false
//        }
//        if (call.hasArgument("lang")) {
//            lang = call.argument<String>("lang")
//        }
//        if (call.hasArgument("email")) {
//            email = call.argument<String>("email")
//        }
//        if (call.hasArgument("phone")) {
//            phone = call.argument<String>("phone")
//        }
//        if (call.hasArgument("name")) {
//            name = call.argument<String>("name")
//        }
//        Amani.init(currentContext, call.argument("server"))
//        if (email != null && phone != null && name != null) {
//            if (birthDate != null && expireDate != null && documentNo != null) {
////                Amani.goToKycActivity(
////                    currentActivity,
////                    call.argument("id"),
////                    call.argument("loginEmail"),
////                    call.argument("loginPassword"),
////                    birthDate,
////                    expireDate,
////                    documentNo,
////                    geoLocation,
////                    lang,
////                    email,
////                    phone,
////                    name
////                )
//                AmaniSDKUI.goToKycActivity(
//                    activity = currentActivity as ComponentActivity, //Activity pointer
//                    resultLauncher = resultLauncher!!, //Requires for listening the activity result, sample resultLauncher is below
//                    idNumber = call.argument<String>("id")!!,
//                    authToken = call.argument("token")!!,
//                    language = lang!!,
//                    geoLocation = true, //Giving permission to access SDK user's location data to process that data
//                    birthDate = birthDate, //YYMMDD format. (For Example: 20 May 1990 is 900520). If NFC not used not mandatory
//                    expireDate = expireDate, //YYMMDD format. Expire date of SDK user's ID Card, If NFC not used not mandatory
//                    documentNumber = documentNo, // Document number of SDK user's ID Card, If NFC not used not mandatory
//                    userEmail = email, // Email of the SDK user, non mandatory field
//                    userPhoneNumber = phone, //Phone number of the SDK user, non mandatory field,
//                    userFullName = name //Full name of the SDK user, non mandatory field
//                )
//            } else {
//                Amani.goToKycActivity(
//                    currentActivity,
//                    call.argument("id"), call.argument("loginEmail"),
//                    call.argument("loginPassword"),
//                    "",
//                    "",
//                    "",
//                    geoLocation,
//                    lang,
//                    email,
//                    phone,
//                    name
//                )
//            }
//        } else {
//            if (birthDate != null && expireDate != null && documentNo != null) {
//                Amani.goToKycActivity(
//                    currentActivity,
//                    call.argument("id"),
//                    call.argument("loginEmail"),
//                    call.argument("loginPassword"),
//                    birthDate,
//                    expireDate,
//                    documentNo,
//                    geoLocation,
//                    lang,
//                    null,
//                    null,
//                    null
//                )
//            } else {
//                Amani.goToKycActivity(
//                    currentActivity,
//                    call.argument("id"),
//                    call.argument("loginEmail"),
//                    call.argument("loginPassword"),
//                    geoLocation,
//                    lang
//                )
//            }
//        }
//    }

    // Keep for ActivityAware implementation
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
}