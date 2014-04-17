#import <Foundation/Foundation.h>


@interface Utils : NSObject

+(void)notNull:(NSString *)name value:(id)object;

+(void)notEmpty:(NSString *)name string:(NSString *)string;

+(void)notEmpty:(NSString *)name array:(NSArray *)array;

@end

