//
//  APIResource.h
//  APIResource
//
//  Created by Melad Barjel on 3/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APIResource;
@class SnepoNetworkingManager;

@protocol APIResourceDelegate <NSObject>

@optional

- (NSDictionary *)resource:(APIResource *)resource keyForId:(NSNumber *)uid;
- (NSDictionary *)resource:(APIResource *)resource formatParameters:(NSDictionary *)parameters;

@end

@interface APIResource : NSObject

@property (nonatomic, weak) id<APIResourceDelegate> delegate;

@property (nonatomic, strong) NSString* collectionName;
@property (nonatomic, strong) NSString* resourceName;
@property (nonatomic, strong) SnepoNetworkingManager* manager;

- (void)getAllResourcesWithSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)getResourcesWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)getResourceWithIdentifier:(id)identifier withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)createResourceWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)updateResourceWithIdentifier:(id)identifier parameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)deleteResourceWithIdentifier:(id)identifier withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;

- (NSDictionary *)wrappedParametersForParameters:(NSDictionary *)parameters;
- (NSDictionary *)wrappedParametersForIdentifier:(id)identifer parameters:(NSDictionary *)parameters;

@end
