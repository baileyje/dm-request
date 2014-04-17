#import <Foundation/Foundation.h>
#import "Resource.h"
#import "CallbackChain.h"
#import "HttpCommon.h"


typedef void (^ResponseDataCallback)(NSData * data);

@interface Response : Resource

@property (nonatomic, strong)NSHTTPURLResponse * response;

-(id)initWith:(NSHTTPURLResponse *)response;

- (Response*)data:(ResponseDataCallback)data;

- (Response*)end:(Callable)callable;

- (Response*)error:(ErrorCallback)callback;

@end