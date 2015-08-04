//
//  NetworkingTests.m
//  networking
//
//  Created by Melad Barjel on 4/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APIResource.h"

@interface NetworkingTests : XCTestCase

@property (nonatomic, strong) APIResource* resource;

@end

@implementation NetworkingTests

- (void)setUp {
    [super setUp];
    _resource = [[APIResource alloc] init];
    _resource.baseUrlString = @"http://aj-staging.snepo.com/";
    _resource.apiPathString = @"api/v1/";
    _resource.collectionName = @"adventures";
    _resource.resourceName = @"adventure";
}

- (void)tearDown {
    _resource = nil;
    [super tearDown];
}

- (void)testExample {
    __block id blockData;
    
    runInMainLoop(^(BOOL *done) {
        [_resource getAllResourcesWithSuccess:^(NSDictionary *data) {
            NSLog(@"Response: %@", data);
            blockData = data;
            *done = YES;
        } failure:^(NSError *error) {
            *done = YES;
        }];
    });
    
    XCTAssertNotNil(blockData, @"");
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
        [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

@end
