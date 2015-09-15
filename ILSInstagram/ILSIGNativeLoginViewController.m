//
//  ILSIGNativeLoginViewController.m
//  MoreLikers
//
//  Created by xiekw on 8/18/14.
//  Copyright (c) 2014 周和生. All rights reserved.
//

#import "ILSIGNativeLoginViewController.h"
#import "ILSInstagram.h"
#import "ILSIGSessionManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ILSInstagramHeader.h"

static inline NSString *myHac(NSString *from)
{
    NSString *androidKey = @"initWithURL";
    
    const char *cKey  = [androidKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [from cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    Byte *testByte = (Byte *)[HMAC bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[HMAC length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%02x",(testByte[i]&0xff)];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

@interface ILSIGNativeLoginViewController ()<UITextFieldDelegate>
{
    BOOL _downKeyboard;
    NSString *_imageBundleName;
}

@end

@implementation ILSIGNativeLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_scrollKeyBoard) name:UIKeyboardWillShowNotification object:nil];
        self.titleView = [UILabel new];
        self.imageView = [UIImageView new];
        self.errorLabel = [UILabel new];
        self.imageLabel = [UILabel new];
        self.usernameField = [UITextField new];
        self.passwordField = [UITextField new];
        self.acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.backSV = [UIScrollView new];
        self.backButton = [UIButton new];
        _imageBundleName = [ILSIGNativeLoginApperance sharedApperance].imageBundleName ? : @"ilsinstagram.bundle";
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)_scrollKeyBoard
{
    if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()) {
        BOOL is480 = (fabs([UIScreen mainScreen].bounds.size.height - 480.0) < 0.001);
        if (is480) {
            [self.backSV setContentOffset:CGPointMake(0, 80) animated:YES];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ILSIGSessionManager clearInstagramCookies];
    
    self.view.backgroundColor = [UIColor whiteColor];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    self.backSV.showsVerticalScrollIndicator = NO;
    self.backSV.backgroundColor = [ILSIGNativeLoginApperance sharedApperance].backgoundColor ? : [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.00];
    
    
    self.backSV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backSV];
    

    self.titleView.text = NSLocalizedString(@"Login now", nil);
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.backgroundColor = [UIColor clearColor];
    
    self.titleView = [ILSIGNativeLoginApperance sharedApperance].titleView ? : self.titleView;
    
    self.titleView.frame = CGRectMake(0, 0, 150, 44);
    self.navigationItem.titleView = self.titleView;
    
    CGFloat imageLabelFont = 14.0;
    CGFloat textFieldFont = 17.0;
    CGFloat errorLabelFont = 14.0;

    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        imageLabelFont = 28.0;
        textFieldFont = 28.0;
        errorLabelFont = 18.0;
    }
    
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/pic3@2x.jpg", _imageBundleName]];
    
    self.imageView = [ILSIGNativeLoginApperance sharedApperance].imageView ? : self.imageView;
    

    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backSV addSubview:self.imageView];
    
    
    self.imageLabel.textColor = [UIColor whiteColor];
    self.imageLabel.backgroundColor = [UIColor clearColor];
    self.imageLabel.font = [UIFont boldSystemFontOfSize:imageLabelFont];
    self.imageLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    self.imageLabel.shadowOffset = CGSizeMake(0, 1);
    self.imageLabel.text = NSLocalizedString(@"Log into your Instagram account", nil);
    [self.backSV addSubview:self.imageLabel];
    self.imageLabel.textAlignment = NSTextAlignmentCenter;
    
    self.imageLabel = [ILSIGNativeLoginApperance sharedApperance].imageLabel ? : self.imageLabel;
    
    self.usernameField.clearButtonMode = UITextFieldViewModeAlways;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.rightViewMode = UITextFieldViewModeAlways;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.placeholder = NSLocalizedString(@"Username(NOT email)", nil);
    
    
    
    self.passwordField.secureTextEntry = YES;
    self.passwordField.placeholder = NSLocalizedString(@"Password", nil);
    self.usernameField.returnKeyType = self.passwordField.returnKeyType = UIReturnKeyDone;
    self.usernameField.delegate =  self.passwordField.delegate = self;
    self.usernameField.contentVerticalAlignment = self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;


    
    
    self.usernameField.leftViewMode = self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/icon_account.png", _imageBundleName]]];
    self.passwordField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/icon_password.png", _imageBundleName]]];
    self.usernameField.backgroundColor = self.passwordField.backgroundColor = [UIColor whiteColor];
    self.usernameField.font = self.passwordField.font = [UIFont systemFontOfSize:textFieldFont];
    
    [self.backSV addSubview:self.usernameField];
    [self.backSV addSubview:self.passwordField];
    
    self.lineV1 = [[UIView alloc] init];
    [self.backSV addSubview:self.lineV1];
    self.lineV2 = [[UIView alloc] init];
    [self.backSV addSubview:self.lineV2];
    self.lineV3 = [[UIView alloc] init];
    [self.backSV addSubview:self.lineV3];
    self.lineV1.backgroundColor = self.lineV2.backgroundColor = self.lineV3.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:230.0/255.0 blue:233.0/255.0 alpha:1];
    

    self.errorLabel.textColor = [UIColor colorWithRed:229.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1];
    self.errorLabel.backgroundColor = [UIColor clearColor];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.font = [UIFont systemFontOfSize:errorLabelFont];
    [self.backSV addSubview:self.errorLabel];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedDescending) {
        self.acv.frame = CGRectMake(0, 0, 20, 20);
    }else {
        self.acv.frame = CGRectMake(0, 0, 40, 40);
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.acv];
    
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    if (self.navigationController.viewControllers.count > 1) {
        [self.backButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/btn_back_normal.png", _imageBundleName]] forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/btn_back_selected.png", _imageBundleName]] forState:UIControlStateHighlighted];
    }else {
        [self.backButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/btn_close_normal.png", _imageBundleName]] forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/btn_close_selected.png", _imageBundleName]] forState:UIControlStateHighlighted];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -32, 0, 0);
    }
    [self.backButton addTarget:self action:@selector(_back) forControlEvents:UIControlEventTouchUpInside];
    [self.usernameField becomeFirstResponder];
    [self _scrollKeyBoard];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat imageViewHeight = 150.0;
    CGFloat imageLabelHeight = 40.0;
    CGFloat textFieldHeight = 40.0;
    CGFloat textUpYoffset = 20.0f;
    CGFloat lineV2Xoffset = 50.0;
    CGFloat errorLabelHeight = 40.0;
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        imageViewHeight = 320.0;
        imageLabelHeight = 90.0;
        textFieldHeight = 70.0;
        textUpYoffset = 40.0;
        lineV2Xoffset = 150.0;
        errorLabelHeight = 80.0;
    }
    
    self.backSV.frame = self.view.bounds;
    CGFloat extraHeight = self.view.bounds.size.width > self.view.bounds.size.height ? 200 : 50;
    self.backSV.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + extraHeight);
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        self.backSV.contentOffset = CGPointMake(0, 200);
    }

    self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), imageViewHeight);
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        self.imageView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), imageViewHeight);
    }
    
    self.imageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) - imageLabelHeight, CGRectGetWidth(self.imageView.frame), imageLabelHeight);
    
    self.usernameField.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + textUpYoffset, CGRectGetWidth(self.view.bounds), textFieldHeight);
    self.passwordField.frame = CGRectMake(CGRectGetMinX(self.usernameField.frame), CGRectGetMaxY(self.usernameField.frame), CGRectGetWidth(self.view.bounds), textFieldHeight);
    
    self.lineV1.frame = CGRectMake(CGRectGetMinX(self.usernameField.frame), CGRectGetMinY(self.usernameField.frame), CGRectGetWidth(self.usernameField.frame), 0.5);
    self.lineV2.frame = CGRectMake(lineV2Xoffset, CGRectGetMaxY(self.usernameField.frame), CGRectGetWidth(self.usernameField.frame)- lineV2Xoffset, 0.5);
    self.lineV3.frame = CGRectMake(CGRectGetMinX(self.usernameField.frame), CGRectGetMaxY(self.passwordField.frame), CGRectGetWidth(self.usernameField.frame), 0.5);
    
    self.errorLabel.frame =  CGRectMake(CGRectGetMinX(self.usernameField.frame), CGRectGetMaxY(self.passwordField.frame), CGRectGetWidth(self.usernameField.frame), errorLabelHeight);
    
}

