#import <XCTest/XCTest.h>
#import "DMParamBuilder.h"

@interface ParamBuilderTest : XCTestCase
@end

@implementation ParamBuilderTest

- (void)testFor {
    NSDictionary* params = @{
        @"param1": @"value1",
        @"param2": @"value2",
        @"param3": @"value3",
        @"param4": @"value4"
    };
    NSString* paramString = [DMParamBuilder for:params];
    NSArray* pairs = [paramString componentsSeparatedByString:@"&"];
    NSMutableDictionary* actual = [NSMutableDictionary dictionary];
    for(NSString* pair in pairs) {
        NSArray* parts = [pair componentsSeparatedByString:@"="];
        actual[parts[0]] = parts[1];
    }
    XCTAssertEqualObjects(params, actual);
}

@end