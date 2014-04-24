#import "DMParamBuilder.h"

@implementation DMParamBuilder

NSString * encode(NSString * string) {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef) string,
            NULL,
            CFSTR("!*'();:@&=+$,/?%#[]\" "),
            kCFStringEncodingUTF8));
}

+(NSString *)for:(NSDictionary *)params {
    NSMutableArray * parts = [NSMutableArray arrayWithCapacity:params.allKeys.count];
    [params enumerateKeysAndObjectsUsingBlock:^(id name, id value, BOOL *stop) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", name, encode(params[name])]];
    }];
    return [parts componentsJoinedByString:@"&"];
}

+(DMBodyBuilder)for:(NSDictionary *)params request:(DMRequest*)request {
    [request header:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    return ^NSData *() {
        return [[self for:params] dataUsingEncoding:NSUTF8StringEncoding];
    };
}

@end