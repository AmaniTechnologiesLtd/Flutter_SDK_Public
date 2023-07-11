import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'amanisdk_method_channel.dart';

abstract class AmanisdkPlatform extends PlatformInterface {
  /// Constructs a AmanisdkPlatform.
  AmanisdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AmanisdkPlatform _instance = MethodChannelAmanisdk();

  /// The default instance of [AmanisdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAmanisdk].
  static AmanisdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmanisdkPlatform] when
  /// they register themselves.
  static set instance(AmanisdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  final methodChannel = const MethodChannel('amanisdk');

  Future<void> startAmaniSDKWithToken(
    String server,
    String token,
    String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? language,
    String? email,
    String? phone,
    String? name,
  ) {
    throw UnimplementedError(
        'startAmaniSDKWithToken() has not been implemented.');
  }

  Future<void> startAmaniSDKWithCredentials(
    String server,
    String loginEmail,
    String loginPassword,
    String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? language,
    String? email,
    String? phone,
    String? name,
  ) {
    throw UnimplementedError(
        'startAmaniSDKWithCredentials() has not been implemented.');
  }
}
