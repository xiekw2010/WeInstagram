//
//  ILSINSWebViewController.m
//  kxieINSDemo
//
//  Created by Kaiwei Xie on 12/12/12.
//  Copyright (c) 2012 Kaiwei Xie. All rights reserved.
//

#import "ILSIGLoginViewController.h"
#import "ILSInstagramHeader.h"


#define KSomeErrorHappened NSLocalizedString(@"It is coming to some error now, you could go back and login again", nil)


@interface ILSIGLoginViewController ()<UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) LoginStatusView *statusView;
@property (nonatomic, strong) NSString *userName, *password;
@property (nonatomic, strong) UIImageView *navImageV;
@property (nonatomic, strong) UIButton *xButton;

@end

@implementation ILSIGLoginViewController

+ (void)showInstagramLoginViewControllerFrom:(UIViewController *)from instagramRedirectURI:(NSString *)redirectURI instagramSecret:(NSString *)secret
{
    ILSIGLoginViewController *loginVC = [[ILSIGLoginViewController alloc] init];
    loginVC.instagramSecret = secret;
    loginVC.instagramRedirectURI = redirectURI;
    loginVC.autoDismiss = YES;
    [from presentViewController:loginVC animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ILSIGSessionManager clearInstagramCookies];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
  
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.clipsToBounds = YES;

#define kStatusViewHeight 130
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kStatusViewHeight)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    
    self.statusView = [[LoginStatusView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.webView.frame), CGRectGetWidth(self.webView.frame), kStatusViewHeight)];
    
    __weak ILSIGLoginViewController *wself = self;
    self.statusView.clickBlock = ^() {
        [wself webRefresh:nil];
    };
    [self.view addSubview:self.statusView];
 
    [self webRefresh:nil];
    
    self.xButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.xButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 44), 0, 44, 44);
    [self.xButton setImage:[UIImage imageNamed:@"ilsinstagram.bundle/btn_close_normal.png"] forState:UIControlStateNormal];
    [self.xButton setImage:[UIImage imageNamed:@"ilsinstagram.bundle/btn_close_selected.png"] forState:UIControlStateHighlighted];
    [self.xButton addTarget:self action:@selector(backNow:) forControlEvents:UIControlEventTouchUpInside];
    if ([ILSIGSessionManager sharedInstance].isLogin) {
        [self.view addSubview:self.xButton];
    }
}

- (void)backNow:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)webRefresh:(id)sender
{
    assert(self.instagramRedirectURI != nil && self.instagramSecret != nil);
    
    [self.statusView startAnimating:NSLocalizedString(@"Loading login page, please wait...", nil)];
    
    
    NSString *authString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", self.instagramSecret, self.instagramRedirectURI];
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    [self.webView loadRequest:mRequest];
}


#pragma -mark webView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.statusView startAnimating:NSLocalizedString(@"Loading login page, please wait...", nil)];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
///* Get the user's password
    NSString *currentURLString = webView.request.URL.absoluteString;
    NSString *passcodeURLContainer = @"accounts/login/?next=";
    if ([currentURLString rangeOfString:passcodeURLContainer].length != 0 && [request.HTTPMethod isEqualToString:@"POST"]) {
        NSString *str = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (str && str.length > 0) {
            NSArray *firstStringArray = [str componentsSeparatedByString:@"&"];
            for (NSString *secondString in firstStringArray) {
                if ([secondString rangeOfString:@"username"].length > 0) {
                    NSArray *nameArray = [secondString componentsSeparatedByString:@"="];
                    self.userName = nameArray[1];
                }else if ([secondString rangeOfString:@"password"].length > 0) {
                    NSArray *passwordArray = [secondString componentsSeparatedByString:@"="];
                    self.password = passwordArray[1];
                }
            }
        }
    }
    NSString *urlString = request.URL.absoluteString;
    NSRange range = [urlString rangeOfString:@"access_token="];
    if (range.location != NSNotFound) {
        NSString *accessTokenKey = [urlString substringFromIndex:range.location + 13];
        NSArray *userIdsAndTokens = [accessTokenKey componentsSeparatedByString:@"."];
        NSString *userid = userIdsAndTokens[0];

        if (accessTokenKey.length > 0 && userid.length > 0) {
            
            [[ILSIGSessionManager sharedInstance] updateAccessToken:accessTokenKey userId:userid];
            [[ILSIGSessionManager sharedInstance] saveUserName:self.userName password:self.password];
            [[ILSInstagram sharedInstagram] ooLogin];
            
            [[ILSInstagram sharedInstagram] instagramDetailInfoForUserId:userid compeletionHandler:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramUserDidLoginNotification object:nil];
            
            if (self.autoDismiss) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }

        }else {
            [self.statusView stopAnimating:KSomeErrorHappened];
        }
        return NO;
    }
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    if ([html rangeOfString:@"error_type"].length > 0 && [html rangeOfString:@"error_message"].length > 0) {
        [self.statusView stopAnimating:KSomeErrorHappened];
    }else {
        [self.statusView stopAnimating:NSLocalizedString(@"Please make sure to log in with Instagram username(NOT email address).", nil)];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError %@", error);
    if (error) {
        [self.statusView stopAnimating:KSomeErrorHappened];
    }
}


@end

@interface LoginStatusView ()

@property (nonatomic, strong) UIActivityIndicatorView *acv;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LoginStatusView

#define kRefreshButtonWidth 44
#define kTitleButtonHeight 50

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5)];
        lineV.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1];
        [self addSubview:lineV];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.bounds), kTitleButtonHeight)];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:self.titleLabel];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.refreshButton setImage:[UIImage imageNamed:@"ilsinstagram.bundle/refresh_normal.png"] forState:UIControlStateNormal];
        [self.refreshButton setImage:[UIImage imageNamed:@"ilsinstagram.bundle/refresh_selected.png"] forState:UIControlStateHighlighted];
        self.refreshButton.frame = CGRectMake((CGRectGetWidth(self.bounds) - kRefreshButtonWidth) * 0.5, (CGRectGetHeight(self.bounds) - kTitleButtonHeight - kRefreshButtonWidth) * 0.5 + CGRectGetMaxY(self.titleLabel.frame), kRefreshButtonWidth, kRefreshButtonWidth);
        [self.refreshButton addTarget:self action:@selector(refreshButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.acv.frame = self.refreshButton.frame;
    }
    return self;
}

- (void)refreshButtonClicked:(id)sender
{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)startAnimating:(NSString *)title
{
    self.titleLabel.text = title;
    [self.refreshButton removeFromSuperview];
    [self addSubview:self.acv];
    [self.acv startAnimating];
}

- (void)stopAnimating:(NSString *)title
{
    self.titleLabel.text = title;
    [self.acv stopAnimating];
    [self.acv removeFromSuperview];
    [self addSubview:self.refreshButton];
}

@end
