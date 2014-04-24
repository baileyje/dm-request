#import <Foundation/Foundation.h>


@interface DMResource : NSObject

-(NSObject *)attribute:(NSString *)name;

-(void)attribute:(NSString *)name value:(NSString *)value;

@end