#import <Foundation/Foundation.h>
#import "Request.h"


@interface JsonResponseCallback : NSObject

+(ResponseCallback)with:(void(^)(Response* response, NSObject *))json;

@end