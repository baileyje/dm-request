#import "BufferingResponseCallback.h"
#import "Response.h"


@implementation BufferingResponseCallback

+ (ResponseCallback)with:(void (^)(Response* response, NSData *buffer))callback {
    return ^(Response *response, Callable next) {
        NSMutableData *buffer = [NSMutableData data];
        [response data:^(NSData *data) {
            [buffer appendData:data];
        }];
        __weak Response* _response = response;
        [response end:^{
            callback(_response, buffer);
        }];
        next();
    };
}

@end