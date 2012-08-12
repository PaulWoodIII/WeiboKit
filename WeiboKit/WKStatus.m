//
//  WKStatus.m
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKStatus.h"

@implementation WKStatus

@synthesize idString;
@synthesize mid;
@synthesize text;
@synthesize thumbnail_pic;
@synthesize original_pic;
@synthesize source;
@synthesize reposts_count;
@synthesize comments_count;
@synthesize created_at;
@synthesize favorited;
@synthesize truncated;
@synthesize geo;
@synthesize in_reply_to_screen_name;
@synthesize in_reply_to_status_id;
@synthesize in_reply_to_user_id;

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
        self.idString = [dictionary objectForKey:@"idstr"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ text:%@ | idString:%@>", [self class], self.text, self.idString];
}



@end
