#import "AmanisdkPlugin.h"
#if __has_include(<amani_flutter_sdk/amani_flutter_sdk-Swift.h>)
#import <amani_flutter_sdk/amani_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "amani_flutter_sdk-Swift.h"
#endif

@implementation AmanisdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmanisdkPlugin registerWithRegistrar:registrar];
}
@end
