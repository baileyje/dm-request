#import "DMBasicAuthRequestCallback.h"
#import "NSData+Encode.h"

@implementation DMBasicAuthRequestCallback

+ (DMRequestCallback)with:(NSString*)user password:(NSString*)password {
    return ^(DMRequest* request, DMCallback next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", user, password] dataUsingEncoding:NSUTF8StringEncoding].b64]];
        next();
    };
}

@end