#import <Foundation/Foundation.h>


@interface DMResource : NSObject

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end