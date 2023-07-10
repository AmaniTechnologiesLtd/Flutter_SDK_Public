import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:amani_flutter_sdk/sdkresult.dart';
import 'package:flutter/services.dart';
import 'amanisdk_platform_interface.dart';

class Amanisdk {
  Completer<SdkResult>? _completer;

  Amanisdk() {
    AmanisdkPlatform.instance.methodChannel
        .setMethodCallHandler(_handleInverseChannel);
  }

  /// Starts our native android or ios sdk.
  /// [server], [token], and [id] fields are required.
  ///
  /// [birthDate], [expireDate] and [documentNo] fields are grouped optionals so
  /// you must use all of them if you use one of them.
  ///
  /// Any *date* format is in **YYMMDD** format.
  ///
  /// [email], [phone], [name] fields are related to customer profile.
  ///
  ///
  Future<SdkResult> startAmaniSDKWithToken({
    required String server,
    required String token,
    required String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? lang,
    String? email,
    String? phone,
    String? name,
  }) async {
    // Adds the suffix for api endpoints.
    String serverURL = Platform.isAndroid ? '$server/api/v1/' : server;

    if (token == "") {
      throw Exception("You can't use an empty string as token");
    }

    if (!token.contains(".")) {
      throw Exception("The token must be in JWT format");
    }

    // Parse the JWT token and check if payload contains customer_id
    List<String> tokenParts = token.split('.');
    final payloadBytes = base64Decode(base64.normalize(tokenParts[1]));
    final payloadJson = jsonDecode(utf8.decode(payloadBytes));

    if (payloadJson['user_id'] == null) {
      throw Exception("You can't use admin token with this SDK.");
    }

    // Enjoy the ride.
    AmanisdkPlatform.instance.startAmaniSDKWithToken(
        serverURL,
        token,
        id,
        birthDate,
        expireDate,
        documentNo,
        geoLocation,
        lang,
        email,
        phone,
        name);

    _completer = Completer<SdkResult>();
    return _completer!.future;
  }

  Future<void> _handleInverseChannel(MethodCall call) async {
    switch (call.method) {
      case 'onSuccess':
        final result = SdkResult.fromJson(jsonDecode(call.arguments));
        _completer?.complete(result);
        break;
      case 'onError':
        _completer?.completeError(call.arguments);
    }
  }

  Future<SdkResult> startAmaniSDKWithCredentials({
    required String server,
    required String loginEmail,
    required String loginPassword,
    required String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? lang,
    String? email,
    String? phone,
    String? name,
  }) async {
    // Adds the suffix for api endpoints.
    String serverURL = Platform.isAndroid ? '$server/api/v1/' : server;

    AmanisdkPlatform.instance.startAmaniSDKWithCredentials(
        serverURL,
        loginEmail,
        loginPassword,
        id,
        birthDate,
        expireDate,
        documentNo,
        geoLocation,
        lang,
        email,
        phone,
        name);

    _completer = Completer<SdkResult>();
    return _completer!.future;
  }
}
