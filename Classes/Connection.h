#import <Foundation/Foundation.h>

@class Request;


@interface Connection : NSObject

@property(nonatomic, readonly) Request *request;

- (void)cancel;

@end