//
//  ILSInstagram.m
//  ILSInstagram
//
//  Created by xiekw on 14/6/16.
//  Copyright (c) 2014年 xiekw. All rights reserved.
//

#import "ILSInstagram.h"
#import "ILSInstagramHeader.h"
#import <CommonCrypto/CommonCrypto.h>

//static NSString  *_kIg_sig = @"30b12eccccac24b72a8b95780755bdc8"; // version 4 key


NSString * const kInstagramUserDidLoginNotification = @"ilsins.kILSMLNotiInstagramUserDidLogin";
NSString * const kInstagramUserDidLogoutNotification = @"ilsins.kInstagramUserDidLogoutNotification";

NSInteger const kInstagramErrorCodeInvalidUsernameAndPassword = 78781;
NSInteger const kInstagramErrorNeedLoginToInstagramVerified = 78782;

static NSString * const kAFMultipartFormCRLF = @"\r\n";



//HTTP Headers keys
static NSString * const kUserAgent = @"kUserAgent";
static NSString * const kHost = @"kHost";
static NSString * const kIgSigKeyVersion = @"kIgSigKeyVersion";
static NSString * const kIgSigature = @"kIgSigature";

//HTTP Headers values
static NSString * _UserAgent = @"Instagram 6.4.1 (iPhone6,2; iPhone OS 8_1; zh_CN; en) AppleWebKit/420+";
static NSString * _Host = @"i.instagram.com";
static NSUInteger _Ig_sig_key_version = 5;
static NSString * _Ig_sig = @"b38a8379f150531f9ad0d53ec8f7ac29e66aa875571f3bf75289bbdf1b4fd2d8";


//HTTP Path keys
static NSString * const kLoginPath = @"kLoginPath";
static NSString * const kDetailInfoPath = @"kDetailInfoPath";
static NSString * const kFollowingsPath = @"kFollowingPath";
static NSString * const kFollowersPath = @"kFollowerPath";
static NSString * const kMyFeedPath = @"kMyFeedPath";
static NSString * const kUnFollowPath = @"kUnFollowPath";
static NSString * const kFollowPath = @"kFollowPath";
static NSString * const kCommentPath = @"kCommentPath";
static NSString * const kLikePath = @"kLikePath";
static NSString * const kUnLikePath = @"kUnLikePath";
static NSString * const kUserTimelinePath = @"kUserTimeline";
static NSString * const kHotMediaPath = @"kHotMediaPath";
static NSString * const kTagMediaPath = @"kTagMediaPath";
static NSString * const kSearchTagPath = @"kSearchTagPath";
static NSString * const kCheckRelationshipPath = @"kCheckRelationshipPath";
static NSString * const kMyLikedMediaPath = @"kMyLikedMediaPath";
static NSString * const kSearchUserPath = @"kSearchUserPath";

//HTTP Path values
static NSString * _LoginPath = @"https://i.instagram.com/api/v1/accounts/login/";
static NSString * _DetailInfoPath = @"http://i.instagram.com/api/v1/users/%@/info/";
static NSString * _followingsPath = @"http://i.instagram.com/api/v1/friendships/%@/following/";
static NSString * _followersPath = @"http://i.instagram.com/api/v1/friendships/%@/followers/";
static NSString * _myFeedPath = @"http://i.instagram.com/api/v1/feed/timeline/?";
static NSString * _unFollowPath = @"http://i.instagram.com/api/v1/friendships/destroy/%@/";
static NSString * _followPath = @"http://i.instagram.com/api/v1/friendships/create/%@/";
static NSString * _commentPath = @"http://i.instagram.com/api/v1/media/%@/comment/";
static NSString * _likePath = @"http://i.instagram.com/api/v1/media/%@/like/?d=1&src=profile";
static NSString * _unLikePath = @"http://i.instagram.com/api/v1/media/%@/unlike/";
static NSString * _userTimelinePath = @"http://i.instagram.com/api/v1/feed/user/%@/?";
static NSString * _hotMediaPath = @"http://i.instagram.com/api/v1/feed/popular/?";
static NSString * _tagMediaPath = @"http://i.instagram.com/api/v1/feed/tag/%@/?";
static NSString * _searchTagPath = @"http://i.instagram.com/api/v1/tags/search/?q=%@";
static NSString * _checkRelationshipPath = @"http://i.instagram.com/api/v1/friendships/show/%@/";
static NSString * _myLikedMediaPath = @"http://i.instagram.com/api/v1/feed/liked/?";
static NSString * _searchUserPath = @"http://i.instagram.com/api/v1/users/search/?%@&ig_sig=%@";


