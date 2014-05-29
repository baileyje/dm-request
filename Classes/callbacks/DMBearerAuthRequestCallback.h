#import <Foundation/Foundation.h>
#import "DMRequest.h"

@interface DMBearerAuthRequestCallback : NSObject

+ (DMRequestCallback)with:(NSString*)token;

@end