#import "VozovozAppUpdaterPlugin.h"
#if __has_include(<vozovoz_app_updater/vozovoz_app_updater-Swift.h>)
#import <vozovoz_app_updater/vozovoz_app_updater-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vozovoz_app_updater-Swift.h"
#endif

@implementation VozovozAppUpdaterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVozovozAppUpdaterPlugin registerWithRegistrar:registrar];
}
@end
