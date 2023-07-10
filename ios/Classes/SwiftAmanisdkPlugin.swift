import Flutter
import UIKit
import AmaniUIv1
import AmaniSDK

@objc
public class SwiftAmanisdkPlugin: NSObject, FlutterPlugin {
  let nativeSDK = AmaniUIv1.sharedInstance
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
    // TODO: Make v2 back end usable
    nativeSDK.set(
      server: params["server"] as! String,
      token: params["token"] as! String,
      customer: customer!,
      useGeoLocation: useGeoLocation ?? false,
      language: params["lang"] as? String ?? "tr",
      nviModel: nvi,
      apiVersion: .v2
    ) { (customerModel, error) in
      // no-op
    }
    
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      self.nativeSDK.showSDK(on: vc!)
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
    
    //    nativeSDK.setDelegate(delegate: self)
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
                  customer: customer!) { (customer, error) in
      // no-op
    }
    
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      self.nativeSDK.showSDK(on: vc!)
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


extension SwiftAmanisdkPlugin: AmaniUIDelegate {
  public func onKYCSuccess(CustomerId: String) {
    let resultData: [String: Any] = [
      "isVerificationCompleted": true,
      "isTokenExpired": false,
    ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
    
  }
  
  public func onKYCFailed(CustomerId: String, Rules: [[String : String]]?) {
    let resultData: [String: Any] = [
      "isVerificationCompleted": false,
      "isTokenExpired": false,
      "rules": Rules as Any
    ]
    channel.invokeMethod("onSuccess", arguments: resultToJson(dictionary: resultData))
  }
  
}

