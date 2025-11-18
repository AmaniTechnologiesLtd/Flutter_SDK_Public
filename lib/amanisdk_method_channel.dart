import 'amanisdk_platform_interface.dart';

/// An implementation of [AmanisdkPlatform] that uses method channels.
class MethodChannelAmanisdk extends AmanisdkPlatform {

  @override
  Future<void> configure({
    required String server,
    required List<String> enabledFeatures,
  }) async {
    await methodChannel.invokeMethod('configure', <String, dynamic>{
      'server': server,
      'enabledFeatures': enabledFeatures,
     
    });
  }

  @override
  Future<bool?> startAmaniSDKConfigurable(
    String token,
    String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool geoLocation,
    String? language,
    String? email,
    String? phone,
    String? name,
  ) async {
    final result = await methodChannel.invokeMethod(
      'startAmaniSDKConfigurable',
      <String, dynamic>{
        'token': token,
        'id': id,
        'birthDate': birthDate,
        'expireDate': expireDate,
        'documentNo': documentNo,
        'geoLocation': geoLocation,
        'lang': language,
        'email': email,
        'phone': phone,
        'name': name,
      },
    );
    return result;
  }


  @override
  Future<bool?> startAmaniSDKWithToken(
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
    String apiVersion,
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
      'lang': language,
      'email': email,
      'phone': phone,
      'name': name,
      'apiVersion': apiVersion,
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

  Future<void> setSSLPinning(
    String? certificate
  ) async {
     final result = await methodChannel
        .invokeMethod('SSLcertificate', <String, dynamic>{
          'certificate': certificate
        });

      return result;
  }
}
