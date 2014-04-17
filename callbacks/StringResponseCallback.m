#import "StringResponseCallback.h"
#import "Response.h"
#import "BufferingResponseCallback.h"


@implementation StringResponseCallback

+(ResponseCallback)with:(void(^)(Response* response, NSString* string))callback {
    return [BufferingResponseCallback with:^(Response* response, NSData *data) {
        callback(response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}

@end