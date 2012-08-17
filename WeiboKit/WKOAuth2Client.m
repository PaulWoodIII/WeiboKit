//
//  WKOAuth2Client.m
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKOAuth2Client.h"
#import "WKApplicationDefaults.h"
#import "AFJSONRequestOperation.h"
#import "AFJSONUtilities.h"
#import "WKStatus.h"
#import "WKUser.h"
#import "WKOAuthUser.h"

#ifndef kWKClientAppKey
#error
#endif

#ifndef kWKClientAppSecret
#error
#endif

#ifndef kWKClientRedirectURL
#error
#endif

NSString *const kWKAuthorizationSuccessfullNotificationName = @"kWKAuthorizationSuccessfullNotificationName";
NSString *const kWKAuthorizationFailureNotificationName = @"kWKAuthorizationFailureNotificationName";

@implementation WKOAuth2Client

#define kWKAPIURL     @"https://api.weibo.com/2"

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
    [parameters setObject:[WKOAuthUser currentUser].accessToken forKey:@"access_token"];
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
#pragma mark Weibo WebView OAuth 2.0

- (void)startAuthorization{
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&redirect_uri=%@&client_id=%@", kWKClientRedirectURL, kWKClientAppKey];
    NSLog(@"%@", urlString);
    WKAuthorizeWebView *webView = [[WKAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.weibo.com/oauth2/"]];
    [client postPath:[NSString stringWithFormat:@"access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",
                      kWKClientAppKey, kWKClientAppSecret, kWKClientRedirectURL, code]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject){
                 NSError *error = nil;
                 id responseJSON;
                 if ([responseObject length] == 0) {
                     responseJSON = nil;
                 } else {
                     responseJSON = AFJSONDecode(responseObject, &error);
                 }
                 
                 BOOL success = NO;
                 
                 if ([responseJSON isKindOfClass:[NSDictionary class]])
                 {
                     NSDictionary *dict = (NSDictionary *)responseJSON;
                     
                     NSString *token = [dict objectForKey:@"access_token"];
                     NSString *userID = [dict objectForKey:@"uid"];
                     NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
                     
                     success = token && userID;
                     if (success) {
                         WKOAuthUser *newUser = [[WKOAuthUser alloc] init];
                         newUser.user_id = userID;
                         newUser.accessToken = token;
                         newUser.expires_in = seconds;
                         [WKOAuthUser setCurrentUser:newUser];
                         [[NSNotificationCenter defaultCenter] postNotificationName:kWKAuthorizationSuccessfullNotificationName object:newUser];
                     }
                     [[NSNotificationCenter defaultCenter] postNotificationName:kWKAuthorizationFailureNotificationName object:error];
                 }
                 else{
                     [[NSNotificationCenter defaultCenter] postNotificationName:kWKAuthorizationFailureNotificationName object:nil];
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error){
                 [[NSNotificationCenter defaultCenter] postNotificationName:kWKAuthorizationFailureNotificationName object:error];
             }];
}

- (void)authorizeWebView:(WKAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    [webView hide:YES];
    
    // if not canceled
    if (![code isEqualToString:@"21330"])
    {
        [self requestAccessTokenWithAuthorizeCode:code];
    }
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
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];

    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
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
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[maxStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
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
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
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
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[maxStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
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
    if (user) {
        [parameters setObject:[user user_id] forKey:@"uid"];
    }
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
    if (user) {
        [parameters setObject:[user user_id] forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
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
    
    if (user) {
        [parameters setObject:[user user_id] forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[maxStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
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
    if (user) {
        [parameters setObject:[user user_id] forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
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
    if (user) {
        [parameters setObject:[user user_id] forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:[sinceStatus idNumber] forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[maxStatus idNumber] forKey:@"since_id"];
    }
    if (pageNum > 0) {
        [parameters setObject:[NSNumber numberWithInt:pageNum] forKey:@"page"];
        
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
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
    [parameters setObject:[WKOAuthUser currentUser].user_id forKey:@"uid"];
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
