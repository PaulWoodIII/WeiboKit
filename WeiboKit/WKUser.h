//
//  WKUser.h
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKUser : NSObject {

}

@property (nonatomic, retain) NSNumber *user_id;
@property (nonatomic, retain) NSString *screen_name;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSURL *profile_image_url;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSNumber *followers_count;
@property (nonatomic, retain) NSNumber *friends_count;
@property (nonatomic, retain) NSNumber *statuses_count;
@property (nonatomic, retain) NSNumber *favourites_count;
@property (nonatomic, retain) NSDate *created_at;
@property (getter=isFollowing) BOOL following;
@property (getter=isAllow_all_act_msg) BOOL allow_all_act_msg;
@property (nonatomic, retain) NSString *remark;
@property (nonatomic, assign, getter=isGeo_enabled) BOOL geo_enabled;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, assign, getter=isAllow_all_comment) BOOL allow_all_comment;
@property (nonatomic, retain) NSString *avatar_large;
@property (nonatomic, retain) NSString *verified_reason;
@property (getter=isFollow_me) BOOL follow_me;
@property (nonatomic, retain) NSNumber *online_status;
@property (nonatomic, retain) NSNumber *bi_followers_count;

+ (id)objectWithDictionary:(NSDictionary *)dictionary;

@end
