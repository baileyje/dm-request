#import "JsonBodyBuilder.h"


@implementation JsonBodyBuilder

+(BodyBuilder)with:(NSObject *)object request:(Request *)request {
    [request header:@"Content-Type" value:@"application/json"];
    return ^NSData *() {
        NSError * error;
        return [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    };
}

@end