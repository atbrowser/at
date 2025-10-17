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

// CouchDB methods
+ (NSString*)initCouchDBWithHost:(NSString*)host
                            port:(NSInteger)port
                        username:(NSString*)username
                        password:(NSString*)password {
    return [SwiftCode initCouchDBWithHost:host port:port username:username password:password];
}

+ (void)getAllDBs:(void (^)(NSString *result, NSString *error))callback {
    [SwiftCode getAllDBs:callback];
}

+ (void)createDB:(NSString*)dbName
        callback:(void (^)(NSString *result, NSString *error))callback {
    [SwiftCode createDBWithDbName:dbName callback:callback];
}

+ (void)deleteDB:(NSString*)dbName
        callback:(void (^)(NSString *result, NSString *error))callback {
    [SwiftCode deleteDBWithDbName:dbName callback:callback];
}

+ (void)insertDocument:(NSString*)dbName
          documentJson:(NSString*)documentJson
              callback:(void (^)(NSString *result, NSString *error))callback {
    [SwiftCode insertDocumentWithDbName:dbName documentJson:documentJson callback:callback];
}

+ (void)getDocument:(NSString*)dbName
              docId:(NSString*)docId
           callback:(void (^)(NSString *result, NSString *error))callback {
    [SwiftCode getDocumentWithDbName:dbName docId:docId callback:callback];
}

@end