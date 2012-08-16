//
//  WKOAuth2Client.h
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "AFOAuth2Client.h"
#import <CoreLocation/CoreLocation.h>
#import "WKAuthorizeWebView.h"

@class WKStatus;
@class WKUser;

extern NSString *const kWKAuthorizationSuccessfullNotificationName;
extern NSString *const kWKAuthorizationFailureNotificationName;

@interface WKOAuth2Client : AFOAuth2Client < WKAuthorizeWebViewDelegate > {
    
}

+ (id)sharedInstance;

#pragma mark -
#pragma mark OAuth 2.0 Authorization API

- (void)startAuthorization;

#pragma mark -
#pragma mark Weibo API
// Statuses and Posting Statuses

// TO DO
// statuses/public_timeline
// Return the latest public weibos

// - (void)getPublicTimlineWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/home_timeline
// Return the authenticating user’s and his friends’ latest weibos
- (void)getHomeTimelineWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getHomeTimelineSinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getHomeTimelineSinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/friends_timeline
// Return the authenticating user’s and his friends’ latest weibos
- (void)getFriendsTimelineWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getFriendsTimelineSinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getFriendsTimelineSinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/user_timeline
// Return the latest weibos of one user
- (void)getUserTimeline:(WKUser *)user withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getUserTimeline:(WKUser *)user sinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getUserTimeline:(WKUser *)user sinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/bilateral_timeline
// Return the latest weibos of the users that are following the authenticating user and are being
- (void)getBilateralTimeline:(WKUser *)user withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getBilateralTimeline:(WKUser *)user sinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getBilateralTimeline:(WKUser *)user sinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/repost_timeline
// Return the latest of repost weibos of a original weibo
- (void)getRepostForStatus:(WKStatus *)users withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getRepostForStatus:(WKStatus *)users sinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getRepostForStatus:(WKStatus *)users  sinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// statuses/mentions.json
// Return the latest weibos metioned the authenticating user
- (void)getMentionsWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getMentionsForStatus:(WKStatus *)users sinceStatus:(WKStatus *)sinceStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getMentionsForStatus:(WKStatus *)users  sinceStatus:(WKStatus *)sinceStatus withMaximumStatus:(WKStatus *)maxStatus startingAtPage:(int)pageNum count:(int)count withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//TODO
/*
 // statuses/show
 - (void)showStatusWithID:(int)statusID withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 
 // statuses/repost Repost a weibo
 // Repost a weibo
 - (void)repostStatus:(WKStatus *)status withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 - (void)repostStatus:(WKStatus *)status withComment:(NSString *)comment withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 
 // statuses/destroy Delete a weibo
 // Delete a weibo
 - (void)destroyStatus:(WKStatus *)status withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 
 // statuses/update
 // Post a weibo
 - (void)updateStatusWithComment:(NSString *)comment withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 - (void)updateStatusWithComment:(NSString *)comment withLat:(float)lat withLng:(float)lng withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 
 // statuses/upload
 // Upload a picture with a new weibo
 - (void)uploadStatusWithComment:(NSString *)comment withImage:(UIImage *)image withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 - (void)uploadStatusWithComment:(NSString *)comment withImage:(UIImage *)image withLat:(float)lat withLng:(float)lng withSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
 
 */

#pragma mark -
#pragma mark Comments API
// Comments and Posting Comments

#pragma mark -
#pragma mark Users API
// Friends & Followers
- (void)getUserDetailsWithSuccess:(void (^)(WKUser *user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark -
#pragma mark Accounts API


#pragma mark -
#pragma mark Favorites API

#pragma mark -
#pragma mark Topics API

#pragma mark -
#pragma mark Tags API

#pragma mark -
#pragma mark Register API

#pragma mark -
#pragma mark Search API

#pragma mark -
#pragma mark Recommend API

#pragma mark -
#pragma mark Remind API

#pragma mark -
#pragma mark Public Service API

#pragma mark -
#pragma mark Geo API

@end
