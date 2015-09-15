//
//  ILSINSSessionManager.m
//  ILSINSInstaFollower
//
//  Created by Kaiwei.Xie on 1/21/13.
//  Copyright (c) 2013 Kaiwei Xie. All rights reserved.
//

#import "ILSIGSessionManager.h"
#import "ILSInstagramHeader.h"

static NSString * const kIGLoginedUsersDataKey = @"ils.ig.kIGUserDataKey";
static NSString * const kIGLoginedUserIdskey = @"ils.ig.kIGLoginedUserIdskey";
static NSString * const kIGLoginedUserId = @"ils.ig.kIGLoginedUserId";

@interface ILSIGSessionManager ()
{
    NSString *_userId;
    NSDictionary *_userInfo;
}

@property (nonatomic, strong) NSMutableDictionary *loginedUsers;
@property (nonatomic, strong) NSMutableArray *loginedUserIds;

@end

@implementation ILSIGSessionManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(isLogin:(RCTResponseSenderBlock)callback)
{
  BOOL islogin = [[[self class] sharedInstance] isLogin];
  callback(@[[NSNull null], @(islogin)]);
}

+ (ILSIGSessionManager *)sharedInstance {
    static ILSIGSessionManager *_sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [[ILSIGSessionManager alloc] init];
    });
    return _sessionManager;
}

- (id)init
{
    if (self = [super init]) {
        [self loadUser];
    }
    return self;
}

- (void)loadUser
{
    NSArray *loginedUserIds = self.loginedUserIds;
    if (loginedUserIds.count) {
        self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kIGLoginedUserId];;
    }
}

- (NSArray *)loginedUserIds
{
    if (!_loginedUserIds) {
        NSArray *loginedIds = [[NSUserDefaults standardUserDefaults] objectForKey:kIGLoginedUserIdskey];
        _loginedUserIds = loginedIds;
        if (!_loginedUserIds) {
            _loginedUserIds = [NSArray array];
        }
    }
    return _loginedUserIds;
}

- (NSMutableDictionary *)loginedUsers
{
    if (!_loginedUsers) {
        NSData *usersData = [[NSUserDefaults standardUserDefaults] objectForKey:kIGLoginedUsersDataKey];
        NSDictionary *usersDictionary = usersData?[NSKeyedUnarchiver unarchiveObjectWithData:usersData]:[[NSDictionary alloc] init];
        _loginedUsers = [usersDictionary mutableCopy];
        if (!_loginedUsers) {
            _loginedUsers = [NSMutableDictionary dictionary];
        }
    }
    return _loginedUsers;
}

