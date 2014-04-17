#import <Foundation/Foundation.h>


@interface Resource : NSObject

-(NSObject *)attribute:(NSString *)name;

-(void)attribute:(NSString *)name value:(NSString *)value;

@end