#import "DMJsonBodyBuilder.h"


@implementation DMJsonBodyBuilder

+(DMBodyBuilder)with:(NSObject*)object request:(DMRequest*)request {
    [request header:@"Content-Type" value:@"application/json"];
    return ^NSData* {
        NSError* error;
        return [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    };
}

@end