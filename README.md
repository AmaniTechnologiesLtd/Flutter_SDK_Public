# Amani Flutter SDK

This document helps you how to integrate our SDK into your Flutter project.

## Installation
Before using our sdk you must complete the changes below. Otherwise you might encounter build issues.

## Requirements
- iOS 11 or later
- Android minSDK 21 or later
- Android compileSDKVersion 33 or later
- Flutter 3.0 or later

## Android Gradle changes

On your module’s `build.gradle` file under the `android/app/build.gralde` add the changes below inside of `android` section.

```groovy
packagingOptions {
  pickFirst 'lib/x86/libc++_shared.so'
  pickFirst 'lib/x86_64/libc++_shared.so'
  pickFirst 'lib/armeabi-v7a/libc++_shared.so'
  pickFirst 'lib/arm64-v8a/libc++_shared.so'
}
dataBinding { enabled true }
```

On the same file, update your minSdkVersion to 21 or later.

```dart
defaultConfig {
        applicationId "ai.amani.flutterexample"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-build-configuration.
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

## Update your AndroidManifest.xml

You must add `tools:replace="android:label"` on your main android manifest file.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" # this line must be added
    package="ai.amani.amanisdk_example">
	<application
        android:label="amanisdk_example"
        android:name="${applicationName}"
        tools:replace="android:label" #this line must be added
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            tools:replace="android:theme" 
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
```
while here, you can also add the permissions
```xml
<uses-permission
        android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ScanNFC" />
```

## Adding Proguard Rules
You must add the rules below to proguard file

```
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class ai.amani.amanisdk.AmanisdkPlugin {*;}
-dontwarn ai.amani.amanisdk.AmanisdkPlugin

-keep class com.amani_ml** {*;}
-dontwarn com.amani.ml**
-keep class datamanager.** {*;}
-dontwarn datamanager.**
-keep class networkmanager.** {*;}
-dontwarn networkmanager.**
-keep class com.amani_ai.jniLibrary.CroppedResult { *; }

-keep class org.jmrtd.** { *; }
-keep class net.sf.scuba.** {*;}
-keep class org.bouncycastle.** {*;}
-keep class org.spongycastle.** {*;}
-keep class org.ejbca.** {*;}

-dontwarn org.ejbca.**
-dontwarn org.bouncycastle.**
-dontwarn org.spongycastle.**
-dontwarn org.jmrtd.**
-dontwarn net.sf.scuba.**

-keep class org.tensorflow.lite**{ *; }
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.support**{ *; }
-dontwarn org.tensorflow.lite.support**
```

## iOS Podfile changes

Set the global platform of your project to iOS 11.0

```ruby
platform :ios, '11.0'
```

Add the SDK’s source to your podfile.

```ruby
source "https://github.com/AmaniTechnologiesLtd/Mobile_SDK_Repo"
source "https://github.com/CocoaPods/Specs"
```

Add the section below to your post-install hook

```ruby
target.build_configurations.each do |config|
	config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
  config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
 end
```

Final result should look like this

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    # Required by amani sdk.
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

## iOS permissions

You have to add these permissions into your `info.plist` file. All permissions are required for app submission.

For NFC:

```xml
    <key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
	<array>
		<string>A0000002471001</string>
	</array>
	<key>NFCReaderUsageDescription</key>
	<string>This application requires access to NFC to  scan IDs.</string>
```

For Location:

```xml
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This application requires access to your location to upload the document.</string>
	<key>NSLocationUsageDescription</key>
	<string>This application requires access to your location to upload the document.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>This application requires access to your location to upload the document.</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>This application requires access to your location to upload the document.</string>
```

For Camera:

```xml
	<key>NSCameraUsageDescription</key>
	<string>This application requires access to your camera for scanning and uploading the document.</string>
```

**Note**: You need to add all keys according to your usage.

### **Grant access to NFC**

Enable the Near Field Communication Tag Reading capability in the target Signing & Capabilities.

### Building for devices that don’t support NFC

For the devices that don’t support NFC (like iPhone 6), there is no CoreNFC library in the system and we are also using some iOS crypto libraries for reading NFC data supported after iOS 13. You need to add libraries below as optional under the Build Phases->Link Binary With Libraries menu. Even if you don't use the NFC process, you should add this libraries below.

```
CoreNFC.framework
CryptoKit.framework
CryptoTokenKit.framework
```

## Adding the Flutter package
Add our SDK to your project’s `pubspec.yaml` file.

```yaml
amanisdk:
    git: https://github.com/AmaniTechnologiesLtd/Flutter_SDK_Public
```

After adding our SDK to your project don't forget to run the command below to install our SDK.

```bash
$ flutter pub get
```

On some rare cases, flutter pub get doesn't reinstall pods correctly. If you have build issues, cd into ios directory and run 

```bash
$ pod install
```

## Usage

```dart
import 'package:amanisdk/amanisdk.dart';
import 'package:amanisdk/sdkresult.dart'; // For SdkResult class.
```

### Calling startAmaniSDKWithToken

```dart
final _amanisdkPlugin = Amanisdk();
async {
	SdkResult result = await _amanisdkPlugin.startAmaniSDKWithToken(
								   server: "server_url supplied from us.",
                    token:
                        "customer token from the web server",
                    id: "customer id card number"
                    phone: "OPTIONAL phone number of customer",
                    email: "OPTIONAL email address of customer",
                    name: "OPTIONAL name of customer",
                    geoLocation: false, // OPTIONAL defaults to false
                    birthDate: "OPTIONAL birthdate in YYMMDD format on the ID",
                    expireDate: "OPTIONAL expireDate in YYMMDD format on the ID",
                    documentNo: "OPTIONAL document number on the ID",
		    lang: "en" // Language code in ISO 639-1
                    );
   print(result);
}
```

In the result, there will be some general variables to check both error states, if verification is completed. If the user returns from the SDK screen, rules will be filled.

**Note: You must give birthDate, expireDate, documentNo together otherwise the SDK won't start.**

# How to acquire customer token for using this SDK
1- On the server side, you need to log in with your credentials and get a token for the next steps. This token should be used only on server-side requests not used on Web SDK links.
```bash
curl --location --request POST 'https://demo.amani.ai/api/v1/user/login/' \

- -form 'email="user@account.com"' \
- -form 'password="password"'
```
2- Get or Create a customer using the request below. If there is no customer new one is created if there is a customer already created with this ID Card Number it will be returned.

This request will return a customer token that has a short life span and is valid only for this customer. Use this token to initialize Web SDK.
```
curl --location --request POST 'https://demo.amani.ai/api/v1/customer' \

- -header 'Authorization: TOKEN use_your_admin_token_here' \
- -form 'id_card_number="Customer_ID_Card_Number"'\ (Required)
- -form 'name="Customer Name"' \ (Optional)
- -form 'email="Customer Email"' \ (Optional)
- -form 'phone="Customer Phone"' (Optional)
```
