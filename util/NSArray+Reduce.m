#import "NSArray+Reduce.h"

@implementation NSArray (Reduce)

-(void)reduce:(void(^)(id item, Callable next))each done:(Callable)done {
    if(self.count == 0) return done();
    id head = [self objectAtIndex:0];
    each(head, ^{
        NSArray * tail = [self subarrayWithRange:NSMakeRange(1, self.count - 1)];
        [tail reduce:each done:done];
    });
}

@end