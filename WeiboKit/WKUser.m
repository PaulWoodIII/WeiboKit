//
//  WKUser.m
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKUser.h"

@implementation WKUser

@synthesize user_id;
@synthesize screen_name;
@synthesize name;
@synthesize province;
@synthesize city;
@synthesize location;
@synthesize description;
@synthesize url;
@synthesize profile_image_url;
@synthesize domain;
@synthesize gender;
@synthesize followers_count;
@synthesize friends_count;
@synthesize statuses_count;
@synthesize favourites_count;
@synthesize created_at;
@synthesize following;
@synthesize allow_all_act_msg;
@synthesize remark;
@synthesize geo_enabled;
@synthesize verified;
@synthesize allow_all_comment;
@synthesize avatar_large;
@synthesize verified_reason;
@synthesize follow_me;
@synthesize online_status;
@synthesize bi_followers_count;

+ (id)objectWithDictionary:(NSDictionary *)dictionary{
    // If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
    
    WKUser *object = [[WKUser alloc] initWithDictionary:dictionary];
    
    return object;
}

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.user_id = [[dictionary objectForKey:@"id"] description];
        self.screen_name = [dictionary objectForKey:@"screen_name"];
        // TO DO
        // Add all the other params
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ user_id:%@ | screen_name:%@>", [self class], self.user_id, self.screen_name];
}

@end
