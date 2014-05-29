#import <DMFoundation/DMBlocks.h>
#import "DMResponse.h"

@interface DMResponse ()
@property(nonatomic, strong) NSMutableArray* dataCallbacks;
@property(nonatomic, strong) NSMutableArray* endCallbacks;
@property(nonatomic, strong) NSMutableArray* errorCallbacks;
@end

@implementation DMResponse

- (id)initWith:(NSHTTPURLResponse*)response {
    if(self = [super init]) {
        self.response = response;
        self.dataCallbacks = [NSMutableArray array];
        self.endCallbacks = [NSMutableArray array];
        self.errorCallbacks = [NSMutableArray array];
    }
    return self;
}

- (DMResponse*)data:(DMResponseDataCallback)dataCallback {
    [self.dataCallbacks addObject:dataCallback];
    return self;
}

- (DMResponse*)end:(DMCallback)endCallback {
    [self.endCallbacks addObject:endCallback];
    return self;
}

- (DMResponse*)error:(DMErrorCallback)callback {
    [self.errorCallbacks addObject:callback];
    return self;
}

- (NSInteger)statusCode {
    return self.response.statusCode;
}

- (long long)expectedContentLength {
    return self.response.expectedContentLength;
}

#pragma mark - package

- (void)handle:(NSData*)data {
    for (DMResponseDataCallback callback in self.dataCallbacks) callback(data);
}

- (void)complete {
    for (DMCallback callback in self.endCallbacks) callback();
}

- (void)handleError:(NSError*)error {
    for (DMErrorCallback callback in self.errorCallbacks) callback(error);
}

@end