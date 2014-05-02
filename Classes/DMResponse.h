#import <Foundation/Foundation.h>
#import "DMResource.h"
#import "DMCallbackChain.h"
#import "HttpCommon.h"


typedef void (^DMResponseDataCallback)(NSData * data);

@interface DMResponse : DMResource

@property (nonatomic, strong)NSHTTPURLResponse * response;

-(id)initWith:(NSHTTPURLResponse *)response;

- (DMResponse*)data:(DMResponseDataCallback)data;

- (DMResponse*)end:(Callable)callable;

- (DMResponse*)error:(ErrorCallback)callback;

- (int)statusCode;

- (long long int)expectedContentLength;

@end