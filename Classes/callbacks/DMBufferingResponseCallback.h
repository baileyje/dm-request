#import <Foundation/Foundation.h>
#import "DMRequest.h"

@class DMResponse;


@interface DMBufferingResponseCallback : NSObject

+ (DMResponseCallback)with:(void (^)(DMResponse* response, NSData *buffer))callback;

@end