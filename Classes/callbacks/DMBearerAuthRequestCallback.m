#import "DMBearerAuthRequestCallback.h"

@implementation DMBearerAuthRequestCallback

+ (DMRequestCallback)with:(NSString*)token {
    return ^(DMRequest* request, DMCallback next) {
        [request header:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
        next();
    };
}

@end