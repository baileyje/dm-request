#import <Foundation/Foundation.h>
#import "HttpCommon.h"

@class Resource;

typedef void (^ChainedCallback)(Resource* resource, Callable next);

@interface CallbackChain : NSObject

-(id)initWith:(Resource*)resource callbacks:(NSArray *)callbacks;

-(void)next;

-(void)done;

@end