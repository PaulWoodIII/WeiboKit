//
//  WKStatus.h
//  WeiboKit
//
//  Created by Paul Wood on 8/12/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class WKUser;

@interface WKStatus : NSObject {

}

@property (nonatomic, retain) NSNumber *idNumber;
@property (nonatomic, retain) NSString *idString;
@property (nonatomic, retain) NSString *mid;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *thumbnail_pic;
@property (nonatomic, retain) NSString *original_pic;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSNumber *reposts_count;
@property (nonatomic, retain) NSNumber *comments_count;
@property (nonatomic, retain) NSDate *created_at;
@property (nonatomic, assign, getter=isFavorited) BOOL favorited;
@property (nonatomic, assign, getter=isTruncated) BOOL truncated;
@property (nonatomic, retain) CLLocation *geo;
@property (nonatomic, retain) NSString *in_reply_to_screen_name;
@property (nonatomic, retain) NSString *in_reply_to_status_id;
@property (nonatomic, retain) NSString *in_reply_to_user_id;
@property (nonatomic, retain) WKUser *user;

+ (id)objectWithDictionary:(NSDictionary *)dictionary;

@end