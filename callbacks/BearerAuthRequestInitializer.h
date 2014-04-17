#import <Foundation/Foundation.h>
#import "Request.h"

@interface BearerAuthRequestInitializer : NSObject

+(RequestCallback)with:(NSString *)token;

@end