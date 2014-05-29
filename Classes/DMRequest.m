#import "DMRequest.h"
#import "DMRequestUtils.h"
#import "DMResponse.h"
#import "DMParamBuilder.h"
#import "DMConnection.h"
#import "DMEnum.h"
#import "NSDictionary+Iterate.h"

@class DMHttpMethod;
@protocol DMHttpMethods
+ (DMHttpMethod*)GET;
+ (DMHttpMethod*)POST;
+ (DMHttpMethod*)PUT;
+ (DMHttpMethod*)PATCH;
+ (DMHttpMethod*)DELETE;
+ (DMHttpMethod*)HEAD;
@end

@interface DMHttpMethod : DMEnum<DMHttpMethods>
- (BOOL)supportsBody;
@end

@interface DMRequest ()
@property(nonatomic, strong) NSURL*url;
@property(nonatomic) DMHttpMethod* method;
@property(nonatomic, copy) DMBodyBuilder bodyBuilder;
@property(nonatomic, strong) NSMutableDictionary*params;
@property(nonatomic, strong) NSMutableDictionary*headers;
@property(nonatomic, strong) NSMutableArray* cookies;
@property(nonatomic, strong) NSMutableArray*requestCallbacks;
@property(nonatomic, strong) NSMutableDictionary*responseInterceptors;
@property(nonatomic, strong) NSMutableDictionary*responseCallbacks;
@end

@interface DMConnection (internals)
- (id)initWith:(DMRequest*)request;
- (void)connect:(NSURLRequest*)request;
@end

@implementation DMRequest

+ (DMRequest*)requestWithUrl:(NSString*)url method:(DMHttpMethod*)method {
    return [[DMRequest alloc] initWith:url method:method];
}

+ (DMRequest*)get:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.GET];
}

+ (DMRequest*)post:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.POST];
}

+ (DMRequest*)put:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.PUT];
}

+ (DMRequest*)patch:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.PATCH];
}

+ (DMRequest*)delete:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.DELETE];
}

+ (DMRequest*)head:(NSString*)url {
    return [self requestWithUrl:url method:DMHttpMethod.HEAD];
}

- (DMRequest*)body:(DMBodyBuilder)bodyBuilder {
    if (self.bodyBuilder) {
        [NSException raise:@"Illegal state" format:@"Body callback already set."];
    }
    if (!self.method.supportsBody) {
        [NSException raise:@"Illegal state" format:@"Http method does not support a body."];
    }
    self.bodyBuilder = bodyBuilder;
    return self;
}

- (DMRequest*)param:(NSString*)name value:(NSString*)value {
    [DMRequestUtils notEmpty:@"name" string:name];
    [DMRequestUtils notEmpty:@"value" string:value];
    self.params[name] = value;
    return self;
}

- (DMRequest*)header:(NSString*)name value:(NSString*)value {
    [DMRequestUtils notEmpty:@"name" string:name];
    [DMRequestUtils notEmpty:@"value" string:value];
    self.headers[name] = value;
    return self;
}

- (DMRequest*)cookie:(NSHTTPCookie*)cookie {
    [self.cookies addObject:cookie];
    return self;
}

- (DMRequest*)intercept:(NSUInteger)status call:(DMResponseCallback)callback {
    return [self registerResponseCallback:callback status:status registry:self.responseInterceptors];
}

- (DMRequest*)intercept:(DMResponseCallback)callback {
    [self intercept:2 call:callback];
    [self intercept:3 call:callback];
    [self intercept:4 call:callback];
    return [self intercept:5 call:callback];
}

- (DMRequest*)on:(NSUInteger)status call:(DMResponseCallback)callback {
    return [self registerResponseCallback:callback status:status registry:self.responseCallbacks];
}

- (DMRequest*)success:(DMResponseCallback)callback {
    return [self on:2 call:callback];
}

- (DMRequest*)redirect:(DMResponseCallback)callback {
    return [self on:3 call:callback];
}

- (DMRequest*)clientError:(DMResponseCallback)callback {
    return [self on:4 call:callback];
}