static inline void _loadAnyKeys()
{
  NSDictionary *defaulDic = @{
                              kLoginPath:_LoginPath,
                              kDetailInfoPath:_DetailInfoPath,
                              kFollowingsPath:_followingsPath,
                              kFollowersPath:_followersPath,
                              kMyFeedPath:_myFeedPath,
                              kUnFollowPath:_unFollowPath,
                              kFollowPath:_followPath,
                              kCommentPath:_commentPath,
                              kLikePath:_likePath,
                              kUnLikePath:_unLikePath,
                              kUserAgent:_UserAgent,
                              kHost:_Host,
                              kIgSigKeyVersion:@(_Ig_sig_key_version),
                              kIgSigature:_Ig_sig,
                              kUserTimelinePath:_userTimelinePath,
                              kHotMediaPath:_hotMediaPath,
                              kTagMediaPath:_tagMediaPath,
                              kSearchTagPath:_searchTagPath,
                              kCheckRelationshipPath:_checkRelationshipPath,
                              kMyLikedMediaPath:_myLikedMediaPath,
                              kSearchUserPath:_searchUserPath
                              };
  
  NSDictionary *resultDic = defaulDic;
  _LoginPath = resultDic[kLoginPath] ? : _LoginPath;
  _followingsPath = resultDic[kFollowingsPath] ? : _followingsPath;
  _followersPath = resultDic[kFollowersPath] ? : _followersPath;
  _UserAgent = resultDic[kUserAgent] ? : _UserAgent;
  _Host = resultDic[kHost] ? : _Host;
  NSInteger v = [resultDic[kIgSigKeyVersion] integerValue];
  _Ig_sig_key_version = v > 0 ? v : _Ig_sig_key_version;
  _Ig_sig = resultDic[kIgSigature] ? : _Ig_sig;
  _myFeedPath = resultDic[kMyFeedPath] ? : _myFeedPath;
  _followPath = resultDic[kFollowPath] ? : _followPath;
  _unFollowPath = resultDic[kUnFollowPath] ? : _unFollowPath;
  _commentPath = resultDic[kCommentPath] ? : _commentPath;
  _userTimelinePath = resultDic[kUserTimelinePath] ? : _userTimelinePath;
  _hotMediaPath = resultDic[kHotMediaPath] ? : _hotMediaPath;
  _tagMediaPath = resultDic[kTagMediaPath] ? : _tagMediaPath;
  _searchTagPath = resultDic[kSearchTagPath] ? : _searchTagPath;
  _checkRelationshipPath = resultDic[kCheckRelationshipPath] ? : _checkRelationshipPath;
  _myLikedMediaPath = resultDic[kMyLikedMediaPath] ? : _myLikedMediaPath;
  _searchUserPath = resultDic[kSearchUserPath] ? : _searchUserPath;
}

