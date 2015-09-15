//
//  ILSINSRecursiveDownloadOperation.h
//  ILSINSInstaFollower
//
//  Created by xiekw on 13-8-26.
//  Copyright (c) 2013年 Kaiwei Xie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ResponseBlock)(id response, NSError *error);

typedef enum {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodDelete,
}HttpMethod;


@interface ILSInstagramNetworkOperation : NSOperation

- (id)initWithURL:(NSURL *)url timeOut:(float)timeout;
- (id)initWithURL:(NSURL *)url timeOut:(float)timeout withMethod:(HttpMethod)method httpBody:(NSString *)body;
- (id)initWithRequest:(NSURLRequest *)request;

@property (nonatomic, copy) ResponseBlock responseHanlder;

@end

