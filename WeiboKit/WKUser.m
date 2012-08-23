//
//  WKUser.m
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKUser.h"

@implementation WKUser

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
        self.user_id = [dictionary objectForKey:@"id"];
        self.screen_name = [dictionary objectForKey:@"screen_name"];
        
        self.name = [dictionary objectForKey:@"name"];
        self.province = [dictionary objectForKey:@"province"];
        self.city = [dictionary objectForKey:@"city"];
        self.location = [dictionary objectForKey:@"location"];
        self.description = [dictionary objectForKey:@"province"];
        self.url = [dictionary objectForKey:@"url"];
        self.profile_image_url = [NSURL URLWithString:[dictionary objectForKey:@"profile_image_url"]];
        self.domain = [dictionary objectForKey:@"domain"];
        self.gender = [dictionary objectForKey:@"gender"];
        self.followers_count = [dictionary objectForKey:@"followers_count"];
        self.friends_count = [dictionary objectForKey:@"friends_count"];
        self.statuses_count = [dictionary objectForKey:@"statuses_count"];
        self.favourites_count = [dictionary objectForKey:@"favourites_count"];
        //self.created_at;
        self.following = [[dictionary objectForKey:@"following"] boolValue]; //Bool
        self.allow_all_act_msg = [[dictionary objectForKey:@"allow_all_act_msg"] boolValue]; //Bool
        self.remark = [dictionary objectForKey:@"remark"];
        self.geo_enabled = [[dictionary objectForKey:@"geo_enabled"] boolValue]; //Bool
        self.verified = [[dictionary objectForKey:@"verified"] boolValue]; //Bool
        self.allow_all_comment = [[dictionary objectForKey:@"allow_all_comment"] boolValue]; //Bool
        self.avatar_large = [dictionary objectForKey:@"avatar_large"];
        self.verified_reason = [dictionary objectForKey:@"verified_reason"];
        self.follow_me = [[dictionary objectForKey:@"follow_me"] boolValue];
        self.online_status = [dictionary objectForKey:@"online_status"];
        self.bi_followers_count = [dictionary objectForKey:@"bi_followers_count"];
        
        // TO DO
        // Add all the other params
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ user_id:%@ | screen_name:%@>", [self class], self.user_id, self.screen_name];
}

@end
