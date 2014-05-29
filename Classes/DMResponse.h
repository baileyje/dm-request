#import <Foundation/Foundation.h>
#import "DMResource.h"
#import "DMCallbackChain.h"


typedef void (^DMResponseDataCallback)(NSData* data);

@interface DMResponse : DMResource

@property (nonatomic, strong)NSHTTPURLResponse* response;

- (id)initWith:(NSHTTPURLResponse*)response;

- (DMResponse*)data:(DMResponseDataCallback)data;

- (DMResponse*)end:(DMCallback)callable;

- (DMResponse*)error:(DMErrorCallback)callback;

- (NSInteger)statusCode;

- (long long)expectedContentLength;

@end