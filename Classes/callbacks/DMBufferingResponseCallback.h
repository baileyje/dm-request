#import <Foundation/Foundation.h>
#import "DMRequest.h"

@class DMResponse;


@interface DMBufferingResponseCallback : NSObject

+ (DMResponseCallback)with:(void (^)(DMResponse*, NSData*))callback;

@end