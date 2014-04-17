#import "Request.h"
#import "Utils.h"
#import "Response.h"
#import "ParamBuilder.h"

typedef enum {
    HttpMethodGet, HttpMethodPost
} HttpMethod;

@interface ConnectionDelegate : NSObject <NSURLConnectionDelegate>

@property(nonatomic, strong) Request *request;
@property(nonatomic, strong) Response *response;

- (id)initWith:(Request *)request;

@end

@interface Request ()
@property(nonatomic, strong) NSURL *url;
@property(nonatomic) HttpMethod method;
@property(nonatomic, copy) BodyBuilder bodyBuilder;
@property(nonatomic, strong) NSMutableDictionary *params;
@property(nonatomic, strong) NSMutableDictionary *headers;
@property(nonatomic, strong) NSMutableArray* cookies;
@property(nonatomic, strong) NSMutableArray *requestCallbacks;
@property(nonatomic, strong) NSMutableDictionary *responseInterceptors;
@property(nonatomic, strong) NSMutableDictionary *responseCallbacks;
@property(nonatomic, strong) ConnectionDelegate *currentDelegate;
@end

@implementation Request

static NSMutableArray*  requests;

+(void)initialize {
    requests = [NSMutableArray array];
}

+ (Request *)get:(NSString *)url {
    return [[Request alloc] initWith:url method:HttpMethodGet];
}

+ (Request *)post:(NSString *)url {
    return [[Request alloc] initWith:url method:HttpMethodPost];
}

- (id)initWith:(NSString *)url method:(HttpMethod)method {
    self = [super init];
    self.url = [NSURL URLWithString:url];
    self.method = method;
    self.params = [NSMutableDictionary dictionary];
    self.headers = [NSMutableDictionary dictionary];
    self.cookies = [NSMutableArray array];
    self.requestCallbacks = [NSMutableArray array];
    self.responseInterceptors = [NSMutableDictionary dictionary];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    return self;
}

- (Request *)body:(BodyBuilder)bodyBuilder {
    if (self.bodyBuilder) {
        [NSException raise:@"Illegal state" format:@"Body callback already set."];
    }
    if (!self.method == HttpMethodPost) {
        [NSException raise:@"Illegal state" format:@"Http method does not support a body."];
    }
    self.bodyBuilder = bodyBuilder;
    return self;
}

- (Request *)param:(NSString *)name value:(NSString *)value {
    [Utils notEmpty:@"name" string:name];
    [Utils notEmpty:@"value" string:value];
    self.params[name] = value;
    return self;
}

- (Request*)header:(NSString *)name value:(NSString *)value {
    [Utils notEmpty:@"name" string:name];
    [Utils notEmpty:@"value" string:value];
    self.headers[name] = value;
    return self;
}

- (Request*)cookie:(NSHTTPCookie*)cookie {
    [self.cookies addObject:cookie];
    return self;
}

- (Request *)intercept:(int)status call:(ResponseCallback)callback {
    return [self registerResponseCallback:callback status:status registry:self.responseInterceptors];
}

- (Request *)intercept:(ResponseCallback)callback {
    [self intercept:2 call:callback];
    [self intercept:3 call:callback];
    [self intercept:4 call:callback];
    return [self intercept:5 call:callback];
}

- (Request *)status:(int)status call:(ResponseCallback)callback {
    return [self registerResponseCallback:callback status:status registry:self.responseCallbacks];
}

- (Request *)success:(ResponseCallback)callback {
    return [self status:2 call:callback];
}

- (Request *)redirect:(ResponseCallback)callback {
    return [self status:2 call:callback];
}

- (Request *)clientError:(ResponseCallback)callback {
    return [self status:4 call:callback];
}

- (Request *)serverError:(ResponseCallback)callback {
    return [self status:5 call:callback];
}

- (Request *)error:(ResponseCallback)callback {
    [self clientError:callback];
    return [self serverError:callback];
}

- (Request *)any:(ResponseCallback)callback {
    [self success:callback];
    [self redirect:callback];
    return [self error:callback];
}

- (Request *)auth:(RequestCallback)authenticator {
    [Utils notNull:@"authenticator" value:authenticator];
    [self.requestCallbacks addObject:authenticator];
    return self;
}

- (void)fetch {
    [[[CallbackChain alloc] initWith:self callbacks:[self.requestCallbacks arrayByAddingObject:^(Request *request, Callable next) {
        [request connect];
    }]] next];
}

- (void)connect {
    BodyBuilder bodyBuilder = self.bodyBuilder;
    if (self.params.count) {
        if (bodyBuilder || self.method == HttpMethodGet) {
            NSString *query = self.url.query;
            if (!query || query.length == 0) {
                query = [ParamBuilder for:self.params];
            } else {
                query = [query stringByAppendingFormat:@"&%@", [ParamBuilder for:self.params]];
            }
            self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self.url.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0], query]];
        } else {
            bodyBuilder = [ParamBuilder for:self.params request:self];
        }
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request setHTTPMethod:self.method == HttpMethodPost ? @"POST" : @"GET"];
    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:name];
    }];
    if (bodyBuilder) {
        [request setHTTPBody:bodyBuilder()];
    }
    [requests addObject:self];
    self.currentDelegate = [[ConnectionDelegate alloc] initWith:self];
    [NSURLConnection connectionWithRequest:request delegate:self.currentDelegate];

}

- (Request *)registerResponseCallback:(ResponseCallback)callback status:(int)status registry:(NSMutableDictionary *)registry {
    [Utils notNull:@"callback" value:callback];
    [Utils notNull:@"registry" value:registry];
    NSMutableArray *callbacks = registry[[NSNumber numberWithInt:status]];
    if (!callbacks) {
        callbacks = [NSMutableArray array];
        registry[[NSNumber numberWithInt:status]] = callbacks;
    }
    [callbacks addObject:callback];
    return self;
}

- (CallbackChain *)buildResponseChain:(Response *)response {
    int status = response.response.statusCode;
    NSMutableArray *allCallbacks = [NSMutableArray array];
    [self fillResponseCallbacksFor:status from:self.responseInterceptors into:allCallbacks];
    [self fillResponseCallbacksFor:status from:self.responseCallbacks into:allCallbacks];
    CallbackChain *chain = [[CallbackChain alloc] initWith:response callbacks:allCallbacks];
    return chain;
}

- (void)fillResponseCallbacksFor:(int)statusCode from:(NSDictionary *)registry into:(NSMutableArray *)into {
    for (int status = statusCode; status > 0; status /= 10) {
        NSArray *callbacks = registry[[NSNumber numberWithInt:status]];
        if (callbacks) [into addObjectsFromArray:callbacks];
    }
}

@end

@interface Response (hack)
- (void)handle:(NSData *)data;

- (void)complete;

- (void)handleError:(NSError *)error;
@end

@implementation ConnectionDelegate

- (id)initWith:(Request *)request {
    self = [super init];
    self.request = request;
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)httpResponse {
    self.response = [[Response alloc] initWith:httpResponse];
    [[self.request buildResponseChain:self.response] next];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.response handle:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.response handleError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.response complete];
}

@end