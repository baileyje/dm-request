#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMJsonResponseCallback : NSObject

+(DMResponseCallback)with:(void(^)(DMResponse* response, NSObject *))json;

@end