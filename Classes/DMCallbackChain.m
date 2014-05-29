#import "DMCallbackChain.h"
#import "DMResource.h"
#import "NSMutableArray+Queue.h"

@interface DMCallbackChain ()
@property (nonatomic, strong) DMResource* resource;
@property (nonatomic, strong) NSMutableArray* callbacks;
@end


@implementation DMCallbackChain

- (id)initWith:(DMResource*)resource callbacks:(NSArray*)callbacks {
    if(self = [super init]) {
        self.resource = resource;
        self.callbacks = [NSMutableArray arrayWithArray:callbacks];
    }
    return self;
}

- (void)next {
    DMChainedCallback callback = self.callbacks.dequeue;
    if(!callback) {
        [self done];
    } else {
        callback(self.resource, ^{
            [self next];
        });
    }
}

- (void)done {
}

@end