#import "Request.h"
#import "Utils.h"
#import "Response.h"
#import "ParamBuilder.h"
#import "Connection.h"


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
@end

@interface Connection (internals)
- (id)initWith:(Request *)request;
- (void)connect:(NSURLRequest*)request;
@end

@implementation Request

+ (Request *)get:(NSString *)url {
    return [[Request alloc] initWith:url method:HttpMethodGet];
}

+ (Request *)post:(NSString *)url {
    return [[Request alloc] initWith:url method:HttpMethodPost];
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

- (Request *)on:(int)status call:(ResponseCallback)callback {
    return [self registerResponseCallback:callback status:status registry:self.responseCallbacks];
}

- (Request *)success:(ResponseCallback)callback {
    return [self on:2 call:callback];
}

- (Request *)redirect:(ResponseCallback)callback {
    return [self on:2 call:callback];
}

- (Request *)clientError:(ResponseCallback)callback {
    return [self on:4 call:callback];
}

- (Request *)serverError:(ResponseCallback)callback {
    return [self on:5 call:callback];
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

- (Connection*)fetch {
    Connection* connection = [[Connection alloc] initWith:self];
    [[[CallbackChain alloc] initWith:self callbacks:[self.requestCallbacks arrayByAddingObject:^(Request *request, Callable next) {
        [request connect:connection];
    }]] next];
    return connection;
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

#pragma mark - package private

- (void)connect:(Connection*)connection {
    BodyBuilder bodyBuilder = self.bodyBuilder;
    NSURL* url = self.url;
    if (self.params.count) {
        if (bodyBuilder || self.method == HttpMethodGet) {
            NSString *query = self.url.query;
            if (!query || query.length == 0) {
                query = [ParamBuilder for:self.params];
            } else {
                query = [query stringByAppendingFormat:@"&%@", [ParamBuilder for:self.params]];
            }
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self.url.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0], query]];
        } else {
            bodyBuilder = [ParamBuilder for:self.params request:self];
        }
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:self.method == HttpMethodPost ? @"POST" : @"GET"];
    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:name];
    }];
    if (bodyBuilder) {
        [request setHTTPBody:bodyBuilder()];
    }
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [connection connect:request];
}

- (CallbackChain *)buildResponseChain:(Response *)response {
    int status = response.response.statusCode;
    NSMutableArray *allCallbacks = [NSMutableArray array];
    [self fillResponseCallbacksFor:status from:self.responseInterceptors into:allCallbacks];
    [self fillResponseCallbacksFor:status from:self.responseCallbacks into:allCallbacks];
    CallbackChain *chain = [[CallbackChain alloc] initWith:response callbacks:allCallbacks];
    return chain;
}

#pragma mark - private

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

- (void)fillResponseCallbacksFor:(int)statusCode from:(NSDictionary *)registry into:(NSMutableArray *)into {
    for (int status = statusCode; status > 0; status /= 10) {
        NSArray *callbacks = registry[[NSNumber numberWithInt:status]];
        if (callbacks) [into addObjectsFromArray:callbacks];
    }
}

@end
