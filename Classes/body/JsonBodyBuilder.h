#import <Foundation/Foundation.h>
#import "Request.h"


@interface JsonBodyBuilder : NSObject

+(BodyBuilder)with:(NSObject *)object request:(Request *)request;

@end