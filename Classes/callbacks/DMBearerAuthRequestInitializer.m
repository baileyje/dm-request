#import "DMBearerAuthRequestInitializer.h"

@implementation DMBearerAuthRequestInitializer

+(DMRequestCallback)with:(NSString *)token {
    return ^(DMRequest*request, Callable next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
        next();
    };
}

@end