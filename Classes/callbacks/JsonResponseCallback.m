#import "JsonResponseCallback.h"
#import "BufferingResponseCallback.h"

@implementation JsonResponseCallback

+(ResponseCallback)with:(void(^)(Response* response, NSObject *))callback {
    return [BufferingResponseCallback with:^(Response* response, NSData *data) {
        NSError *error;
        callback(response, [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]);
    }];
}

@end