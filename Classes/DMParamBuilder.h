#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMParamBuilder : NSObject

+ (NSString*)for:(NSDictionary*)params;

+ (DMBodyBuilder)for:(NSDictionary*)params request:(DMRequest*)request;

@end