- (void)syncCurrentUserDetails
{
    if (self.userId) {
        self.loginedUsers[self.userId] = self.currentUser;
        NSData *allUserData = [NSKeyedArchiver archivedDataWithRootObject:self.loginedUsers];
        [[NSUserDefaults standardUserDefaults] setObject:allUserData forKey:kIGLoginedUsersDataKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// a place need to overwrite to support multi account login and logout
- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    self.currentUser = self.loginedUsers[_userId];
    if (!self.currentUser) {
        self.currentUser = [NSMutableDictionary dictionary];
    }
    if (_userId) {
        [[NSUserDefaults standardUserDefaults] setObject:_userId forKey:kIGLoginedUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)switchToUserId:(NSString *)switchedUserId
{
    if (switchedUserId && ![switchedUserId isEqualToString:self.userId]) {
        self.userId = switchedUserId;
        [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramUserDidLoginNotification object:nil userInfo:nil];
    }
}

- (void)didDeleteUserId:(NSString *)deletedUserId
{
    if ([deletedUserId isEqualToString:self.userId]) {
        
        if (self.loginedUserIds.count > 0) {
            NSInteger idx = [self.loginedUserIds indexOfObject:self.userId];
            NSInteger nextIdx;
            if (idx + 1 < self.loginedUserIds.count) {
                nextIdx = idx + 1;
            }else {
                if (idx - 1 >= 0) {
                    nextIdx = idx - 1;
                }else {
                    [self logout];
                    return;
                }
            }
            
            NSString *beSwitched = self.loginedUserIds[nextIdx];
            [self switchToUserId:beSwitched];
            [self didDeleteUserId:deletedUserId];
        }
    }else {
        if ([self.loginedUserIds containsObject:deletedUserId]) {
            
            NSMutableArray *mLoginUserIds = [self.loginedUserIds mutableCopy];
            [mLoginUserIds removeObject:deletedUserId];
            self.loginedUserIds = [mLoginUserIds copy];
            [[NSUserDefaults standardUserDefaults] setObject:self.loginedUserIds forKey:kIGLoginedUserIdskey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.loginedUsers removeObjectForKey:deletedUserId];
            NSData *allUserData = [NSKeyedArchiver archivedDataWithRootObject:self.loginedUsers];
            [[NSUserDefaults standardUserDefaults] setObject:allUserData forKey:kIGLoginedUsersDataKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramUserDidLogoutNotification object:deletedUserId userInfo:nil];
        }
    }
}

- (void)updateAccessToken:(NSString *)token userId:(NSString *)userId {
    
    if (![self.loginedUserIds containsObject:userId]) {
        NSMutableArray *mLoginIds = [self.loginedUserIds mutableCopy];
        [mLoginIds addObject:userId];
        self.loginedUserIds = [mLoginIds copy];
        [[NSUserDefaults standardUserDefaults] setObject:self.loginedUserIds forKey:kIGLoginedUserIdskey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    self.userId = userId;
    [self updateAccessToken:token];
}

- (void)saveUserName:(NSString *)username password:(NSString *)password
{
    if (username && password) {
        NSArray *uAndpArray = @[username, password];
        self.currentUser[kUsernameAndPwd] = uAndpArray;
        [self syncCurrentUserDetails];
    }
}

- (NSString *)accessToken
{
    NSString *accessToken = self.currentUser[kAccessTokenKey];
    return accessToken;
}

- (void)updateAccessToken:(NSString *)token
{
    if (token) {
        self.currentUser[kAccessTokenKey] = token;
        [self syncCurrentUserDetails];
    }
}

- (BOOL)isLogin
{
    return ([self loginedUserIds].count > 0 && [self userId].length > 0 && [self accessToken].length > 0);
}

- (NSArray *)usernameAndPassword
{
    return self.currentUser[kUsernameAndPwd];
}

- (NSDictionary *)userInfo
{
    NSDictionary *result = self.currentUser[kDetailsKey];
    return result;
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    if (userInfo) {
        self.currentUser[kDetailsKey] = userInfo;
        [self syncCurrentUserDetails];
    }
}

- (NSDictionary *)userIdAndDetailInfoMap
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self.loginedUsers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj[kDetailsKey]) {
            [result setObject:obj[kDetailsKey] forKey:key];
        }
    }];
    return result;
}

- (NSDictionary *)addTheCookiesWithHeaders:(NSDictionary *)headers
{
    NSMutableArray *hArray = [NSMutableArray array];
    NSDictionary *tokenDic;
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStore cookies]) {
        if ([cookie.domain rangeOfString:@"instagram.com"].length > 0) {
            [hArray addObject:cookie];
            if ([cookie.name isEqualToString:@"csrftoken"]) {
                tokenDic = @{@"X-CSRFToken": cookie.value};
            }
        }
    }

    NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:hArray];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [resultDic addEntriesFromDictionary:cookieDic];
    [resultDic addEntriesFromDictionary:tokenDic];
    [resultDic addEntriesFromDictionary:headers];
    return resultDic;
}

- (void)setHeaderFields:(NSDictionary *)headerFields
{
    if (headerFields) {
        NSDictionary *cookieHeaders = [self addTheCookiesWithHeaders:headerFields];
        self.currentUser[kWebLikeHeaders] = cookieHeaders;
        [self syncCurrentUserDetails];
    }
}

- (NSString *)csfToken {
    return self.headerFields[@"X-CSRFToken"];
}

- (NSDictionary *)headerFields
{
    NSDictionary *headers = self.currentUser[kWebLikeHeaders];
    return headers;
}

// It's a tough way to clear all, not support to delete specific userId
- (void)logout
{
    NSString *logoutUserId = self.userId;
    _userId = nil;
    _userInfo = nil;
    
    self.currentUser = [NSMutableDictionary dictionary];
    self.loginedUserIds = [NSMutableArray array];
    self.loginedUsers = [NSMutableDictionary dictionary];
    
    [[self class] clearInstagramCookies];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIGLoginedUserIdskey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIGLoginedUsersDataKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIGLoginedUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramUserDidLogoutNotification object:logoutUserId userInfo:nil];
}

+ (void)clearInstagramCookies
{
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStore cookies]) {
        [cookieStore deleteCookie:cookie];
    }
}

@end
