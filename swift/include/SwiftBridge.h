#ifndef SwiftBridge_h
#define SwiftBridge_h

#import <Foundation/Foundation.h>

@interface SwiftBridge : NSObject
+ (NSString*)helloWorld:(NSString*)input;
+ (void)helloGui;
+ (void)triggerHapticFeedback:(NSInteger)pattern;

// CouchDB methods
+ (NSString*)initCouchDBWithHost:(NSString*)host
                            port:(NSInteger)port
                        username:(NSString*)username
                        password:(NSString*)password;
+ (void)getAllDBs:(void (^)(NSString *result, NSString *error))callback;
+ (void)createDB:(NSString*)dbName
        callback:(void (^)(NSString *result, NSString *error))callback;
+ (void)deleteDB:(NSString*)dbName
        callback:(void (^)(NSString *result, NSString *error))callback;
+ (void)insertDocument:(NSString*)dbName
          documentJson:(NSString*)documentJson
              callback:(void (^)(NSString *result, NSString *error))callback;
+ (void)getDocument:(NSString*)dbName
              docId:(NSString*)docId
           callback:(void (^)(NSString *result, NSString *error))callback;
@end

#endif