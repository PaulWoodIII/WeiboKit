//
//  WKList.h
//  WeiboKit
//
//  Created by Paul Wood on 8/17/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKList : NSObject

@property BOOL hasvisible;
@property NSNumber *previous_cursor;
@property NSNumber *next_cursor;
@property NSNumber *total_number;
@property (nonatomic, retain) NSMutableArray *statuses;

+ (WKList *)listWithResponse:(id)response;

@end
