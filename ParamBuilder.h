#import <Foundation/Foundation.h>
#import "Request.h"


@interface ParamBuilder : NSObject

+(NSString *)for:(NSDictionary *)params;

+(BodyBuilder)for:(NSDictionary *)params request:(Request *)request;

@end