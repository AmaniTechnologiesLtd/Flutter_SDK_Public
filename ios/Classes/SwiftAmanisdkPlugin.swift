import Flutter
import UIKit
import Amani

public class SwiftAmanisdkPlugin: NSObject, FlutterPlugin {
  let nativeSDK = AmaniSDK.sharedInstance
  var channel: FlutterMethodChannel!
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "amanisdk", binaryMessenger: registrar.messenger())
    let instance = SwiftAmanisdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    instance.channel = methodChannel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "startAmaniSDKWithToken") {
      startAmaniSDKWithToken(call: call)
    }
    
    if (call.method == "startAmaniSDKWithCredentials") {
      startAmaniSDKWithCredentials(call: call)
    }
  }
  
  func startAmaniSDKWithToken(call: FlutterMethodCall) {
    let useGeoLocation = (call.arguments as! [String:Any])["geoLocation"] as? Bool
    let params = call.arguments as! [String:Any]
    var customer: CustomerRequestModel?
    let name = params["name"] as? String
    let email = params["email"] as? String
    let phone = params["phone"] as? String
      
    if (name == nil && email == nil && phone == nil) {
        customer = CustomerRequestModel(idCardNumber: params["id"] as! String)
    } else {
        customer = CustomerRequestModel(name: params["name"] as? String, email: params["email"] as? String, phone: params["phone"] as? String, idCardNumber: params["id"] as! String)
    }
    var nvi: NviModel? = nil
    
    if let birthDate = params["birthDate"] as? String, let expireDate = params["expireDate"] as? String, let documentNo = params["documentNo"] as? String {
      nvi = NviModel(documentNo: documentNo , dateOfBirth: birthDate, dateOfExpire: expireDate)
    }
    
    nativeSDK.setDelegate(delegate: self)
    nativeSDK.set(
        server: params["server"] as! String,
        token: params["token"] as! String,
        customer: customer!,
        nvi: nvi,
        sharedSecret: params["sharedSecret"] as? String ?? nil,
        useGeoLocation: useGeoLocation ?? false,
        language: params["lang"] as? String ?? "tr")
    
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      self.nativeSDK.showSDK(overParent: vc!)
    }
  }
  
  func startAmaniSDKWithCredentials(call: FlutterMethodCall) {
    let useGeoLocation = (call.arguments as! [String:Any])["geoLocation"] as? Bool
    let params = call.arguments as! [String:Any]
    var customer: CustomerRequestModel?
    let name = params["name"] as? String
    let email = params["email"] as? String
    let phone = params["phone"] as? String
    let loginEmail = params["loginEmail"] as? String
    let loginPassword = params["loginPassword"] as? String
    
      
    if (name == nil && email == nil && phone == nil) {
        customer = CustomerRequestModel(idCardNumber: params["id"] as! String)
    } else {
        customer = CustomerRequestModel(name: params["name"] as? String, email: params["email"] as? String, phone: params["phone"] as? String, idCardNumber: params["id"] as! String)
    }
    var nvi: NviModel? = nil
    
    if let birthDate = params["birthDate"] as? String, let expireDate = params["expireDate"] as? String, let documentNo = params["documentNo"] as? String {
      nvi = NviModel(documentNo: documentNo , dateOfBirth: birthDate, dateOfExpire: expireDate)
    }
    
    nativeSDK.setDelegate(delegate: self)
//    nativeSDK.set(
//        server: params["server"] as! String,
//        customer: customer!,
//        nvi: nvi,
//        sharedSecret: params["sharedSecret"] as? String ?? nil,
//        useGeoLocation: useGeoLocation ?? false,
//        language: params["lang"] as? String ?? "tr")
   
    nativeSDK.set(server: params["server"] as! String,
                  userName: loginEmail!,
                  password: loginPassword!,
                  customer: customer!)
    
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
      let resultData: [String: Any] = [
        "isVerificationCompleted": true,
        "isTokenExpired": false,
      ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
  }
  
  public func onKYCFailed(CustomerId: Int, Rules: [[String : String]]?) {
    let resultData: [String: Any] = [
      "isVerificationCompleted": false,
      "isTokenExpired": false,
      "rules": Rules as Any
    ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
  }
  
  public func onTokenExpired() {
    let resultData: [String: Any] = [
      "isVerificationCompleted": false,
      "isTokenExpired": true
    ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
  }
  
  public func onNoInternetConnection() {
    let resultData: [String: Any] = [
      "isVerificationCompleted": false,
      "isTokenExpired": false,
    ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
  }
  
  public func onEvent(name: String, Parameters: [String]?, type: String) {
    // NO-OP
  }
  
}
