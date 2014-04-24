#import <Foundation/Foundation.h>
#import "DMRequest.h"


@interface DMBasicAuthRequestInitializer : NSObject

+(DMRequestCallback)with:(NSString *)user password:(NSString *)password;

@end