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

- (NSMutableArray *)statusArrayWithResponse:(id)response{
    if (![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *JSONStatuses = [response objectForKey:@"statuses"];
    
    NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:[JSONStatuses count]];
    for (NSDictionary *taskDictionary in JSONStatuses) {
        WKStatus *status = [WKStatus objectWithDictionary:taskDictionary];
        [statuses addObject:status];
    }
    return statuses;
}

#pragma mark -
#pragma mark Weibo API

#pragma mark Home Time Line

// statuses/home_timeline
// Return the authenticating user’s and his friends’ latest weibos

- (void)getHomeTimelineWithSuccess:(void (^)(NSMutableArray *statuses))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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


- (void)getHomeTimelineSinceStatus:(WKStatus *)sinceStatus
                    startingAtPage:(int)pageNum
                             count:(int)count
                       withSuccess:(void (^)(NSMutableArray *statuses))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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
- (void)getHomeTimelineSinceStatus:(WKStatus *)sinceStatus
                 withMaximumStatus:(WKStatus *)maxStatus
                    startingAtPage:(int)pageNum
                             count:(int)count
                       withSuccess:(void (^)(NSMutableArray *statuses))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[sinceStatus idString] forKey:@"since_id"];
    [parameters setObject:[maxStatus idString] forKey:@"max_id"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

#pragma mark Friends Time Line

// statuses/friends_timeline
// Return the authenticating user’s and his friends’ latest weibos

- (void)getFriendsTimelineWithSuccess:(void (^)(NSMutableArray *statuses))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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


- (void)getFriendsTimelineSinceStatus:(WKStatus *)sinceStatus
                       startingAtPage:(int)pageNum
                                count:(int)count
                          withSuccess:(void (^)(NSMutableArray *statuses))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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
- (void)getFriendsTimelineSinceStatus:(WKStatus *)sinceStatus
                    withMaximumStatus:(WKStatus *)maxStatus
                       startingAtPage:(int)pageNum
                                count:(int)count
                          withSuccess:(void (^)(NSMutableArray *statuses))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[sinceStatus idString] forKey:@"since_id"];
    [parameters setObject:[maxStatus idString] forKey:@"max_id"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

#pragma mark User Time Line

// statuses/user_timeline
// Return the latest weibos of one user

- (void)getUserTimeline:(WKUser *)user
            withSuccess:(void (^)(NSMutableArray *statuses))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

- (void)getUserTimeline:(WKUser *)user
            sinceStatus:(WKStatus *)sinceStatus
         startingAtPage:(int)pageNum
                  count:(int)count
            withSuccess:(void (^)(NSMutableArray *statuses))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

- (void)getUserTimeline:(WKUser *)user
            sinceStatus:(WKStatus *)sinceStatus
      withMaximumStatus:(WKStatus *)maxStatus
         startingAtPage:(int)pageNum
                  count:(int)count
            withSuccess:(void (^)(NSMutableArray *statuses))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [parameters setObject:[sinceStatus idString] forKey:@"since_id"];
    [parameters setObject:[maxStatus idString] forKey:@"max_id"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

#pragma mark Bilateral Time Line

// statuses/bilateral_timeline
// Return the latest weibos of the users that are following the authenticating user and are being

- (void)getBilateralTimeline:(WKUser *)user
                 withSuccess:(void (^)(NSMutableArray *statuses))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

- (void)getBilateralTimeline:(WKUser *)user
                 sinceStatus:(WKStatus *)sinceStatus
              startingAtPage:(int)pageNum
                       count:(int)count
                 withSuccess:(void (^)(NSMutableArray *statuses))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

- (void)getBilateralTimeline:(WKUser *)user
                 sinceStatus:(WKStatus *)sinceStatus
           withMaximumStatus:(WKStatus *)maxStatus
              startingAtPage:(int)pageNum
                       count:(int)count
                 withSuccess:(void (^)(NSMutableArray *statuses))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[user user_id] forKey:@"uid"];
    [parameters setObject:[sinceStatus idString] forKey:@"since_id"];
    [parameters setObject:[maxStatus idString] forKey:@"max_id"];
    [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         NSMutableArray *statuses = [self statusArrayWithResponse:responseObject];
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

#pragma mark Repost Time Line

// statuses/repost_timeline
// Return the latest of repost weibos of a original weibo

- (void)getRepostForStatus:(WKStatus *)users
               withSuccess:(void (^)(NSMutableArray *statuses))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

- (void)getRepostForStatus:(WKStatus *)users
               sinceStatus:(WKStatus *)sinceStatus
            startingAtPage:(int)pageNum
                     count:(int)count
               withSuccess:(void (^)(NSMutableArray *statuses))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

- (void)getRepostForStatus:(WKStatus *)users
               sinceStatus:(WKStatus *)sinceStatus
         withMaximumStatus:(WKStatus *)maxStatus
            startingAtPage:(int)pageNum
                     count:(int)count
               withSuccess:(void (^)(NSMutableArray *statuses))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

#pragma mark Mentions

// statuses/mentions.json
// Return the latest weibos metioned the authenticating user

- (void)getMentionsWithSuccess:(void (^)(NSMutableArray *statuses))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

- (void)getMentionsForStatus:(WKStatus *)users
                 sinceStatus:(WKStatus *)sinceStatus
              startingAtPage:(int)pageNum
                       count:(int)count
                 withSuccess:(void (^)(NSMutableArray *statuses))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

- (void)getMentionsForStatus:(WKStatus *)users
                 sinceStatus:(WKStatus *)sinceStatus
           withMaximumStatus:(WKStatus *)maxStatus
              startingAtPage:(int)pageNum
                       count:(int)count
                 withSuccess:(void (^)(NSMutableArray *statuses))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
}

#pragma mark -
#pragma mark Users API

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
