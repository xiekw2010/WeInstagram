//
//  ILSINSWebViewController.h
//  kxieINSDemo
//
//  Created by Kaiwei Xie on 12/12/12.
//  Copyright (c) 2012 Kaiwei Xie. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The loginViewController for Instagram, just use below method to login
    
    showInstagramLoginViewControllerFrom:(UIViewController *)from instagramRedirectURI:(NSString *)redirectURI instagramSecret:(NSString *)secret;
 
    if you wanna have a custom LoginViewController, then follow the steps below:
    
    1. init a ILSIGLoginViewController instance like loginVC
 
    2. set the instagramSecret, instagramRedirectURI, and set autoDismiss to NO
    
    3. push the loginVC from you custom LoginViewController
 
    4. At where you present your custom LoginViewController to register the notification "kInstagramUserDidLoginNotification", in register method to dismiss your custom LoginViewController
 */
@interface ILSIGLoginViewController : UIViewController

/**
 *  Example secret = 708d95d99a58482e8bd9122263f994b5;
    redirectURI = http://cosmothemes.com/instagram/
 */
@property (nonatomic, strong) NSString *instagramSecret;
@property (nonatomic, strong) NSString *instagramRedirectURI;
@property (nonatomic, assign) BOOL autoDismiss;

+ (void)showInstagramLoginViewControllerFrom:(UIViewController *)from instagramRedirectURI:(NSString *)redirectURI instagramSecret:(NSString *)secret;

@end

@interface LoginStatusView : UIView

@property (nonatomic, copy) dispatch_block_t clickBlock;
@property (nonatomic, strong) UIButton *refreshButton;

- (void)startAnimating:(NSString *)title;
- (void)stopAnimating:(NSString *)title;

@end
