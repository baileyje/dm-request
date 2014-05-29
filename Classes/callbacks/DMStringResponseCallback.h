#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMStringResponseCallback : NSObject

+ (DMResponseCallback)with:(void (^)(DMResponse*, NSString*))handler;

@end