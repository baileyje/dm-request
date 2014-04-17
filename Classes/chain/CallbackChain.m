#import "CallbackChain.h"
#import "Resource.h"
#import "NSMutableArray+Queue.h"

@interface CallbackChain()
@property (nonatomic, strong) Resource* resource;
@property (nonatomic, strong) NSMutableArray* callbacks;
@end


@implementation CallbackChain

-(id)initWith:(Resource*)resource callbacks:(NSArray *)callbacks {
    self = [super init];
    self.resource = resource;
    self.callbacks = [NSMutableArray arrayWithArray:callbacks];
    return self;
}

-(void)next {
    ChainedCallback callback = [self.callbacks dequeue];
    if(!callback) {
        [self done];
    } else {
        callback(self.resource, ^{
            [self next];
        });
    }
}

-(void)done {
}

@end