static inline NSString *myHac(NSString *from)
{
    NSString *androidKey = _Ig_sig;
    
    const char *cKey  = [androidKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [from cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    char *resultData = malloc(CC_SHA256_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_SHA256_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(cHMAC[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(cHMAC[index] % 0x10)];
    }
    resultData[CC_SHA256_DIGEST_LENGTH * 2] = 0;
    
    NSString *resultString = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    free(resultData);
    
    return resultString;
}

static inline NSString *stringForAction(InstagramRelationAction action)
{
    NSString *result;
    switch (action) {
        case InstagramRelationActionFollow:
            result = @"follow";
            break;
        case InstagramRelationActionUnFollow:
            result = @"unfollow";
            break;
        case InstagramRelationActionBlock:
            result = @"block";
            break;
        case InstagramRelationActionUnBlock:
            result = @"unblock";
            break;
        case InstagramRelationActionApprove:
            result = @"approve";
            break;
        case InstagramRelationActionDeny:
            result = @"ignore";
            break;
        default:
            break;
    }
    
    return result;
}

@interface ILSInstagram ()
{
    BOOL _isNativeLogin;
}

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ILSInstagram

+ (instancetype)sharedInstagram
{
    static dispatch_once_t onceToken;
    static ILSInstagram *__shared = nil;
    dispatch_once(&onceToken, ^{
        __shared = [[ILSInstagram alloc] init];
    });
    return __shared;
}

- (id)init
{
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 10;
        self.reqTimeOut = 15.0f;
        self.usingNativeWay = YES;
        _loadAnyKeys();
    }
    return self;
}

- (void)setOperationTimeInterval:(NSTimeInterval)operationTimeInterval
{
    _operationTimeInterval = operationTimeInterval;
    if (_operationTimeInterval > 0) {
        self.operationQueue = [[TimeIntervalOperationQueue alloc] initWithTimeInterval:_operationTimeInterval];
    }else {
        self.operationQueue = [NSOperationQueue new];
    }
    self.operationQueue.maxConcurrentOperationCount = 10.0;
}

- (BOOL)_isNativeWay
{
    if (self.usingNativeWay) {
        return YES;
    }else {
        if ([[ILSIGSessionManager sharedInstance].accessToken rangeOfString:@"."].location != NSNotFound) {
            return NO;
        }else {
            return YES;
        }
    }
}

//无rank_token
- (ILSInstagramNetworkOperation *)instagramDetailInfoForUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSString *path = [NSString stringWithFormat:_DetailInfoPath, userId];
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSString *path = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/?access_token=%@", [userId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [ILSIGSessionManager sharedInstance].accessToken];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = ^(id response, NSError *error) {
            
            if (!error && [response isKindOfClass:[NSDictionary class]]) {
                if ([userId isEqualToString:[ILSIGSessionManager sharedInstance].userId]) {
                    [ILSIGSessionManager sharedInstance].userInfo = response[@"data"];
                }
            }
            
            if (handler) {
                handler(response, error);
            }
        };
        [self.operationQueue addOperation:op];
        return op;
    }
}

//已添加rank_token
- (ILSInstagramNetworkOperation *)instagramFollowers:(BOOL)followers fromUserId:(NSString *)userId fromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSMutableString *path;
        if (!followers) {
            path = [[NSString stringWithFormat:_followingsPath, userId] mutableCopy];

        }else {
            path = [[NSString stringWithFormat:_followersPath, userId] mutableCopy];
        }
        
        NSString *before;
        if (cursor) {
            before = [NSString stringWithFormat:@"ig_sig_key_version=%lu&max_id=%@", (unsigned long)_Ig_sig_key_version, cursor];
        }else {
            before = [NSString stringWithFormat:@"ig_sig_key_version=%lu&rank_token=", (unsigned long)_Ig_sig_key_version];
        }
        NSString *sig = myHac(before);
        [path appendFormat:@"?%@&ig_sig=%@", before, sig];
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSString *followPathComp = followers ? @"followed-by" : @"follows";
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/%@?access_token=%@&count=500", [userId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], followPathComp,[ILSIGSessionManager sharedInstance].accessToken] mutableCopy];
        if (cursor) {
            [path appendFormat:@"&cursor=%@", cursor];
        }
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

//无rank_token
- (ILSInstagramNetworkOperation *)instagramFeedsFromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSMutableString *path = [_myFeedPath mutableCopy];
        if (cursor) {
            [path appendFormat:@"max_id=%@&", cursor];
        }
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", [ILSIGSessionManager sharedInstance].accessToken] mutableCopy];
        if (cursor) {
            [path appendFormat:@"&max_id=%@", cursor];
        }
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}


- (ILSInstagramNetworkOperation *)instagramTimelineFromCursor:(NSString *)cursor
                                                   fromUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSMutableString *path = [[NSString stringWithFormat:_userTimelinePath, userId] mutableCopy];
        if (cursor) {
            [path appendFormat:@"max_id=%@&", cursor];
        }
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@&count=%d", userId, [ILSIGSessionManager sharedInstance].accessToken, 500] mutableCopy];
        if (cursor) {
            [path appendFormat:@"&max_id=%@", cursor];
        }
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramHotMediaCompeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:_hotMediaPath];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }else {
        NSString *path = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/popular?access_token=%@", [ILSIGSessionManager sharedInstance].accessToken];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramTagMediaFromCursor:(NSString *)cursor
                                                          tag:(NSString *)tagName
                                           compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSString *utfTag = [tagName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableString *path = [[NSString stringWithFormat:_tagMediaPath, utfTag] mutableCopy];
        if (cursor) {
            [path appendFormat:@"max_id=%@&", cursor];
        }
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@", [tagName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [ILSIGSessionManager sharedInstance].accessToken] mutableCopy];
        if (cursor) {
            [path appendFormat:@"&max_tag_id=%@", cursor];
        }
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramFuzzySearchTag:(NSString *)tagName compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSString *utfTagName = [tagName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *path = [NSString stringWithFormat:_searchTagPath, utfTagName];
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/search?q=%@&access_token=%@", [tagName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [ILSIGSessionManager sharedInstance].accessToken] mutableCopy];
        
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramChangeRelationShipWithUserId:(NSString *)otherUserId
                                                                 action:(InstagramRelationAction)action
                                                     compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        return [self ooRelationAction:action userId:otherUserId compeletionHandler:handler];
    }else {
        NSString *path = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship?", [otherUserId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSString *body = [NSString stringWithFormat:@"access_token=%@&action=%@", [ILSIGSessionManager sharedInstance].accessToken, stringForAction(action)];
        
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut withMethod:HttpMethodPost httpBody:body];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }

}

