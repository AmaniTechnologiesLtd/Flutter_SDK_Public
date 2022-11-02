import 'dart:convert';

class SdkResult {
  bool isVerificationCompleted;
  bool isTokenExpired;

  /// Due to differences in our iOS SDK this field always will be *nil* on iOS.
  /// Use it with Platform Check.
  ///
  /// On Android 1000 is the default value.
  int? apiExceptionCode;

  /// This List will be filled if user canceled the KYC process,
  /// or failed the verification
  Map<String, dynamic>? rules;

  SdkResult(this.isVerificationCompleted, this.isTokenExpired,
      this.apiExceptionCode, this.rules);

  factory SdkResult.fromJson(dynamic json) {
    return SdkResult(
        json['isVerificationCompleted'] ?? false,
        json['isTokenExpired'] ?? false,
        json['apiExceptionCode'] as int?,
        json['rules']);
  }
}
