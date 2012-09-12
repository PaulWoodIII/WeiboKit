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
#import "WKList.h"
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
                     NSNumber *userID = [dict objectForKey:@"uid"];
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

- (void)getHomeTimelineWithSuccess:(void (^)(WKList *list))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:[NSNumber numberWithInt:5] forKey:@"count"];
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}


- (void)getHomeTimelineSinceStatus:(NSNumber *)sinceStatus
                             count:(int)count
                       withSuccess:(void (^)(WKList *list))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getHomeTimelineSinceStatus:(NSNumber *)sinceStatus
                 withMaximumStatus:(NSNumber *)maxStatus
                             count:(int)count
                       withSuccess:(void (^)(WKList *list))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[NSNumber numberWithLongLong:[maxStatus longLongValue] - 1] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/home_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
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

- (void)getFriendsTimelineWithSuccess:(void (^)(WKList *list))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}


- (void)getFriendsTimelineSinceStatus:(NSNumber *)sinceStatus
                                count:(int)count
                          withSuccess:(void (^)(WKList *list))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
    
}
- (void)getFriendsTimelineSinceStatus:(NSNumber *)sinceStatus
                    withMaximumStatus:(NSNumber *)maxStatus
                                count:(int)count
                          withSuccess:(void (^)(WKList *list))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[NSNumber numberWithLongLong:[maxStatus longLongValue] - 1] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/friends_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
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

- (void)getUserTimeline:(NSNumber *)user
            withSuccess:(void (^)(WKList *list))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (user) {
        [parameters setObject:user forKey:@"uid"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getUserTimeline:(NSNumber *)user
            sinceStatus:(NSNumber *)sinceStatus
                  count:(int)count
            withSuccess:(void (^)(WKList *list))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (user) {
        [parameters setObject:user forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getUserTimeline:(NSNumber *)user
            sinceStatus:(NSNumber *)sinceStatus
      withMaximumStatus:(NSNumber *)maxStatus
                  count:(int)count
            withSuccess:(void (^)(WKList *list))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    
    if (user) {
        [parameters setObject:user forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[NSNumber numberWithLongLong:[maxStatus longLongValue] - 1] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
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

- (void)getBilateralTimeline:(NSNumber *)user_id
                 withSuccess:(void (^)(WKList *list))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setObject:user_id forKey:@"uid"];
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getBilateralTimeline:(NSNumber *)user_id
                 sinceStatus:(NSNumber *)sinceStatus
                       count:(int)count
                 withSuccess:(void (^)(WKList *list))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (user_id) {
        [parameters setObject:user_id forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}

- (void)getBilateralTimeline:(NSNumber *)user
                 sinceStatus:(NSNumber *)sinceStatus
           withMaximumStatus:(NSNumber *)maxStatus
                       count:(int)count
                 withSuccess:(void (^)(WKList *list))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    if (user) {
        [parameters setObject:user forKey:@"uid"];
    }
    if (sinceStatus) {
        [parameters setObject:sinceStatus forKey:@"since_id"];
    }
    if (maxStatus) {
        [parameters setObject:[NSNumber numberWithLongLong:[maxStatus longLongValue] - 1] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    
    [[WKOAuth2Client sharedInstance] getPath:@"statuses/user_timeline.json"
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                         WKList *list = [WKList listWithResponse:responseObject];
                                         if (success) {
                                             success(list);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
}


#pragma mark Posting Status
// statuses/update
// Post a weibo

- (void)updateStatusWithComment:(NSString *)comment
                    withSuccess:(void (^)(WKStatus *status))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:comment forKey:@"status"];
    [[WKOAuth2Client sharedInstance] postPath:@"statuses/update.json"
                                   parameters:parameters
                                      success:^(AFHTTPRequestOperation *operation, id responseObject){
                                          WKStatus *status = [WKStatus objectWithDictionary:responseObject];
                                          if (success) {
                                              success(status);
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                          if (failure) {
                                              failure(operation, error);
                                          }
                                      }];
}

- (void)uploadStatusWithComment:(NSString *)comment
                  withImageData:(NSData *)imageData
                        withLat:(float)lat
                        withLng:(float)lng
                    withSuccess:(void (^)(WKStatus *status))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:comment forKey:@"status"];
    [parameters setValue:[NSNumber numberWithFloat:lat] forKey:@"lat"];
    [parameters setValue:[NSNumber numberWithFloat:lng] forKey:@"long"];
    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST"
                                                                   path:@"statuses/upload.json"
                                                             parameters:parameters
                                              constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                  [formData appendPartWithFileData:imageData name:@"pic" fileName:@"temp.jpeg" mimeType:@"image/jpeg"];
                                              }];
    
    AFHTTPRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        WKStatus *status = [WKStatus objectWithDictionary:responseObject];
        if (success) {
            success(status);
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (failure) {
                                             failure(operation, error);
                                         }
                                     }];
    
    [operation start];
}

#pragma mark Repost Status
// statuses/repost
// Post a weibo

- (void)repostStatus:(NSNumber *)status
          withStatus:(NSString *)comment
           isComment:(int)is_comment
         withSuccess:(void (^)(WKStatus *status))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:comment forKey:@"status"];
    [parameters setValue:status forKey:@"id"];
    [parameters setValue:[NSNumber numberWithInt:is_comment] forKey:@"is_comment"];
    [[WKOAuth2Client sharedInstance] postPath:@"statuses/repost.json"
                                   parameters:parameters
                                      success:^(AFHTTPRequestOperation *operation, id responseObject){
                                          WKStatus *status = [WKStatus objectWithDictionary:responseObject];
                                          if (success) {
                                              success(status);
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                          if (failure) {
                                              failure(operation, error);
                                          }
                                      }];
}


#pragma mark Comment on Status
// comments/create
// Post a weibo

- (void)commentOnStatus:(NSNumber *)status
            withComment:(NSString *)comment
             onOriginal:(int)comment_ori
            withSuccess:(void (^)(WKStatus *status))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:comment forKey:@"comment"];
    [parameters setValue:status forKey:@"id"];
    [parameters setValue:[NSNumber numberWithInt:comment_ori] forKey:@"comment_ori"];
    [[WKOAuth2Client sharedInstance] postPath:@"comments/create.json"
                                   parameters:parameters
                                      success:^(AFHTTPRequestOperation *operation, id responseObject){
                                          WKStatus *status = [WKStatus objectWithDictionary:responseObject];
                                          if (success) {
                                              success(status);
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                          if (failure) {
                                              failure(operation, error);
                                          }
                                      }];
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