- (ILSInstagramNetworkOperation *)instagramCheckRelationShipWithUserId:(NSString *)userId compeletionHandler:(ResponseBlock)handler
{
    
    if ([self _isNativeWay]) {
        NSString *path = [NSString stringWithFormat:_checkRelationshipPath, userId];
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        [self.operationQueue addOperation:op];
        op.responseHanlder = handler;
        return op;
    }else {
        NSString *path = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship?access_token=%@", userId, [ILSIGSessionManager sharedInstance].accessToken];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramLike:(BOOL)like media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        return [self ooLike:like media:mediaId compeletionHandler:handler];
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?", [mediaId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] mutableCopy];
        NSString *body = [NSString stringWithFormat:@"access_token=%@", [ILSIGSessionManager sharedInstance].accessToken];
        
        HttpMethod method;
        ILSInstagramNetworkOperation *op;
        
        if (like) {
            method = HttpMethodPost;
            op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut withMethod:method httpBody:body];
        }else {
            method = HttpMethodDelete;
            [path appendFormat:@"&%@", body];
            op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut withMethod:method httpBody:body];
        }
        
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramSearchUserName:(NSString *)username compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSString *utfUserName = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *fromSig = [NSString stringWithFormat:@"ig_sig_key_version=%lu&query=%@", (unsigned long)_Ig_sig_key_version, utfUserName];
        NSString *sig = myHac(fromSig);
        NSString *path = [NSString stringWithFormat:_searchUserPath, fromSig, sig];
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }else {
        NSString *utfUserName = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *path = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&access_token=%@", utfUserName, [ILSIGSessionManager sharedInstance].accessToken];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (ILSInstagramNetworkOperation *)instagramMyLikedMediaFromCursor:(NSString *)cursor compeletionHandler:(ResponseBlock)handler
{
    if ([self _isNativeWay]) {
        NSMutableString *path = [_myLikedMediaPath mutableCopy];
        if (cursor) {
            [path appendFormat:@"max_id=%@&", cursor];
        }
        NSURLRequest *req = [self _buildNativeGetRequestWithPath:path];
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }else {
        NSMutableString *path = [[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/liked?access_token=%@&count=500", [ILSIGSessionManager sharedInstance].accessToken] mutableCopy];
        if (cursor) {
            [path appendFormat:@"&max_like_id=%@", cursor];
        }
        ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithURL:[NSURL URLWithString:path] timeOut:self.reqTimeOut];
        op.responseHanlder = handler;
        [self.operationQueue addOperation:op];
        return op;
    }
}

- (NSMutableURLRequest *)_defaultReqWithPath:(NSString *)path
{
    NSMutableURLRequest *mReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.reqTimeOut];
    [mReq setValue:_UserAgent forHTTPHeaderField:@"User-Agent"];
    [mReq setValue:_Host forHTTPHeaderField:@"Host"];
    [mReq setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [mReq setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [mReq setValue:@"en;q=1, zh-Hans;q=0.9, ja;q=0.8, zh-Hant;q=0.7, fr;q=0.6, de;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [mReq setValue:@"AQ==" forHTTPHeaderField:@"X-IG-Capabilities"];
    [mReq setValue:@"WiFi" forHTTPHeaderField:@"X-IG-Connection-Type"];
    return mReq;
}

- (NSMutableURLRequest *)_buildNativeIGMultipartRequestWithPath:(NSString *)path param:(NSDictionary *)param
{
    NSString *kAFMultipartFormBoundary = [NSUUID UUID].UUIDString;
    NSMutableURLRequest *mReq = [self _defaultReqWithPath:path];
    [mReq setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kAFMultipartFormBoundary] forHTTPHeaderField:@"Content-Type"];
    [mReq setHTTPMethod:@"POST"];
    NSMutableData *body = [[NSMutableData alloc] init];
    [body appendData:[[NSString stringWithFormat:@"--%@%@", kAFMultipartFormBoundary, kAFMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ig_sig_key_version\"%@%@", kAFMultipartFormCRLF, kAFMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@%@", param[@"ig_sig_key_version"], @"\r"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@--%@%@", kAFMultipartFormCRLF, kAFMultipartFormBoundary, kAFMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"signed_body\"%@%@", kAFMultipartFormCRLF, kAFMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", param[@"signed_body"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@--%@--%@", kAFMultipartFormCRLF, kAFMultipartFormBoundary, kAFMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [mReq setHTTPBody:body];
    [mReq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
    
    // if we do the login request, here we must not set the cookie!
    if (![path isEqualToString:_LoginPath]) {
        NSDictionary *currentHeaderFields = [[ILSIGSessionManager sharedInstance] headerFields];
        if (currentHeaderFields[@"Cookie"]) {
            [mReq setValue:currentHeaderFields[@"Cookie"] forHTTPHeaderField:@"Cookie"];
        }
    }
    
    return mReq;
}

- (NSMutableURLRequest *)_buildNativeGetRequestWithPath:(NSString *)path
{
    NSMutableURLRequest *mReq = [self _defaultReqWithPath:path];
    NSDictionary *currentHeaderFields = [[ILSIGSessionManager sharedInstance] headerFields];
    if (currentHeaderFields[@"Cookie"]) {
        [mReq setValue:currentHeaderFields[@"Cookie"] forHTTPHeaderField:@"Cookie"];
    }

    [mReq setHTTPMethod:@"GET"];
    return mReq;
}

- (void)ooLogin
{
    [self ooLoginCompletionHandler:nil];
}

- (void)ooLoginUserName:(NSString *)username password:(NSString *)password CompletionHandler:(void(^)(NSDictionary *userInfoDic, NSError *error))handler
{
    if (_isNativeLogin) {
        return;
    }
    _isNativeLogin = YES;
    [ILSIGSessionManager clearInstagramCookies];
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *signedBodyString = [NSString stringWithFormat:@"{\"_uuid\":\"%@\",\"password\":\"%@\",\"username\":\"%@\",\"device_id\":\"%@\",\"from_reg\":false,\"_csrftoken\":\"missing\"}", uuid, password, username,uuid];
    NSString *resultString = @"";
    resultString = [resultString stringByAppendingString:[[myHac(signedBodyString) stringByAppendingString:@"."] stringByAppendingString:signedBodyString]];
    NSDictionary *param = @{@"signed_body":resultString, @"ig_sig_key_version":@(_Ig_sig_key_version)};
    NSLog(@"Request Param is %@", param);
    NSString *path = _LoginPath;
    NSURLRequest *mReq = [self _buildNativeIGMultipartRequestWithPath:path param:param];
    ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:mReq];
    op.responseHanlder = ^(id response, NSError *error) {
        _isNativeLogin = NO;
        if (!error && response) {
            NSString *userId = [NSString stringWithFormat:@"%@",[response valueForKeyPath:@"logged_in_user.pk"]];
            [[ILSIGSessionManager sharedInstance] updateAccessToken:nil userId:userId];
            [[ILSIGSessionManager sharedInstance] setHeaderFields:mReq.allHTTPHeaderFields];
            [[ILSIGSessionManager sharedInstance] saveUserName:username password:password];
        }
        if (handler) {
            handler(response, error);
        }
    };
    [self.operationQueue addOperation:op];
}

- (void)ooLoginCompletionHandler:(ResponseBlock)handler
{
    NSArray *uAndP = [ILSIGSessionManager sharedInstance].usernameAndPassword;
    if (uAndP.count == 2) {
        NSString *username = uAndP[0];
        NSString *password = uAndP[1];
        [self ooLoginUserName:username password:password CompletionHandler:handler];
    }else {
        if (handler) {
            handler(nil, [NSError errorWithDomain:@"ilsinstagram" code:100 userInfo:@{NSLocalizedDescriptionKey: @"No username and password"}]);
        }
    }
}

- (ILSInstagramNetworkOperation *)ooLike:(BOOL)like media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler
{
    NSString *likeOrUnLike = like ? _likePath : _unLikePath;
    NSString *path = [NSString stringWithFormat:likeOrUnLike, mediaId];
    NSString *csfToken = [ILSIGSessionManager sharedInstance].csfToken;
    NSString *signedBodyString = [NSString stringWithFormat:@"{\"media_id\":\"%@\",\"_csrftoken\":\"%@\"}", mediaId, csfToken];
    NSString *resultString = @"";
    resultString = [resultString stringByAppendingString:[[myHac(signedBodyString) stringByAppendingString:@"."] stringByAppendingString:signedBodyString]];
    NSDictionary *param = @{@"signed_body":resultString, @"ig_sig_key_version":@(_Ig_sig_key_version)};
    NSMutableURLRequest *req = [self _buildNativeIGMultipartRequestWithPath:path param:param];
    ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
    op.responseHanlder = handler;
    [self.operationQueue addOperation:op];
    return op;
}

- (ILSInstagramNetworkOperation *)ooRelationAction:(InstagramRelationAction)action userId:(NSString *)userId compeletionHandler:(ResponseBlock)handler
{
    NSString *actionString;
    switch (action) {
        case InstagramRelationActionApprove:
        case InstagramRelationActionBlock:
        case InstagramRelationActionDeny:
        case InstagramRelationActionUnBlock:
        case InstagramRelationActionFollow:
            actionString = _followPath;
            break;
        case InstagramRelationActionUnFollow:
            actionString = _unFollowPath;
            break;
        default:
            actionString = _followPath;
            break;
    }
    NSString *csfToken = [ILSIGSessionManager sharedInstance].csfToken;
    NSString *path = [NSString stringWithFormat:actionString, userId];
    NSString *signedBodyString = [NSString stringWithFormat:@"{\"user_id\":\"%@\",\"_csrftoken\":\"%@\"}", userId, csfToken];
    NSString *resultString = @"";
    resultString = [resultString stringByAppendingString:[[myHac(signedBodyString) stringByAppendingString:@"."] stringByAppendingString:signedBodyString]];
    NSDictionary *param = @{@"signed_body":resultString, @"ig_sig_key_version":@(_Ig_sig_key_version)};
    NSMutableURLRequest *req = [self _buildNativeIGMultipartRequestWithPath:path param:param];
    ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
    op.responseHanlder = handler;
    [self.operationQueue addOperation:op];
    return op;
}

- (ILSInstagramNetworkOperation *)ooComment:(NSString *)comment media:(NSString *)mediaId compeletionHandler:(ResponseBlock)handler
{
    comment = [comment stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    comment = [comment stringByReplacingOccurrencesOfString:@"\\u" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\\" withString:@"'"];
    comment = [comment stringByReplacingOccurrencesOfString:@"/" withString:@"'"];
    comment = [comment stringByReplacingOccurrencesOfString:@"\b" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\f" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    comment = [comment stringByReplacingOccurrencesOfString:@"\v" withString:@" "];
    
    NSString *path = [NSString stringWithFormat:_commentPath, mediaId];
    NSString *csfToken = [ILSIGSessionManager sharedInstance].csfToken;
    NSString *signedBodyString = [NSString stringWithFormat:@"{\"comment_text\":\"%@\",\"_csrftoken\":\"%@\"}", comment, csfToken];
    NSString *resultString = @"";
    resultString = [resultString stringByAppendingString:[[myHac(signedBodyString) stringByAppendingString:@"."] stringByAppendingString:signedBodyString]];
    NSDictionary *param = @{@"signed_body":resultString, @"ig_sig_key_version":@(_Ig_sig_key_version)};
    NSMutableURLRequest *req = [self _buildNativeIGMultipartRequestWithPath:path param:param];
    ILSInstagramNetworkOperation *op = [[ILSInstagramNetworkOperation alloc] initWithRequest:req];
    op.responseHanlder = handler;
    [self.operationQueue addOperation:op];
    return op;
}

- (void)cancelAll
{
    [self.operationQueue cancelAllOperations];
}

@end

@implementation TimeIntervalOperationQueue

- (instancetype)initWithTimeInterval:(NSTimeInterval)time
{
    self = [super init];
    if (self) {
        self.timeInterval = time;
    }
    return self;
}

- (void)addOperation:(NSOperation *)op
{
    _opCount ++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_opCount * self.timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super addOperation:op];
    });
}

@end
