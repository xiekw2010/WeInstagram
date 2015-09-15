//
//  NSObject_ILSINSInstagramHeader.h
//  kxieINSDemo
//
//  Created by Kaiwei Xie on 12/13/12.
//  Copyright (c) 2012 Kaiwei Xie. All rights reserved.
//


#import "ILSIGLoginViewController.h"
#import "ILSIGSessionManager.h"
#import "ILSInstagramNetworkOperation.h"
#import "ILSInstagram.h"
#import "ILSIGNativeLoginViewController.h"

// User login and logout notification name
extern NSString * const kInstagramUserDidLoginNotification;

/**
 *  Notification.object is the user id of that user;
 
    A normal way to observe this noti is in the root viewcontroller, and the do follows 2 steps:
 
    1. clean the database about the userId
    2. check if instagram is still logged in? if not, then force the user to login.
 */
extern NSString * const kInstagramUserDidLogoutNotification;


// Instagram network important error code, eg: error.code == kInstagramErrorCodeInvalidUsernameAndPassword
extern NSInteger const kInstagramErrorCodeInvalidUsernameAndPassword;
extern NSInteger const kInstagramErrorNeedLoginToInstagramVerified;
