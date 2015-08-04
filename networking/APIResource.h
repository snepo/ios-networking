//
//  APIResource.h
//  APIResource
//
//  Created by Melad Barjel on 3/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIResource : NSObject

@property (nonatomic, strong) NSString* baseUrlString;
@property (nonatomic, strong) NSString* apiPathString;
@property (nonatomic, strong) NSString* collectionName;
@property (nonatomic, strong) NSString* resourceName;

- (void)getAllResourcesWithSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)getResourceWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;

- (NSString *)getPathForCollection:(BOOL)collection;

@end
