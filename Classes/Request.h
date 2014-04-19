#import <Foundation/Foundation.h>
#import "Resource.h"
#import "CallbackChain.h"

typedef enum {
    HttpMethodGet, HttpMethodPost
} HttpMethod;

@class Response, Request, Connection;

typedef NSData* (^BodyBuilder)();

typedef void (^RequestCallback)(Request* request, Callable next);

typedef void (^ResponseCallback)(Response* response, Callable next);


@interface Request : Resource

+(Request*)get:(NSString *)url;

+(Request*)post:(NSString *)url;

-(Request *)body:(BodyBuilder)bodyBuilder;

-(Request *)param:(NSString *)name value:(NSString *)value;

-(Request *)header:(NSString *)name value:(NSString *)value;

-(Request *)cookie:(NSHTTPCookie*)cookie;

-(Request *)intercept:(int)status call:(ResponseCallback)callback;

-(Request *)intercept:(ResponseCallback)callback;

-(Request *)on:(int)status call:(ResponseCallback)callback;

-(Request *)success:(ResponseCallback)callback;

-(Request *)redirect:(ResponseCallback)callback;

-(Request *)error:(ResponseCallback)callback;

-(Request *)clientError:(ResponseCallback)callback;

-(Request *)serverError:(ResponseCallback)callback;

-(Request *)any:(ResponseCallback)callback;

-(Request *)auth:(RequestCallback)authenticator;

-(Connection*)fetch;

@end