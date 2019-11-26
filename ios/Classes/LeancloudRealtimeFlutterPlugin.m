#import "LeancloudRealtimeFlutterPlugin.h"
#import <leancloud_realtime_flutter/leancloud_realtime_flutter-Swift.h>

@implementation LeancloudRealtimeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLeancloudRealtimeFlutterPlugin registerWithRegistrar:registrar];
}
@end
