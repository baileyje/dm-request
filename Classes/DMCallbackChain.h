#import <Foundation/Foundation.h>
#import "DMBlocks.h"

@class DMResource;

typedef void (^DMChainedCallback)(DMResource* resource, DMCallback next);

@interface DMCallbackChain : NSObject

- (id)initWith:(DMResource*)resource callbacks:(NSArray*)callbacks;

- (void)next;

- (void)done;

@end