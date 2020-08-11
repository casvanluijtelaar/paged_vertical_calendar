#import "VerticalCalendarPlugin.h"
#if __has_include(<vertical_calendar/vertical_calendar-Swift.h>)
#import <vertical_calendar/vertical_calendar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vertical_calendar-Swift.h"
#endif

@implementation VerticalCalendarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVerticalCalendarPlugin registerWithRegistrar:registrar];
}
@end
