#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMBasicAuthRequestCallback : NSObject

+ (DMRequestCallback)with:(NSString*)user password:(NSString*)password;

@end