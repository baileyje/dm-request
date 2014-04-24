#import <Foundation/Foundation.h>
#import "DMRequest.h"

@interface DMBearerAuthRequestInitializer : NSObject

+(DMRequestCallback)with:(NSString *)token;

@end