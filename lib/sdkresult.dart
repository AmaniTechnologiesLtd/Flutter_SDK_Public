import 'dart:collection';
import 'dart:convert';

class SdkResult {
  bool isVerificationCompleted;
  bool isTokenExpired;

  /// Due to differences in our iOS SDK this field always will be *nil* on iOS.
  /// Use it with Platform Check.
  int? apiExceptionCode;

  /// This List will be filled if user canceled the KYC process,
  /// or failed the verification
  Map<String, dynamic>? rules;

  SdkResult(this.isVerificationCompleted, this.isTokenExpired,
      this.apiExceptionCode, this.rules);

  factory SdkResult.fromJson(dynamic json) {
    return SdkResult(
        json['isVerificationCompleted'] as bool,
        json['isTokenExpired'] as bool,
        json['apiExceptionCode'] as int?,
        jsonDecode(jsonEncode(json['rules'])) as Map<String, dynamic>?);
  }
}
