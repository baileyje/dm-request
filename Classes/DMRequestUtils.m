#import "DMRequestUtils.h"

@implementation DMRequestUtils


+ (void)notNull:(NSString*)name value:(id)value {
    if(!value) [self failNull:name];
}

+ (void)notEmpty:(NSString*)name string:(NSString*)value {
    [self notNull:name value:value];
    if([self empty:value]) [self failEmpty:name];
}

+ (void)notEmpty:(NSString*)name array:(NSArray*)value {
    [self notNull:name value:value];
    if(value.count == 0) [self failEmpty:name];
}

+ (BOOL)empty:(NSString*)value {
    return !value || value.length == 0;
}

+ (void)failNull:(NSString*)name {
    if(!name) [self failNull:@"name"];
    if([self empty:name]) [self failEmpty:@"name"];
    [NSException raise:@"Illegal Argument" format:@"The '%@' argument cannot be null.", name];
}

+ (void)failEmpty:(NSString*)name {
    if(!name) [self failNull:@"name"];
    if([self empty:name]) [self failEmpty:@"name"];
    [NSException raise:@"Illegal Argument" format:@"The '%@' argument cannot be empty.", name];
}

@end