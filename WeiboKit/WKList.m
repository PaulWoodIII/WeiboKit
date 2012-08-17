//
//  WKList.m
//  WeiboKit
//
//  Created by Paul Wood on 8/17/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKList.h"
#import "WKStatus.h"

@implementation WKList

+ (WKList *)listWithResponse:(id)response{
    
    WKList *list = [[WKList alloc] init];
    
    if (![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *JSONStatuses = [response objectForKey:@"statuses"];
    
    NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:[JSONStatuses count]];
    for (NSDictionary *taskDictionary in JSONStatuses) {
        WKStatus *status = [WKStatus objectWithDictionary:taskDictionary];
        [statuses addObject:status];
    }
    list.statuses = statuses;
    list.previous_cursor = [response objectForKey:@"previous_cursor"];
    list.next_cursor = [response objectForKey:@"next_cursor"];
    list.total_number = [response objectForKey:@"total_number"];
    
    return list;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ previous_cursor:%@ | next_cursor:%@  total:%d >", [self class], self.previous_cursor, self.next_cursor, [self.statuses count]];
}

@end
