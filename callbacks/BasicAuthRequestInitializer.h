#import <Foundation/Foundation.h>
#import "Request.h"


@interface BasicAuthRequestInitializer : NSObject

+(RequestCallback)with:(NSString *)user password:(NSString *)password;

@end