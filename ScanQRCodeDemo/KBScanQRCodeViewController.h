//
//  ViewController.h
//  ScanQRCodeDemo
//  https://github.com/KentonYu/KBScanQRCodeViewController
//  Created by KentonYu on 15/11/27.
//  Copyright © 2015年 yukaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface KBScanQRCodeViewController : UIViewController

@property (nonatomic, copy, readwrite) NSString *navgationTitle;
@property (nonatomic, copy, readwrite) NSString *descriptionText;
@property (nonatomic, copy, readwrite) void(^captureOutputBlock)(KBScanQRCodeViewController *, NSString *);

+ (instancetype)viewControllerWithNavgationTitle:(NSString *)title descriptionText:(NSString *)description;

- (instancetype)initWithNavgationTitle:(NSString *)title descriptionText:(NSString *)description;
@end
NS_ASSUME_NONNULL_END
