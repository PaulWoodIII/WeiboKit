//
//  WKStatus.m
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKStatus.h"
#import "WKUser.h"

@implementation WKStatus

+ (id)objectWithDictionary:(NSDictionary *)dictionary{
    // If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
    
    WKStatus *object = [[WKStatus alloc] initWithDictionary:dictionary];
    
    return object;
}

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.text = [dictionary objectForKey:@"text"];
        self.idNumber = [dictionary objectForKey:@"id"];
        self.idString = [dictionary objectForKey:@"idstr"];
        self.mid = [dictionary objectForKey:@"mid"];
        self.thumbnail_pic = [dictionary objectForKey:@"thumbnail_pic"];
        self.original_pic = [dictionary objectForKey:@"original_pic"];
        self.source = [dictionary objectForKey:@"source"];
        self.reposts_count = [dictionary objectForKey:@"reposts_count"];
        self.comments_count = [dictionary objectForKey:@"comments_count"];
        self.created_at = [dictionary objectForKey:@"created_at"];
        self.favorited = [[dictionary objectForKey:@"favorited"] boolValue];
        self.truncated = [[dictionary objectForKey:@"truncated"] boolValue];
        //self.geo = [dictionary objectForKey:@"geo"];
        self.in_reply_to_screen_name = [dictionary objectForKey:@"in_reply_to_screen_name"];
        self.in_reply_to_status_id = [dictionary objectForKey:@"in_reply_to_status_id"];
        self.in_reply_to_user_id = [dictionary objectForKey:@"in_reply_to_user_id"];
        // TO DO
        // Add all the other params
        self.user = [WKUser objectWithDictionary:[dictionary objectForKey:@"user"]];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ text:%@ | idString:%@>", [self class], self.text, self.idString];
}



@end
