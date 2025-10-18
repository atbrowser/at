#ifndef SwiftBridge_h
#define SwiftBridge_h

#import <Foundation/Foundation.h>

@interface SwiftBridge : NSObject
+ (NSString*)helloWorld:(NSString*)input;
+ (void)nativeGui;
+ (void)triggerHapticFeedback:(NSInteger)pattern;
@end

#endif
