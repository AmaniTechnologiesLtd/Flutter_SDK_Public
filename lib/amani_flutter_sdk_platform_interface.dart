import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'amani_flutter_sdk_method_channel.dart';

abstract class AmaniFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a AmaniFlutterSdkPlatform.
  AmaniFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AmaniFlutterSdkPlatform _instance = MethodChannelAmaniFlutterSdk();

  /// The default instance of [AmaniFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAmaniFlutterSdk].
  static AmaniFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmaniFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(AmaniFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
