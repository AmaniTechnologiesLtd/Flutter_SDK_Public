import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'amani_flutter_sdk_platform_interface.dart';

/// An implementation of [AmaniFlutterSdkPlatform] that uses method channels.
class MethodChannelAmaniFlutterSdk extends AmaniFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('amani_flutter_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
