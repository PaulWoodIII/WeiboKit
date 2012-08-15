//
//  WKAuthorize.m
//  WeiboKit
//
//  Created by Paul Wood on 8/15/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//
//  Note:
//  Inspired by the WBAuthorize
//  Modified greatly for ARC support and integration to WeiboKit

#import "WKAuthorize.h"
#import "AFHTTPClient.h"
#import "AFJSONUtilities.h"

#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/"

@interface WKAuthorize (Private)

- (void)dismissModalViewController;
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password;

@end

@implementation WKAuthorize

@synthesize appKey;
@synthesize appSecret;
@synthesize redirectURI;
@synthesize delegate;

#pragma mark - WBAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

#pragma mark - WBAuthorize Private Methods

- (void)dismissModalViewController
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissModalViewControllerAnimated:YES];;
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kWBAccessTokenURL]];
    [client postPath:[NSString stringWithFormat:@"access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",
                      appKey, appSecret, redirectURI, code]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject){
                 NSError *error = nil;
                 id responseJSON;
                 if ([responseObject length] == 0) {
                     responseJSON = nil;
                 } else {
                     responseJSON = AFJSONDecode(responseObject, &error);
                 }
                 
                 BOOL success = NO;
                 
                 if ([responseJSON isKindOfClass:[NSDictionary class]])
                 {
                     NSDictionary *dict = (NSDictionary *)responseJSON;
                     
                     NSString *token = [dict objectForKey:@"access_token"];
                     NSString *userID = [dict objectForKey:@"uid"];
                     NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
                     
                     success = token && userID;
                     
                     if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
                     {
                         [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds];
                     }
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error){
                 if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)])
                 {
                     [delegate authorize:self didFailWithError:error];
                 }
             }];
}

#pragma mark - WBAuthorize Public Methods

- (void)startAuthorize
{  
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&redirect_uri=%@&client_id=%@", redirectURI, appKey];
    NSLog(@"%@", urlString);
    WKAuthorizeWebView *webView = [[WKAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
}

- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    [self requestAccessTokenWithUserID:userID password:password];
}

#pragma mark - WBAuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(WKAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    [webView hide:YES];
    
    // if not canceled
    if (![code isEqualToString:@"21330"])
    {
        [self requestAccessTokenWithAuthorizeCode:code];
    }
}


@end
