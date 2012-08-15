//
//  WKAuthorize.h
//  WeiboKit
//
//  Created by Paul Wood on 8/15/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//
//  Note:
//  Inspired by the WBAuthorize
//  Modified greatly for ARC support and integration to WeiboKit

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WKAuthorizeWebView.h"

@class WKAuthorize;

@protocol WKAuthorizeDelegate <NSObject>

@required

- (void)authorize:(WKAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;

- (void)authorize:(WKAuthorize *)authorize didFailWithError:(NSError *)error;

@end

@interface WKAuthorize : NSObject <WBAuthorizeWebViewDelegate> 
{

}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) id<WBAuthorizeDelegate> delegate;

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

- (void)startAuthorize;

@end
