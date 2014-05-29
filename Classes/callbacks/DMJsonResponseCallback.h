#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMJsonResponseCallback : NSObject

+ (DMResponseCallback)with:(void(^)(DMResponse*, NSObject*))callback;

@end