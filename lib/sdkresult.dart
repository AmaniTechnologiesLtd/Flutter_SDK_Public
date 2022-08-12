class SdkResult {
  bool? isVerificationCompleted;
  bool? isTokenExpired;
  int? apiExceptionCode;
  int? customerID;
  List<dynamic>? rules;
  String? problemMessage;

  SdkResult(this.isVerificationCompleted, this.isTokenExpired,
      this.apiExceptionCode, this.customerID, this.rules, this.problemMessage);

  factory SdkResult.fromJson(dynamic json) {
    return SdkResult(
        json['isVerificationCompleted'] as bool?,
        json['isTokenExpired'] as bool?,
        json['apiExceptionCode'] as int?,
        json['customerID'] as int?,
        json['rules'] as List<dynamic>?,
        json['problemMessage'] as String?);
  }
}
