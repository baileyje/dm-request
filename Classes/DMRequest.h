#import <Foundation/Foundation.h>
#import "DMResource.h"
#import "DMCallbackChain.h"

typedef enum {
    HttpMethodGet, HttpMethodPost
} HttpMethod;

@class DMResponse, DMRequest, DMConnection;

typedef NSData* (^DMBodyBuilder)();

typedef void (^DMRequestCallback)(DMRequest* request, Callable next);

typedef void (^DMResponseCallback)(DMResponse* response, Callable next);


@interface DMRequest : DMResource

+(DMRequest*)get:(NSString *)url;

+(DMRequest*)post:(NSString *)url;

-(DMRequest*)body:(DMBodyBuilder)bodyBuilder;

-(DMRequest*)param:(NSString *)name value:(NSString *)value;

-(DMRequest*)header:(NSString *)name value:(NSString *)value;

-(DMRequest*)cookie:(NSHTTPCookie*)cookie;

-(DMRequest*)intercept:(int)status call:(DMResponseCallback)callback;

-(DMRequest*)intercept:(DMResponseCallback)callback;

-(DMRequest*)on:(int)status call:(DMResponseCallback)callback;

-(DMRequest*)success:(DMResponseCallback)callback;

-(DMRequest*)redirect:(DMResponseCallback)callback;

-(DMRequest*)error:(DMResponseCallback)callback;

-(DMRequest*)clientError:(DMResponseCallback)callback;

-(DMRequest*)serverError:(DMResponseCallback)callback;

-(DMRequest*)any:(DMResponseCallback)callback;

-(DMRequest*)auth:(DMRequestCallback)authenticator;

-(DMConnection*)fetch;

@end