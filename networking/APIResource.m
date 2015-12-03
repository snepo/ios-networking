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

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [SnepoNetworkingManager sharedManager];
    }
    return self;
}

- (void)getAllResourcesWithSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    [_manager get:_collectionName withParameters:nil withSuccess:success failure:failure];
}

- (void)getResourcesWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    [_manager get:_collectionName withParameters:parameters withSuccess:success failure:failure];
}

- (void)getResourceWithIdentifier:(id)identifier withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    NSString* key = [NSString stringWithFormat:@"%@_id",_resourceName];
    NSDictionary* parameters = @{key:identifier};
    if ([_delegate respondsToSelector:@selector(resource:keyForId:)]) {
        parameters = [_delegate resource:self keyForId:identifier];
    }
    [_manager get:_resourceName withParameters:parameters withSuccess:success failure:failure];
}

- (void)createResourceWithParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    NSDictionary* formattedParameters = @{_resourceName:parameters};
    if ([_delegate respondsToSelector:@selector(resource:formatParameters:)]) {
        formattedParameters = [_delegate resource:self formatParameters:parameters];
    }
    [_manager post:_resourceName withParameters:formattedParameters withSuccess:success failure:failure];
}

- (void)updateResourceWithIdentifier:(id)identifier parameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    NSString* key = [NSString stringWithFormat:@"%@_id",_resourceName];
    NSDictionary* wrappedParameters = @{key:identifier,_resourceName:parameters};
    [_manager patch:_resourceName withParameters:wrappedParameters withSuccess:success failure:failure];
}

- (void)deleteResourceWithIdentifier:(id)identifier withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure {
    NSString* key = [NSString stringWithFormat:@"%@_id",_resourceName];
    NSDictionary* parameters = @{key:identifier};
    [_manager delete:_resourceName withParameters:parameters withSuccess:success failure:failure];
}

- (NSDictionary *)wrappedParametersForParameters:(NSDictionary *)parameters {
    return [self wrappedParametersForIdentifier:nil parameters:parameters];
}

- (NSDictionary *)wrappedParametersForIdentifier:(id)identifer parameters:(NSDictionary *)parameters {
    NSMutableDictionary* p = NSMutableDictionary.new;
    if (identifer) {
        NSString* key = [NSString stringWithFormat:@"%@_id",_resourceName];
        [p setObject:identifer forKey:key];
    }
    if (parameters) {
        [p setObject:parameters forKey:_resourceName];
    }
    return [p copy];
}

@end
