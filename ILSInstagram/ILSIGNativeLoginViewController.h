//
//  ILSIGNativeLoginViewController.h
//  MoreLikers
//
//  Created by xiekw on 8/18/14.
//  Copyright (c) 2014 周和生. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LoginErrorHandler)(NSError *error);

@interface ILSIGNativeLoginViewController : UIViewController

@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIActivityIndicatorView *acv;
@property (nonatomic, strong) UIScrollView *backSV;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, copy) LoginErrorHandler errorHandler;

@property (nonatomic, strong) UIView *lineV1;
@property (nonatomic, strong) UIView *lineV2;
@property (nonatomic, strong) UIView *lineV3;


@end


@interface ILSIGNativeLoginApperance : NSObject

+ (instancetype)sharedApperance;

@property (nonatomic, strong) NSString *imageBundleName;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UIColor *backgoundColor;

@end