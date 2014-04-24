#import "DMBasicAuthRequestInitializer.h"
#import "Base64.h"

@implementation DMBasicAuthRequestInitializer

+(DMRequestCallback)with:(NSString *)user password:(NSString *)password {
    return ^(DMRequest*request, Callable next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", user, password] base64EncodedString]]];
        next();
    };
}

@end