- (void)_back
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)_setErrorLabelText:(NSString *)errorText
{
    self.errorLabel.text = errorText;
    [UIView animateWithDuration:0.5 animations:^{
        self.errorLabel.alpha = 1.0;
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        self.errorLabel.alpha = 0.0;
    }];
    _downKeyboard = NO;
    [self _scrollKeyBoard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _downKeyboard = YES;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!_downKeyboard) {
        return;
    }
    
    if ([self.acv isAnimating]) {
        return;
    }
    
    NSString *userName = self.usernameField.text;
    NSString *password = self.passwordField.text;
    if (userName.length == 0) {
        [self _setErrorLabelText:NSLocalizedString(@"UserName is empty", nil)];
        return;
    }
    if (password.length == 0) {
        [self _setErrorLabelText:NSLocalizedString(@"Password is empty", nil)];
        return;
    }
    
    [self.acv startAnimating];
    userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[ILSInstagram sharedInstagram] ooLoginUserName:userName password:password CompletionHandler:^(NSDictionary *userInfoDic, NSError *error) {
        [self.acv stopAnimating];
        if (error) {
            if (self.errorHandler) {
                self.errorHandler(error);
            }else {
                if (error.code == kInstagramErrorCodeInvalidUsernameAndPassword) {
                    [self _setErrorLabelText:NSLocalizedString(@"Invalid username or password", nil)];
                }else {
                    [self _setErrorLabelText:NSLocalizedString(@"Login failed", nil)];
                }
            }
        }else {
            userInfoDic = userInfoDic[@"logged_in_user"];
            NSString *userId = [userInfoDic[@"pk"] stringValue];
            NSDictionary *userInfo = @{@"profile_picture" : userInfoDic[@"profile_pic_url"], @"username" : userInfoDic[@"username"], @"id" : userId, @"full_name" : userInfoDic[@"full_name"]};
            NSString *accessToken = myHac(userId);
            
            [[ILSIGSessionManager sharedInstance] updateAccessToken:accessToken userId:userId];
            [[ILSIGSessionManager sharedInstance] setUserInfo:userInfo];
            [[ILSIGSessionManager sharedInstance] saveUserName:userName password:password];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramUserDidLoginNotification object:nil userInfo:nil];
            
        }
        NSLog(@"userinfo dic is %@ and error is %@", userInfoDic, error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation ILSIGNativeLoginApperance

+ (instancetype)sharedApperance
{
    static ILSIGNativeLoginApperance *__apperance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __apperance = [ILSIGNativeLoginApperance new];
    });
    return __apperance;
}




@end
