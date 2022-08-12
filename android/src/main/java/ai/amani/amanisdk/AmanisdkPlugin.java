package ai.amani.amanisdk;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

import com.amani_ai.base.Utiltiy.AppConstants;
import com.amani_ai.base.util.Amani;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;


/** AmanisdkPlugin */
public class AmanisdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity currentActivity;
  private Context currentContext;

  // Call result to use in onActivityResult
  private Result callResult;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.currentContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "amanisdk");
    channel.setMethodCallHandler(this);

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.d("AMANIFPlugin", call.method);
    if (call.method.equals("startAmaniSDKWithToken")) {
      // set the callResult, startAmaniSDK with token.
      this.callResult = result;
      this.startAmaniSDKWithToken(call);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // Gets currentActivity to pass startKYCProcess
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.currentActivity = binding.getActivity();
    binding.addActivityResultListener(new ActivityResultListener() {
      @Override
      public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if (requestCode == 101) {
          JsonObject resultMap = new JsonObject();
          resultMap.addProperty("isVerificationCompleted", Objects.requireNonNull(data).getBooleanExtra(AppConstants.ON_SUCCESS, false));
          resultMap.addProperty("isTokenExpired", Objects.requireNonNull(data).getBooleanExtra(AppConstants.TOKEN_EXPIRED, false));
          resultMap.addProperty("apiExceptionCode", Objects.requireNonNull(data).getIntExtra(AppConstants.ON_API_EXCEPTION, 1000));
          callResult.success(resultMap.toString());
          return true;
        }
        return false;
      }
    });
  }

  private void startAmaniSDKWithToken(@NonNull MethodCall call) {
    String birthDate = null;
    String expireDate = null;
    String documentNo = null;
    Boolean geoLocation = false;
    String lang = null;
    String email = null;
    String phone = null;
    String name = null;

    if (call.hasArgument("birthDate")) {
      birthDate = call.argument("birthDate");
    }
    if (call.hasArgument("expireDate")) {
      expireDate = call.argument("expireDate");
    }
    if (call.hasArgument("documentNo")) {
      documentNo = call.argument("documentNo");
    }
    if (call.hasArgument("geoLocation")) {
      geoLocation = call.argument("geoLocation");
    } else {
      geoLocation = false;
    }
    if (call.hasArgument("lang")) {
      lang = call.argument("lang");
    }
    if (call.hasArgument("email")) {
      email = call.argument("email");
    }
    if (call.hasArgument("phone")) {
      phone = call.argument("phone");
    }
    if (call.hasArgument("name")) {
      name = call.argument("name");
    }

    Amani.init(this.currentContext, call.argument("server"));

    if (email != null && phone != null && name != null) {
      Amani.goToKycActivity(this.currentActivity, call.argument("id"), call.argument("token"), birthDate, expireDate, documentNo, geoLocation, lang, email, phone, name);
    } else if (birthDate != null && expireDate != null && documentNo != null) {
      Amani.goToKycActivity(this.currentActivity, call.argument("id"), call.argument("token"), birthDate, expireDate, documentNo, lang);
    } else {
      Amani.goToKycActivity(this.currentActivity, call.argument("id"), call.argument("token"), lang);
    }
  }
  // Keep for ActivityAware implementation
  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {}

  @Override
  public void onDetachedFromActivity() {}



}
