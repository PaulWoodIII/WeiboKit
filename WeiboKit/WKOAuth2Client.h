//
//  WKOAuth2Client.h
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "AFOAuth2Client.h"

@class WKStatus;
@class WKUser;

@interface WKOAuth2Client : AFOAuth2Client {
    NSString *oauthToken;
    NSString *uid;
}

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *uid;

+ (id)sharedInstance;

- (void)getStatusesWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getUserDetailsWithSuccess:(void (^)(WKUser *user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
