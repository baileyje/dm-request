#import "DMBufferingResponseCallback.h"
#import "DMResponse.h"


@implementation DMBufferingResponseCallback

+ (DMResponseCallback)with:(void (^)(DMResponse*, NSData*))callback {
    return ^(DMResponse* response, DMCallback next) {
        NSMutableData* buffer = [NSMutableData data];
        [response data:^(NSData* data) {
            [buffer appendData:data];
        }];
        __weak DMResponse* _response = response;
        [response end:^{
            callback(_response, buffer);
        }];
        next();
    };
}

@end