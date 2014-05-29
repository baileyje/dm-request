#import "DMResource.h"

@interface DMResource ()
@property(nonatomic, strong) NSMutableDictionary* attributes;
@end

@implementation DMResource

- (id)init {
    if(self = [super init]) {
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    return self.attributes[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    self.attributes[key] = obj;
}

@end