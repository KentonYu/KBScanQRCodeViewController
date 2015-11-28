//
//  WebViewController.m
//  ScanQRCodeDemo
//
//  Created by KentonYu on 15/11/29.
//  Copyright © 2015年 yukaibo. All rights reserved.
//

#import "KBWebViewController.h"

@interface KBWebViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation KBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    NSURL * url            = [NSURL URLWithString:self.strUrl];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
//    [self.webView loadRequest:request];
    
    self.webView.scalesPageToFit = YES;
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
