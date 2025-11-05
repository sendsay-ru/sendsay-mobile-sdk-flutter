#import "SendsayPlugin.h"
#if __has_include(<sendsay/sendsay-Swift.h>)
#import <sendsay/sendsay-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sendsay-Swift.h"
#endif

@implementation SendsayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSendsayPlugin registerWithRegistrar:registrar];
}
@end
