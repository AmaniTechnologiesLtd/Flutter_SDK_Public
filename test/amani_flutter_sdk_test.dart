import 'package:flutter_test/flutter_test.dart';
import 'package:amani_flutter_sdk/amani_flutter_sdk.dart';
import 'package:amani_flutter_sdk/amani_flutter_sdk_platform_interface.dart';
import 'package:amani_flutter_sdk/amani_flutter_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAmaniFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements AmaniFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AmaniFlutterSdkPlatform initialPlatform = AmaniFlutterSdkPlatform.instance;

  test('$MethodChannelAmaniFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAmaniFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    AmaniFlutterSdk amaniFlutterSdkPlugin = AmaniFlutterSdk();
    MockAmaniFlutterSdkPlatform fakePlatform = MockAmaniFlutterSdkPlatform();
    AmaniFlutterSdkPlatform.instance = fakePlatform;

    expect(await amaniFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
