#import "AmanisdkPlugin.h"
#if __has_include(<amanisdk/amanisdk-Swift.h>)
#import <amanisdk/amanisdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "amanisdk-Swift.h"
#endif

@implementation AmanisdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmanisdkPlugin registerWithRegistrar:registrar];
}
@end
