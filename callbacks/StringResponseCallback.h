#import <Foundation/Foundation.h>
#import "Request.h"


@interface StringResponseCallback : NSObject

+ (ResponseCallback)with:(void (^)(Response* response, NSString *string))handler;

@end