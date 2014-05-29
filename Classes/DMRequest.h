#import <Foundation/Foundation.h>
#import "DMResource.h"
#import "DMCallbackChain.h"
#import "DMBlocks.h"


@class DMResponse, DMRequest, DMConnection;

typedef NSData* (^DMBodyBuilder)();

typedef void (^DMRequestCallback)(DMRequest* request, DMCallback next);

typedef void (^DMResponseCallback)(DMResponse* response, DMCallback next);


@interface DMRequest : DMResource

+ (DMRequest*)get:(NSString*)url;

+ (DMRequest*)post:(NSString*)url;

+ (DMRequest*)put:(NSString*)url;

+ (DMRequest*)patch:(NSString*)url;

+ (DMRequest*)delete:(NSString*)url;

+ (DMRequest*)head:(NSString*)url;

- (DMRequest*)body:(DMBodyBuilder)bodyBuilder;

- (DMRequest*)param:(NSString*)name value:(NSString*)value;

- (DMRequest*)header:(NSString*)name value:(NSString*)value;

- (DMRequest*)cookie:(NSHTTPCookie*)cookie;

- (DMRequest*)intercept:(NSUInteger)status call:(DMResponseCallback)callback;

- (DMRequest*)intercept:(DMResponseCallback)callback;

- (DMRequest*)on:(NSUInteger)status call:(DMResponseCallback)callback;

- (DMRequest*)success:(DMResponseCallback)callback;

- (DMRequest*)redirect:(DMResponseCallback)callback;

- (DMRequest*)error:(DMResponseCallback)callback;

- (DMRequest*)clientError:(DMResponseCallback)callback;

- (DMRequest*)serverError:(DMResponseCallback)callback;

- (DMRequest*)any:(DMResponseCallback)callback;

- (DMRequest*)auth:(DMRequestCallback)authenticator;

- (DMConnection*)fetch;

@end