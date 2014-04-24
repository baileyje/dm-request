#import <Foundation/Foundation.h>
#import "HttpCommon.h"

@class DMResource;

typedef void (^DMChainedCallback)(DMResource* resource, Callable next);

@interface DMCallbackChain : NSObject

-(id)initWith:(DMResource*)resource callbacks:(NSArray *)callbacks;

-(void)next;

-(void)done;

@end