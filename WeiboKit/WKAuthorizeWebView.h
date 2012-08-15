//
//  WKAuthorizeWebView.h
//  WeiboKit
//
//  Created by Paul Wood on 8/15/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//
//  Note:
//  Inspired by the WBAuthorizeWebView
//  Modified greatly for ARC support and integration to WeiboKit

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WKAuthorizeWebView;

@protocol WKAuthorizeWebViewDelegate <NSObject>

- (void)authorizeWebView:(WKAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code;

@end

@interface WKAuthorizeWebView : UIView <UIWebViewDelegate> 
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
}

@property (nonatomic, assign) id<WKAuthorizeWebViewDelegate> delegate;

- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

@end