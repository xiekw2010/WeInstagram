//
//  ILSInstagram.h
//  ILSInstagram
//
//  Created by xiekw on 14/6/16.
//  Copyright (c) 2014年 xiekw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILSInstagramNetworkOperation.h"

/**
 *  Instagram relationship operation
 */
typedef NS_ENUM(NSUInteger, InstagramRelationAction) {
    InstagramRelationActionFollow,
    InstagramRelationActionUnFollow,
    InstagramRelationActionBlock,
    InstagramRelationActionUnBlock,
    InstagramRelationActionApprove,
    InstagramRelationActionDeny,
};

/**
 *  This the main interface class for instagram networking events, follow the steps to use it.
 
    1. use ILSIGSessionManager to check if the user has logined instagram(which means if you have store the user instagram accessToken).
 
    2. if not logined, then present the ILSIGNativeLoginViewController.h to force the user to login his instagram.
 
    3. after login, use this class to do the networking events.
 
    4. discuss the cursor, when the reponse doesn't contain it, it will the last object's pk value
 
 */
@interface ILSInstagram : NSObject

+ (instancetype)sharedInstagram;

/**
 *  The network request timeout
 */
@property (nonatomic, assign) float reqTimeOut;
@property (nonatomic, assign) BOOL usingNativeWay;

/**
 *  For the debug mode, set to yes make an operation run after delay 10 seconds
 */
@property (nonatomic, assign) NSTimeInterval operationTimeInterval;

/**
 *  To get the user detail info, something like this 
 
    {
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
 
 
    The native version is
 
         user =     {
         biography = "";
         "external_url" = "";
         "follower_count" = 4078;
         "following_count" = 312;
         "full_name" = Xiekw;
         "geo_media_count" = 34;
         "is_private" = 0;
         "media_count" = 67;
         pk = 620760772;
         "profile_pic_url" = "http://images.ak.instagram.com/profiles/profile_620760772_75sq_1382339490.jpg";
         username = kxiexie;
         "usertags_count" = 0;
         };
 *
 *  @param userId  target userId
 *  @param handler response
 *
 *  @return the network operation;
 */
- (ILSInstagramNetworkOperation *)instagramDetailInfoForUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler;

/**
 *  Get the followers or following list for some user
 *
 *  @param followers YES means get followers, NO means get following
 *  @param userId    target userId
 *  @param cursor    the cursor to locate the page of list
 *  @param handler   response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramFollowers:(BOOL)followers fromUserId:(NSString *)userId fromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler;

/**
 *  Get the current logined user's feed list
 *
 *  @param cursor   the cursor to locate the page of list, when u use native way, the cursor is the last media "pk"
 *  @param handler response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramFeedsFromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler;

/**
 *  Get some one's whole post timeline list
 *
 *  @param cursor  the cursor to locate the page of list
 *  @param userId  target userId
 *  @param handler response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramTimelineFromCursor:(NSString *)cursor
                                                   fromUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler;

/**
 *  Get the current popular posts all over Instagram
 *
 *  @param handler reponse
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramHotMediaCompeletionHandler:(ResponseBlock)handler;


/**
 *  Get the specific Taged post list
 *
 *  @param cursor  the cursor to locate the page of list
 *  @param tagName the specific tag, could be chinese or some other languages
 *  @param handler response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramTagMediaFromCursor:(NSString *)cursor
                                                          tag:(NSString *)tagName
                                           compeletionHandler:(ResponseBlock)handler;


/**
 *  Get the fuzzy tag's post count, response will something like this
 
    {
         "snow" :{
         "media_count": 43590,
         "name": "snowy"
         },
 
         {
         "media_count": 3264,
         "name": "snowyday"
         },
 
         {
         "media_count": 1880,
         "name": "snowymountains"
         },
 
         {
         "media_count": 1164,
         "name": "snowydays"
         },
 
         {
         "media_count": 776,
         "name": "snowyowl"
         },
         {
         "media_count": 680,
         "name": "snowynight"
         },
 
         {
         "media_count": 568,
         "name": "snowylebanon"
         }
    }
 *
 *  @param tagName some tag name
 *  @param handler response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramFuzzySearchTag:(NSString *)tagName compeletionHandler:(ResponseBlock)handler;

/**
 *  Change the instagram relationship, here has a time limitation. Instagram doc is http://instagram.com/developer/endpoints/relationships/
 *
 *  @param otherUserId target user id
 *  @param action      follow, unfollow, deny, etc..
 *  @param handler     response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramChangeRelationShipWithUserId:(NSString *)otherUserId
                                                                 action:(InstagramRelationAction)action
                                                     compeletionHandler:(ResponseBlock)handler;

/**
 *  Get the relationship with some user, the relatioinship description doc is http://instagram.com/developer/endpoints/relationships/
 *
 *  @param userId  Target userId
 *  @param handler reponse
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramCheckRelationShipWithUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler;

/**
 *  Like or dislike the post, here has a time limitation, maybe 10 times every 5 minutes.
 *
 *  @param like    YES means like, NO means dislike
 *  @param mediaId Target mediaId
 *  @param handler reponse
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramLike:(BOOL)like media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler;

/**
 *  Get the searched username list
 *
 *  @param username Target username
 *  @param handler  response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramSearchUserName:(NSString *)username compeletionHandler:(ResponseBlock)handler;

/**
 *  Get my liked medias
 *
 *  @param cursor  the cursor to locate the page of list
 *  @param handler response
 *
 *  @return the network operation
 */
- (ILSInstagramNetworkOperation *)instagramMyLikedMediaFromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler;

- (void)ooLogin;

- (void)ooLoginUserName:(NSString *)username password:(NSString *)password CompletionHandler:(void(^)(NSDictionary *userInfoDic, NSError *error))handler;

- (ILSInstagramNetworkOperation *)ooLike:(BOOL)like media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler;

- (ILSInstagramNetworkOperation *)ooRelationAction:(InstagramRelationAction)action userId:(NSString *)userId compeletionHandler:(ResponseBlock)handler;

- (ILSInstagramNetworkOperation *)ooComment:(NSString *)comment media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler;


/**
 *  cancel all the instagram network operation
 */
- (void)cancelAll;


@end

@interface TimeIntervalOperationQueue : NSOperationQueue
{
    NSUInteger _opCount;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)time;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@end
