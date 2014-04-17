#import "BasicAuthRequestInitializer.h"
#import "Base64.h"

@implementation BasicAuthRequestInitializer

+(RequestCallback)with:(NSString *)user password:(NSString *)password {
    return ^(Request *request, Callable next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", user, password] base64EncodedString]]];
        next();
    };
}

@end