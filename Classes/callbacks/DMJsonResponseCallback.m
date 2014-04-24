#import "DMJsonResponseCallback.h"
#import "DMBufferingResponseCallback.h"

@implementation DMJsonResponseCallback

+(DMResponseCallback)with:(void(^)(DMResponse* response, NSObject *))callback {
    return [DMBufferingResponseCallback with:^(DMResponse* response, NSData* data) {
        NSError* error;
        callback(response, [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]);
    }];
}

@end