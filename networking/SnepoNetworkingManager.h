//
//  SnepoNetworkingManager.h
//  networking
//
//  Created by Melad Barjel on 4/08/2015.
//  Copyright (c) 2015 Snepo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnepoNetworkingManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) NSString* baseUrl;

- (void)get:(NSString *)get withParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)post:(NSString *)post withParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)patch:(NSString *)patch withParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;
- (void)delete:(NSString *)delete withParameters:(NSDictionary *)parameters withSuccess:(void(^)(NSDictionary * data))success failure:(void(^)(NSError * error))failure;

@end
