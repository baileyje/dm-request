#import <Foundation/Foundation.h>
#import "Request.h"

@class Response;


@interface BufferingResponseCallback : NSObject

+ (ResponseCallback)with:(void (^)(Response* response, NSData *buffer))callback;

@end