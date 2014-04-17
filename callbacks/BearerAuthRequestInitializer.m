#import "BearerAuthRequestInitializer.h"

@implementation BearerAuthRequestInitializer

+(RequestCallback)with:(NSString *)token {
    return ^(Request *request, Callable next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
        next();
    };
}

@end