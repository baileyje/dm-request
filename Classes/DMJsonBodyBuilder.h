#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMJsonBodyBuilder : NSObject

+(DMBodyBuilder)with:(NSObject*)object request:(DMRequest*)request;

@end