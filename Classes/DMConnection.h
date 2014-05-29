#import <Foundation/Foundation.h>

@class DMRequest;

@interface DMConnection : NSObject

@property(nonatomic, readonly) DMRequest* request;

- (void)cancel;

@end