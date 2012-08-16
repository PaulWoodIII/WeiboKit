//
//  WKOAuthUser.m
//  WeiboKit
//
//  Created by Paul Wood on 8/15/12.
//  Copyright (c) 2012 Paul Wood. All rights reserved.
//

#import "WKOAuthUser.h"
#import "SSKeychain.h"

@implementation WKOAuthUser

NSString *const kWKCurrentUserChangedNotificationName = @"WKCurrentUserChangedNotification";

NSString *const kWKKeychainServiceName = @"WeiboV2";
static NSString *const kWKUserIDKey = @"WKUserID";
static WKOAuthUser *__currentUser = nil;

+ (WKOAuthUser *)currentUser {
	if (!__currentUser) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *userID = [userDefaults objectForKey:kWKUserIDKey];
		if (!userID) {
			return nil;
		}
		
		NSString *accessToken = [SSKeychain passwordForService:kWKKeychainServiceName account:userID];
		if (!accessToken) {
			return nil;
		}
        //Create the user
		__currentUser = [[WKOAuthUser alloc] init];
        __currentUser.user_id =
		__currentUser.accessToken = accessToken;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kWKCurrentUserChangedNotificationName object:__currentUser];
	}
	return __currentUser;
}


+ (void)setCurrentUser:(WKOAuthUser *)user {
	if (__currentUser) {
		[SSKeychain deletePasswordForService:kWKKeychainServiceName account:__currentUser.user_id];
	}
	
	if (!user.user_id || !user.accessToken) {
		__currentUser = nil;
		return;
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:user.user_id forKey:kWKUserIDKey];
	[userDefaults synchronize];
	
	[SSKeychain setPassword:user.accessToken forService:kWKKeychainServiceName account:user.user_id];
	
	__currentUser = user;

	[[NSNotificationCenter defaultCenter] postNotificationName:kWKCurrentUserChangedNotificationName object:user];
}


@end
