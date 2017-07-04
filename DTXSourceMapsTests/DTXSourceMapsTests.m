//
//  DTXSourceMapsTests.m
//  DTXSourceMapsTests
//
//  Created by Leo Natan (Wix) on 03/07/2017.
//  Copyright © 2017 Leo Natan (Wix). All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DTXSourceMaps/DTXSourceMaps.h>

@interface DTXSourceMapsTests : XCTestCase

@end

@implementation DTXSourceMapsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSourceMapsInput3
{
	NSDictionary* sourceMaps = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[DTXSourceMapsTests class]] URLForResource:@"map" withExtension:@"json"]] options:0 error:NULL];
	
	DTXSourcePosition* testPosition = [DTXSourcePosition new];
	testPosition.line = @12;
	testPosition.column = @48;
	
	DTXSourceMapsParser* parser = [DTXSourceMapsParser sourceMapsParserForSourceMaps:sourceMaps];
	DTXSourcePosition* symbolicated = [parser originalPositionForPosition:testPosition];
	
	XCTAssert([symbolicated.line isEqualToNumber:@59]);
	XCTAssert([symbolicated.column isEqualToNumber:@13]);
	XCTAssert([symbolicated.sourceFileName hasSuffix:@"index.ios.js"]);
}

@end
