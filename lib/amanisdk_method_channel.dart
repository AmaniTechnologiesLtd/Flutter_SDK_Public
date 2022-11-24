import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'amanisdk_platform_interface.dart';

/// An implementation of [AmanisdkPlatform] that uses method channels.
class MethodChannelAmanisdk extends AmanisdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('amanisdk');

  @override
  Future<String?> startAmaniSDKWithToken(
    String server,
    String token,
    String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? lang,
    String? email,
    String? phone,
    String? name,
  ) async {
    // returns a json string to be converted to SdkResult class
    final resultString = await methodChannel
        .invokeMethod<String?>('startAmaniSDKWithToken', <String, dynamic>{
      'server': server,
      'token': token,
      'id': id,
      'birthDate': birthDate,
      'expireDate': expireDate,
      'documentNo': documentNo,
      'geoLocation': geoLocation,
      'lang': lang,
      'email': email,
      'phone': phone,
      'name': name,
    });
    return resultString;
  }

  @override
  Future<String?> startAmaniSDKWithCredentials(
    String server,
    String loginEmail,
    String loginPassword,
    String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? lang,
    String? email,
    String? phone,
    String? name,
  ) async {
    // returns a json string to be converted to SdkResult class
    final resultString = await methodChannel.invokeMethod<String?>(
        'startAmaniSDKWithCredentials', <String, dynamic>{
      'server': server,
      'loginEmail': loginEmail,
      'loginPassword': loginPassword,
      'id': id,
      'birthDate': birthDate,
      'expireDate': expireDate,
      'documentNo': documentNo,
      'geoLocation': geoLocation,
      'lang': lang,
      'email': email,
      'phone': phone,
      'name': name,
    });
    return resultString;
  }
}
