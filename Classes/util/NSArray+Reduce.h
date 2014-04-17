
#import <Foundation/Foundation.h>
#import "HttpCommon.h"


@interface NSArray (Reduce)

-(void)reduce:(void(^)(id item, Callable next))each done:(Callable)done;

@end