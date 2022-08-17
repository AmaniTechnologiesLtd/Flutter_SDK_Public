import Flutter
import UIKit
import Amani

public class SwiftAmanisdkPlugin: NSObject, FlutterPlugin {
  var currentFlutterResult: FlutterResult?
  let nativeSDK = AmaniSDK.sharedInstance
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "amanisdk", binaryMessenger: registrar.messenger())
    let instance = SwiftAmanisdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "startAmaniSDKWithToken") {
      currentFlutterResult = result
      startAmaniSDKWithToken(call: call)
    }
  }
  
  func startAmaniSDKWithToken(call: FlutterMethodCall) {
    let params = call.arguments as! [String:Any]
    print(params)
    let customer = CustomerRequestModel(name: params["name"] as? String ?? "", email: params["email"] as? String ?? "", phone: params["phone"] as? String ?? "", idCardNumber: params["id"] as! String)
    var nvi: NviModel? = nil
    
    if let birthDate = params["birthDate"] as? String, let expireDate = params["expireDate"] as? String, let documentNo = params["documentNo"] as? String {
      nvi = NviModel(documentNo: documentNo , dateOfBirth: birthDate, dateOfExpire: expireDate)
    }
    
    nativeSDK.setDelegate(delegate: self)
    nativeSDK.set(server: params["server"] as! String, token: params["token"] as! String, customer: customer, nvi: nvi, sharedSecret: params["sharedSecret"] as? String ?? nil, useGeoLocation: params["geolocation"] as? Bool ?? false, language: params["lang"] as? String ?? "tr")
    
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      self.nativeSDK.showSDK(overParent: vc!)
    }
    
    
  }
  
  private func getTopMostController() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    var topController: UIViewController?
    if (keyWindow?.rootViewController) != nil {
      while let presentedViewController = topController?.presentedViewController {
        topController = presentedViewController
      }
    }
    
    return topController
  }
  
  private func resultToJson(dictionary: [String: Any]) -> String {
    let jsonData = try? JSONSerialization.data(withJSONObject: dictionary)
    return String(data: jsonData!, encoding: .utf8)!
  }
  
}


extension SwiftAmanisdkPlugin: AmaniSDKDelegate {
  public func onKYCSuccess(CustomerId: Int) {
    if let currentFlutterResult = currentFlutterResult {
      let resultData: [String: Any] = [
        "isVerificationCompleted": true,
        "tokenExpired": false,
      ]
      currentFlutterResult(resultToJson(dictionary: resultData))
    }
  }
  
  public func onKYCFailed(CustomerId: Int, Rules: [[String : String]]?) {
    if let currentFlutterResult = currentFlutterResult {
      let resultData: [String: Any] = [
        "isVerificationCompleted": false,
        "tokenExpired": false,
        "rules": Rules as Any
      ]
      currentFlutterResult(resultToJson(dictionary: resultData))
    }
  }
  
  public func onTokenExpired() {
    if let currentFlutterResult = currentFlutterResult {
      let resultData: [String: Any] = [
        "isVerificationCompleted": false,
        "tokenExpired": true
      ]
      currentFlutterResult(resultToJson(dictionary: resultData))
      print("token expired")
    }
  }
  
  public func onNoInternetConnection() {
    if let currentFlutterResult = currentFlutterResult {
      let resultData: [String: Any] = [
        "isVerificationCompleted": false,
        "tokenExpired": false,
      ]
      currentFlutterResult(resultToJson(dictionary: resultData))
    }
  }
  
  public func onEvent(name: String, Parameters: [String]?, type: String) {
  }
  
}
