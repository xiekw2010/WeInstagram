//
//  ILSINSRecursiveDownloadOperation.m
//  ILSINSInstaFollower
//
//  Created by xiekw on 13-8-26.
//  Copyright (c) 2013年 Kaiwei Xie. All rights reserved.
//

#import "ILSInstagramNetworkOperation.h"
#import "ILSInstagramHeader.h"

NSString * const kILSINSRecursiveDownloadOperationDone = @"ils.fa.kILSINSRecursiveDownloadOperationDone";

//static inline BOOL checkAccessTokenExpired(id jsonFile)
//{
//    //here we don't use the oauth login
//    return NO;
////    NSString *ifAcecessExpired = [jsonFile valueForKeyPath:@"meta.error_type"];
////    if (ifAcecessExpired) {
////        if ([ifAcecessExpired isEqualToString:@"OAuthAccessTokenException"] || [ifAcecessExpired isEqualToString:@"OAuthClientException"]) {
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [[ILSIGSessionManager sharedInstance] didDeleteUserId:[ILSIGSessionManager sharedInstance].userId];
////            });
////            return YES;
////        }
////    }
////    return NO;
//}


@interface ILSInstagramNetworkOperation ()

@property (nonatomic, strong) NSMutableURLRequest *requset;

@end

@implementation ILSInstagramNetworkOperation

NSString *httpMethod(HttpMethod type){
    NSString *result;
    switch (type) {
        case HttpMethodDelete:
            result = @"DELETE";
            break;
        case HttpMethodGet:
            result = @"GET";
            break;
        case HttpMethodPost:
            result = @"POST";
            break;
        default:
            break;
    }
    return result;
}

- (id)initWithURL:(NSURL *)url timeOut:(float)timeout
{
    return [self initWithURL:url timeOut:timeout withMethod:HttpMethodGet httpBody:nil];
}

- (id)initWithRequest:(NSURLRequest *)request
{
    if (self = [super init]) {
        self.requset = [request mutableCopy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url timeOut:(float)timeout withMethod:(HttpMethod)method httpBody:(NSString *)body
{
    if (self = [super init]) {
        self.requset = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
        self.requset.HTTPMethod = httpMethod(method);

        if (method == HttpMethodPost) {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [self.requset setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
            [self.requset setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return self;
}

- (void)main
{
    NSError *loadError;
    NSError *jsonError;
    NSData *infoData;
    id jsonFile;
    NSURLResponse *reponse;
    
    infoData = [NSURLConnection sendSynchronousRequest:self.requset returningResponse:&reponse error:&loadError];
    if (!loadError) {
        jsonFile = [NSJSONSerialization JSONObjectWithData:infoData options:kNilOptions error:&jsonError];
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.responseHanlder) {
                    self.responseHanlder(nil, jsonError);
                }
            });
        }else {
            NSString *result = [[jsonFile valueForKeyPath:@"meta.code"] stringValue];
            NSString *navtiveMessage = jsonFile[@"message"];
            NSString *status = jsonFile[@"status"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result && !navtiveMessage && !status) {
                    if (self.responseHanlder) {
                        self.responseHanlder(jsonFile, nil);
                    }
                }else  if ([result isKindOfClass:[NSString class]] && ![result isEqualToString:@"200"]) {
                    if (self.responseHanlder) {
                        self.responseHanlder(nil, [NSError errorWithDomain:@"ML.InstaLikes" code:[result integerValue] userInfo:nil]);
                    }
                }else  if ([navtiveMessage isKindOfClass:[NSString class]] && [navtiveMessage isEqualToString:@"login_required"]) {
                    [[ILSInstagram sharedInstagram] ooLogin];
                    if (self.responseHanlder) {
                        self.responseHanlder(nil, [NSError errorWithDomain:@"ML.InstaLikes" code:kInstagramErrorCodeInvalidUsernameAndPassword userInfo:@{NSLocalizedDescriptionKey : navtiveMessage}]);
                    }
                }else  if ([navtiveMessage isKindOfClass:[NSString class]] && [navtiveMessage rangeOfString:@"Invalid username"].length > 0) {
                    if (self.responseHanlder) {
                        self.responseHanlder(nil, [NSError errorWithDomain:@"ML.InstaLikes" code:kInstagramErrorCodeInvalidUsernameAndPassword userInfo:@{NSLocalizedDescriptionKey : navtiveMessage}]);
                    }
                }else  if ([navtiveMessage rangeOfString:@"checkpoint_required"].length > 0) {
                    if (self.responseHanlder) {
                        self.responseHanlder(nil, [NSError errorWithDomain:@"ML.InstaLikes" code:kInstagramErrorNeedLoginToInstagramVerified userInfo:@{NSLocalizedDescriptionKey : @"You need to login to Instagram and then login to this"}]);
                    }
                }else  if ([status isKindOfClass:[NSString class]] && [status isEqualToString:@"fail"]) {
                    if (self.responseHanlder) {
                        self.responseHanlder(nil, [NSError errorWithDomain:@"ML.InstaLikes" code:[result integerValue] userInfo:@{NSLocalizedDescriptionKey : navtiveMessage ? : @""}]);
                    }
                }else {
                    if (self.responseHanlder) {
                        self.responseHanlder(jsonFile, nil);
                    }
                }
            });
        }
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.responseHanlder) {
                self.responseHanlder(nil, loadError);
            }
        });
    }
}


@end

