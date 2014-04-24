#import "DMStringResponseCallback.h"
#import "DMResponse.h"
#import "DMBufferingResponseCallback.h"


@implementation DMStringResponseCallback

+(DMResponseCallback)with:(void(^)(DMResponse* response, NSString* string))callback {
    return [DMBufferingResponseCallback with:^(DMResponse* response, NSData* data) {
        callback(response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}

@end