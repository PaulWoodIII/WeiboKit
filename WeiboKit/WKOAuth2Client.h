//
//  WKOAuth2Client.h
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "AFOAuth2Client.h"
#import <CoreLocation/CoreLocation.h>

@class WKStatus;
@class WKUser;

@interface WKOAuth2Client : AFOAuth2Client {
    NSString *oauthToken;
    NSString *uid;
}

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *uid;

+ (id)sharedInstance;

// Weibo API

// statuses/public_timeline
// Return the latest public weibos
- (void)getPublicTimlineWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

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

- (void)getUserDetailsWithSuccess:(void (^)(WKUser *user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
