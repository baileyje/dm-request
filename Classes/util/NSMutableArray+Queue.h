#import <Foundation/Foundation.h>


@interface NSMutableArray (Queue)

- (id)dequeue;

- (void)enqueue:(id)obj;

@end