//
//  NetworkingTests.m
//  networking
//
//  Created by Melad Barjel on 4/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SnepoNetworkingManager.h"
#import "APIResource.h"

@interface NetworkingTests : XCTestCase

@property (nonatomic, strong) APIResource* adventureResource;

@end

@implementation NetworkingTests

- (void)setUp {
    [super setUp];
    SnepoNetworkingManager* snepoNetworkingManager = [[SnepoNetworkingManager alloc] initWithBaseUrl:@"http://aj-staging.snepo.com/api/v1/"];
    [SnepoNetworkingManager setSharedInstance:snepoNetworkingManager];
    _adventureResource = [[APIResource alloc] init];
    _adventureResource.collectionName = @"adventures";
    _adventureResource.resourceName = @"adventure";
}

- (void)tearDown {
    _adventureResource = nil;
    [super tearDown];
}

- (void)testExample {
    
    [_adventureResource getAllResourcesWithSuccess:nil failure:nil];
    
    __block id blockData;
    
    runInMainLoop(^(BOOL *done) {
        [_adventureResource getAllResourcesWithSuccess:^(NSDictionary *data) {
            NSLog(@"Response: %@", data);
            blockData = data;
            *done = YES;
        } failure:^(NSError *error) {
            *done = YES;
        }];
    });
    
    XCTAssertNotNil(blockData, @"");
    XCTAssertEqualObjects([_adventureResource wrappedParametersForIdentifier:@(1) parameters:nil], @{@"adventure_id":@(1)});
    XCTAssertEqualObjects([_adventureResource wrappedParametersForIdentifier:nil parameters:@{@"test":@"123"}], @{@"adventure":@{@"test":@"123"}});
    XCTAssertEqualObjects([_adventureResource wrappedParametersForParameters:@{@"test":@"123"}], @{@"adventure":@{@"test":@"123"}});
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// Wrapper to test async methods: http://stackoverflow.com/questions/2162213/how-to-unit-test-asynchronous-apis
static inline void runInMainLoop(void(^block)(BOOL *done)) {
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

@end
