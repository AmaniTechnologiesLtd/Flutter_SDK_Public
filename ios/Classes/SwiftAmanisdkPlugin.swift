import Flutter
import UIKit
import AmaniUI
import AmaniSDK

@objc
public class SwiftAmanisdkPlugin: NSObject, FlutterPlugin {
  let nativeSDK = AmaniUI.sharedInstance
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

  // func setSSLPinning(call: FlutterMethodCall) async {
  //   let params = call.arguments as! [String:Any]
  //   let certificateURL: URL

  //  if let cerPathURL = params["certificate"] as? String {
  //   certificateURL = URL(string: cerPathURL)
  //    do {
  //     try? await nativeSDK.setSSLPinning(certificate: certificateURL)
  //    }catch(let error) {
  //     debugPrint(error)
  //     }

  //  } 
  // }

 func setSSLPinning(call: FlutterMethodCall) async {
    let params = call.arguments as! [String: Any]
    do {
        if let certificate = params["certificate"] as? String {
            guard let cerUrl = URL(string: certificate) else {
                debugPrint("can't convert to URL")
                return
            }
            debugPrint(cerUrl)
            try? await nativeSDK.setSSLPinning(certificate: cerUrl) // Burada direkt cerUrl kullanılıyor
        } else {
            debugPrint("can't find certificate")
        }
    } catch {
        debugPrint("ssl pinning setlenemedi. \(error)")
    }
}
  
  func startAmaniSDKWithToken(call: FlutterMethodCall) {
       var apiVersion: ApiVersions = .v2
      let params = call.arguments as! [String:Any]
      //todo: location eklenecek cllocation dan.
      //let test:CLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: .pi, longitude: .pi), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date(timeIntervalSinceNow: 1))
    
    
   
    var customer: CustomerRequestModel?
    let name = params["name"] as? String
    let email = params["email"] as? String
    let phone = params["phone"] as? String

    if let apiVers = params["apiVersion"] as? String, apiVers == "v1" {
      apiVersion = .v1
    } 
    
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
      language: params["lang"] as? String ?? "tr",
      nviModel: nvi,
      apiVersion: apiVersion
    )
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      self.nativeSDK.showSDK(on: vc!) { (customerModel, error) in
        // no-op
      }
    }
  }
  
  func startAmaniSDKWithCredentials(call: FlutterMethodCall) {
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
    //        language: params["lang"] as? String ?? "tr")
    
    nativeSDK.setDelegate(delegate: self)
    nativeSDK.set(
      server: params["server"] as! String,
      userName: loginEmail!,
      password: loginPassword!,
      customer: customer!,
      language: params["lang"] as? String ?? "tr",
      nviModel: nvi,
      apiVersion: .v2
    )
    
    let vc = UIApplication.shared.windows.last?.rootViewController
    DispatchQueue.main.async {
      // Fire up!
      self.nativeSDK.showSDK(on: vc!) {(customerRes, error) in
        // no-op
      }
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

  public func onError(type:String,Error:[AmaniError]){
    let resultData: [String:Any] = [
      "isVerificationCompleted": false,
      "isTokenExpired": false,
      "rules": Error as Any
    ]
    channel.invokeMethod("onError",arguments: resultToJson(dictionary:resultData))
  }

  
}

