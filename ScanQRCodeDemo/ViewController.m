//
//  ViewController.m
//  ScanQRCodeDemo
//
//  Created by KentonYu on 15/11/28.
//  Copyright © 2015年 yukaibo. All rights reserved.
//

#import "ViewController.h"
#import "KBScanQRCodeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描二维码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(p_clickRightBarButton:)];
}

- (void)p_clickRightBarButton:(UIBarButtonItem *)sender{
    KBScanQRCodeViewController *target = [[KBScanQRCodeViewController alloc] init];
    target.captureOutputBlock = ^(KBScanQRCodeViewController *scanController, NSString *captureString){
        [scanController.navigationController popViewControllerAnimated:YES];
        NSLog(@"%@",captureString);
    };
    [self.navigationController pushViewController:target animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
