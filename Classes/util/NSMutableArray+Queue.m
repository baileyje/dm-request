#import "NSMutableArray+Queue.h"


@implementation NSMutableArray (Queue)

- (id) dequeue {
    if(self.count == 0) return nil;
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

- (void) enqueue:(id)anObject {
    [self addObject:anObject];
}

@end