#import "Resource.h"

@interface Resource ()
@property(nonatomic, strong) NSMutableDictionary *attributes;
@end

@implementation Resource

- (id)init {
    self = [super init];
    self.attributes = [NSMutableDictionary dictionary];
    return self;
}

- (NSObject *)attribute:(NSString *)name {
    return self.attributes[name];
}

- (void)attribute:(NSString *)name value:(NSString *)value {
    self.attributes[name] = value;
}

@end