//
//  ILSINSSessionManager.h
//  ILSINSInstaFollower
//
//  Created by Kaiwei.Xie on 1/21/13.
//  Copyright (c) 2013 Kaiwei Xie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This the manager to cache instagram users. 
 
    The arch is a map of {@"userId" : @{usersDetails1}, @"userId2" : @{userDetails2}...}, and a list of userIds [@"userId1", @"userId2",...]
 
    The usersDetails is a map of {@"ils.ins.kUserInfoKey" : {userinfo}, @"ils.ins.kUserAccessTokenKey" : @"uiuidoa8812109303102", @"kLastPostedImageKey" : @"http://someURL.jpg"....}
 */
@interface ILSIGSessionManager : NSObject<RCTBridgeModule>

+ (ILSIGSessionManager *)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSArray *loginedUserIds;
@property (nonatomic, strong, readonly) NSString *accessToken;
@property (nonatomic, strong, readonly) NSString *csfToken;


/**
 *  something like this
 
    detailInfo = {
     bio = "\U54c8\U54c8";
     counts =     {
     "followed_by" = 40;
     follows = 29;
     media = 97;
     };
     "full_name" = Xiek;
     id = 266411723;
     "profile_picture" = "http://images.ak.instagram.com/profiles/profile_266411723_75sq_1361255855.jpg";
     username = xiekw;
     website = "";
    }
 
 */
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong, readonly) NSDictionary *userIdAndDetailInfoMap;

- (void)switchToUserId:(NSString *)switchedUserId;
- (void)didDeleteUserId:(NSString *)deletedUserId;



// when you need add new object for currentUser map, here is your solution, careful to remove any key!
@property (nonatomic, strong) NSMutableDictionary *currentUser;
- (void)syncCurrentUserDetails;

// usually you don't need to use or change, careful to use!!
- (void)updateAccessToken:(NSString *)token userId:(NSString *)userId;
- (void)saveUserName:(NSString *)username password:(NSString *)password;
- (NSArray *)usernameAndPassword;
- (void)setHeaderFields:(NSDictionary *)headerFields;
- (NSDictionary *)headerFields;

/**
 *  logout all users and Clear the sessions
 */
- (void)logout;


+ (void)clearInstagramCookies;

@end

static NSString * const kDetailsKey = @"ils.ins.kUserInfoKey";
static NSString * const kAccessTokenKey = @"ils.ins.kUserAccessTokenKey";
static NSString * const kWebLikeHeaders = @"ils.ins.kWebLikeHeaders";
static NSString * const kUsernameAndPwd = @"ils.ins.kUsernameAndPwd";
static NSString * const kIsUserPrivate = @"ils.ins.kIsUserPrivate";


