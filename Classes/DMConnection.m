#import "DMConnection.h"
#import "DMRequest.h"
#include "DMResponse.h"

@interface DMConnection () <NSURLConnectionDelegate>
@property(nonatomic, strong) DMRequest* request;
@property(nonatomic, strong) NSURLConnection* delegate;
@property(nonatomic, strong) DMResponse* response;
@end

@interface DMRequest (package)
- (DMCallbackChain*)buildResponseChain:(DMResponse*)response;
@end

@interface DMResponse (package)
- (void)handle:(NSData*)data;
- (void)complete;
- (void)handleError:(NSError*)error;
@end

@implementation DMConnection {
    BOOL canceled;
}

- (void)cancel {
    canceled = YES;
    if(self.delegate) {
        [self.delegate cancel];
    }
    self.delegate = nil;
}

#pragma mark - package

- (id)initWith:(DMRequest*)request {
    if(self = [super init]) {
        self.request = request;
    }
    return self;
}

- (void)connect:(NSURLRequest*)request {
    self.delegate = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.delegate scheduleInRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    [self.delegate start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)httpResponse {
    if(canceled) return;
    self.response = [[DMResponse alloc] initWith:httpResponse];
    [[self.request buildResponseChain:self.response] next];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    if(canceled) return;
    [self.response handle:data];
    self.delegate = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    if(canceled) return;
    [self.response handleError:error];
    self.delegate = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    if(canceled) return;
    [self.response complete];
    self.delegate = nil;
}

@end