# Amani Flutter SDK

This document helps you how to integrate our SDK into your Flutter project.

## Installation

Add our SDK to your project’s `pubspec.yaml` file.

```yaml
amanisdk:
    git: https://github.com/AmaniTechnologiesLtd/Flutter_SDK_Public
```

After adding our SDK to your project don't forget to run the command below to install our SDK.

```bash
$ flutter pub get
```

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

## iOS Podfile changes

Set the global platform of your project to iOS 11.0

```ruby
platform :ios, '11.0'
```

Add the SDK’s source to your podfile.

```ruby
source "https://github.com/AmaniTechnologiesLtd/Public-IOS-SDK.git"
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
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
```

## iOS permissions

You have to add these permissions into your `info.plist` file. All permissions are required for app submission.

For NFC:

```
    <key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
	<array>
		<string>A0000002471001</string>
	</array>
	<key>NFCReaderUsageDescription</key>
	<string>This application requires access to NFC to  scan IDs.</string>
```

For Location:

```
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

```
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
                    id: "id number");
   print(result);
}
```

In the result, there will be some general variables to check both error states, if verification is completed. If the user returns from the SDK screen, rules will be filled.