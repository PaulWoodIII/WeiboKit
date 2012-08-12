//
//  WKOAuth2Client.h
//  WeiboKit
//
//  Created by Paul Wood on 8/11/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface WKOAuth2Client : AFOAuth2Client {
    NSString *oauthToken;
}

@property (nonatomic, retain) NSString *oauthToken;

+ (id)sharedInstance;

- (void)getStatusesWithSuccess:(void (^)(NSMutableArray *statuses))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
