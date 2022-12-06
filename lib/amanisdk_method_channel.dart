import 'package:flutter/services.dart';

import 'amanisdk_platform_interface.dart';

/// An implementation of [AmanisdkPlatform] that uses method channels.
class MethodChannelAmanisdk extends AmanisdkPlatform {
  @override
  Future<bool?> startAmaniSDKWithToken(
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
    final result = await methodChannel
        .invokeMethod('startAmaniSDKWithToken', <String, dynamic>{
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
    return result;
  }

  @override
  Future<bool?> startAmaniSDKWithCredentials(
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
    final result = await methodChannel
        .invokeMethod('startAmaniSDKWithCredentials', <String, dynamic>{
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
    return result;
  }
}
