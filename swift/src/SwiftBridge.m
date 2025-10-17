#import "SwiftBridge.h"
#import "swift_addon-Swift.h"
#import <Foundation/Foundation.h>

@implementation SwiftBridge

+ (NSString*)helloWorld:(NSString*)input {
    return [SwiftCode helloWorld:input];
}

+ (void)helloGui {
    [SwiftCode helloGui];
}

+ (void)triggerHapticFeedback:(NSInteger)pattern {
    [SwiftCode triggerHapticFeedback:pattern];
}

@end