- (DMRequest*)serverError:(DMResponseCallback)callback {
    return [self on:5 call:callback];
}

- (DMRequest*)error:(DMResponseCallback)callback {
    [self clientError:callback];
    return [self serverError:callback];
}

- (DMRequest*)any:(DMResponseCallback)callback {
    [self success:callback];
    [self redirect:callback];
    return [self error:callback];
}

- (DMRequest*)auth:(DMRequestCallback)authenticator {
    [DMRequestUtils notNull:@"authenticator" value:authenticator];
    [self.requestCallbacks addObject:authenticator];
    return self;
}

- (DMConnection*)fetch {
    DMConnection* connection = [[DMConnection alloc] initWith:self];
    [[[DMCallbackChain alloc] initWith:self callbacks:[self.requestCallbacks arrayByAddingObject:^(DMRequest*request, DMCallback next) {
        [request connect:connection];
    }]] next];
    return connection;
}

- (id)initWith:(NSString*)url method:(DMHttpMethod*)method {
    if(self = [super init]) {
        self.url = [NSURL URLWithString:url];
        self.method = method;
        self.params = [NSMutableDictionary dictionary];
        self.headers = [NSMutableDictionary dictionary];
        self.cookies = [NSMutableArray array];
        self.requestCallbacks = [NSMutableArray array];
        self.responseInterceptors = [NSMutableDictionary dictionary];
        self.responseCallbacks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - package private

- (void)connect:(DMConnection*)connection {
    DMBodyBuilder bodyBuilder = self.bodyBuilder;
    NSURL* url = self.url;
    if (self.params.count) {
        if (bodyBuilder || self.method == DMHttpMethod.GET) {
            NSString* query = self.url.query;
            if (!query || query.length == 0) {
                query = [DMParamBuilder for:self.params];
            } else {
                query = [query stringByAppendingFormat:@"&%@", [DMParamBuilder for:self.params]];
            }
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self.url.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0], query]];
        } else {
            bodyBuilder = [DMParamBuilder for:self.params request:self];
        }
    }
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:self.method.name];
    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    [headers each:^(NSString* name, NSString* value) {
        [request addValue:value forHTTPHeaderField:name];
    }];
    if (bodyBuilder) {
        [request setHTTPBody:bodyBuilder()];
    }
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [connection connect:request];
}

- (DMCallbackChain*)buildResponseChain:(DMResponse*)response {
    NSInteger status = response.statusCode;
    NSMutableArray* allCallbacks = [NSMutableArray array];
    [self fillResponseCallbacksFor:status from:self.responseInterceptors into:allCallbacks];
    [self fillResponseCallbacksFor:status from:self.responseCallbacks into:allCallbacks];
    DMCallbackChain*chain = [[DMCallbackChain alloc] initWith:response callbacks:allCallbacks];
    return chain;
}

#pragma mark - private

- (DMRequest*)registerResponseCallback:(DMResponseCallback)callback status:(NSUInteger)status registry:(NSMutableDictionary*)registry {
    [DMRequestUtils notNull:@"callback" value:callback];
    [DMRequestUtils notNull:@"registry" value:registry];
    NSMutableArray* callbacks = registry[[NSNumber numberWithUnsignedInteger:status]];
    if (!callbacks) {
        callbacks = [NSMutableArray array];
        registry[[NSNumber numberWithUnsignedInteger:status]] = callbacks;
    }
    [callbacks addObject:callback];
    return self;
}

- (void)fillResponseCallbacksFor:(NSUInteger)statusCode from:(NSDictionary*)registry into:(NSMutableArray*)into {
    for (NSUInteger status = statusCode; status > 0; status /= 10) {
        NSArray* callbacks = registry[[NSNumber numberWithUnsignedInteger:status]];
        if (callbacks) [into addObjectsFromArray:callbacks];
    }
}

@end

@implementation DMHttpMethod

+ (NSString*)nameFor:(NSString*)label {
    return label;
}

- (BOOL)supportsBody {
    return !(self == DMHttpMethod.GET || self == DMHttpMethod.HEAD);
}

@end
