//
//  WKOAuth2Client.m
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKOAuth2Client.h"
#import "AFJSONRequestOperation.h"
#import "WKStatus.h"
#import "WKUser.h"

@implementation WKOAuth2Client

#define kWKAPIURL     @"https://api.weibo.com/oauth2"

+ (id)sharedInstance {
    static WKOAuth2Client *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[WKOAuth2Client alloc] initWithBaseURL:
                            [NSURL URLWithString:kWKAPIURL]];
    });
    
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

- (NSMutableDictionary *)defaultGetParameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.oauthToken forKey:@"access_token"];
    return parameters;
}

- (void)getHomeTimelineWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSArray *JSONStatuses = [responseObject objectForKey:@"statuses"];
                                         
                                         NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:[JSONStatuses count]];
                                         for (NSDictionary *taskDictionary in JSONStatuses) {
                                             WKStatus *status = [WKStatus objectWithDictionary:taskDictionary];
                                             [statuses addObject:status];
                                         }
                                         
                                         if (success) {
                                             success(statuses);
                                         }
                                         
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getUserDetailsWithSuccess:(void (^)(WKUser *user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:self.uid forKey:@"uid"];
    [[WKOAuth2Client sharedInstance] getPath:@"users/show.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
        WKUser *user = [WKUser objectWithDictionary:(NSDictionary *)responseObject];
        if (success) {
            success(user);
        }
    }
     failure:^(AFHTTPRequestOperation *operation, NSError *error){
         if (failure) {
             failure(operation, error);
         }
     }];
}

@end
