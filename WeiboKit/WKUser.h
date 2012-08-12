//
//  WKUser.h
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKUser : NSObject {
    NSNumber *id;
    NSString *screen_name;
    NSString *name;
    NSString *province;
    NSString *city;
    NSString *location;
    NSString *description;
    NSString *url;
    NSString *profile_image_url;
    NSString *domain;
    NSString *gender;
    NSNumber *followers_count;
    NSNumber *friends_count;
    NSNumber *statuses_count;
    NSNumber *favourites_count;
    NSDate *created_at;
    BOOL following;
    BOOL allow_all_act_msg;
    NSString *remark;
    BOOL geo_enabled;
    BOOL verified;
    BOOL allow_all_comment;
    NSString *avatar_large;
    NSString *verified_reason;
    BOOL *follow_me;
    NSNumber *online_status;
    NSNumber *bi_followers_count;
}

@end
