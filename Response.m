#import "Response.h"

@interface Response ()
@property(nonatomic, strong) NSMutableArray *dataCallbacks;
@property(nonatomic, strong) NSMutableArray *endCallbacks;
@property(nonatomic, strong) NSMutableArray *errorCallbacks;
@end

@implementation Response

- (id)initWith:(NSHTTPURLResponse *)response {
    self = [super init];
    self.response = response;
    self.dataCallbacks = [NSMutableArray array];
    self.endCallbacks = [NSMutableArray array];
    self.errorCallbacks = [NSMutableArray array];
    return self;
}

- (Response *)data:(ResponseDataCallback)dataCallback {
    [self.dataCallbacks addObject:dataCallback];
    return self;
}

- (Response *)end:(Callable)endCallback {
    [self.endCallbacks addObject:endCallback];
    return self;
}

- (Response *)error:(ErrorCallback)callback {
    [self.errorCallbacks addObject:callback];
    return self;
}

- (void)handle:(NSData *)data {
    for (ResponseDataCallback callback in self.dataCallbacks) callback(data);
}

- (void)complete {
    for (Callable callback in self.endCallbacks) callback();
}

- (void)handleError:(NSError *)error {
    for (ErrorCallback callback in self.errorCallbacks) callback(error);
}

@end