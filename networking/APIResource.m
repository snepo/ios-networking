//
//  APIResource.m
//  APIResource
//
//  Created by Melad Barjel on 3/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import "APIResource.h"

#import "SnepoNetworkingManager.h"

@implementation APIResource

- (void)getAllResourcesWithSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    
    NSString* pathName = [NSString stringWithFormat:@"%@%@%@",self.baseUrlString,self.apiPathString,self.collectionName];
    
    [[SnepoNetworkingManager sharedManager] get:pathName withParameters:nil withSuccess:success failure:failure];
}

- (void)getResourceWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    NSString* pathName = [NSString stringWithFormat:@"%@%@%@",self.baseUrlString,self.apiPathString,self.resourceName];
    NSLog(@"%@",pathName);
}

- (NSString *)getPathForCollection:(BOOL)collection {
    return [NSString stringWithFormat:@"%@%@%@",self.baseUrlString,self.apiPathString,collection ? self.collectionName : self.resourceName];
}

@end
