//
//  ViewController.m
//  ScanQRCodeDemo
//  
//  Created by KentonYu on 15/11/27.
//  Copyright © 2015年 KentonYu. All rights reserved.
//

#import "KBScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KBWebViewController.h"

#define SCREENSIZE [[UIScreen mainScreen] bounds].size
static const CGFloat kScanSize           = 220.0f;
static const CGFloat kScanFrameOriginY   = 100.0f;
static const CGFloat kDescriptionOriginY = 50.0f;
static CGFloat kdirection                = 1;

@interface KBScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession           * session;
@property (nonatomic, strong) AVCaptureDevice            *device;
@property (nonatomic, strong) AVCaptureDeviceInput       *input;
@property (nonatomic, strong) AVCaptureMetadataOutput    * output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) UILabel                    *descriptionLabel;
@property (nonatomic, strong) UIImageView                *lineImageView;
@property (nonatomic, strong) NSTimer                    *timer;

@end

@implementation KBScanQRCodeViewController

+ (instancetype)viewControllerWithNavgationTitle:(NSString *)title descriptionText:(NSString *)description{
    KBScanQRCodeViewController *controller = self.new;
    if (controller) {
        controller.navgationTitle  = title;
        controller.descriptionText = description;
    }
    return controller;
}

- (instancetype)init{
    self = [self initWithNavgationTitle:@"扫描二维码" descriptionText:@"将二维码放入框内，即可自动扫描"];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithNavgationTitle:(NSString *)title descriptionText:(NSString *)description{
    self = [super init];
    if (self) {
        self.navgationTitle = title;
        self.descriptionText = description;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.navgationTitle;
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机",@"测试"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self p_setUpQRCodeCamera];
    [self p_setUpUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [self p_setUpPreviewLayer];
    [self p_startRunning];
}

- (void)viewDidDisappear:(BOOL)animated{
    [self p_stopRunning];
}

- (void)p_setUpUI{
    
    self.view.backgroundColor=[UIColor clearColor];
    
    UIView *darkView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREENSIZE.width, SCREENSIZE.height-64)];
    darkView.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.700];
    [self.view addSubview:darkView];
    
    darkView.layer.mask = [self p_createMaskShapeLayer:darkView.bounds];

    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = self.descriptionText;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake((SCREENSIZE.width - self.descriptionLabel.frame.size.width)/2.0f, kScanFrameOriginY + kScanSize + kDescriptionOriginY, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
    [darkView addSubview:self.descriptionLabel];
//    (SCREENSIZE.width-ScanSize)/2.0f+ScanSize, ScanFrameOriginY
    [self p_drawLineWithStartPoint:CGPointMake((SCREENSIZE.width-kScanSize)/2.0f+kScanSize, kScanFrameOriginY) endPoint:CGPointMake((SCREENSIZE.width-kScanSize)/2.0f+kScanSize, kScanFrameOriginY+50)];
    
    self.lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREENSIZE.width-kScanSize)/2+5, kScanFrameOriginY + 64 + kScanSize/2, kScanSize-10, 2)];
    self.lineImageView.image = [UIImage imageNamed:@"ScanLine"];
    [self.view addSubview:self.lineImageView];
}

- (void)p_drawLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:end];
    [[UIColor whiteColor] setStroke];
    [bezierPath setLineWidth:2.0f];
    [bezierPath stroke];
}

- (void)p_animateLine
{
    if (self.lineImageView.frame.origin.y <= (kScanFrameOriginY+64)) {
        kdirection = 1;
    }
    if (self.lineImageView.frame.origin.y >= (kScanFrameOriginY+kScanSize+64)) {
        kdirection = -1;
    }
    self.lineImageView.frame = CGRectOffset(self.lineImageView.frame, 0, kdirection);
}

//生成蒙版ShapeLayer
- (CAShapeLayer *)p_createMaskShapeLayer:(CGRect)rect{
    UIBezierPath* BezierPath = [UIBezierPath bezierPath];
    [BezierPath moveToPoint: CGPointMake((SCREENSIZE.width-kScanSize)/2.0f+kScanSize, kScanFrameOriginY)];
    [BezierPath addLineToPoint: CGPointMake((SCREENSIZE.width-kScanSize)/2.0f, kScanFrameOriginY)];
    [BezierPath addLineToPoint: CGPointMake((SCREENSIZE.width-kScanSize)/2.0f, kScanFrameOriginY+kScanSize)];
    [BezierPath addLineToPoint: CGPointMake((SCREENSIZE.width-kScanSize)/2.0f+kScanSize, kScanFrameOriginY+kScanSize)];
    [BezierPath addLineToPoint: CGPointMake((SCREENSIZE.width-kScanSize)/2.0f+kScanSize, kScanFrameOriginY)];
    [BezierPath closePath];
    [BezierPath moveToPoint: CGPointMake(rect.size.width, 0)];
    [BezierPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [BezierPath addLineToPoint: CGPointMake(0, rect.size.height)];
    [BezierPath addLineToPoint: CGPointMake(0, 0)];
    [BezierPath addLineToPoint: CGPointMake(rect.size.width, 0)];
    [BezierPath closePath];
    CAShapeLayer *shapeLayer=[CAShapeLayer layer];
    [shapeLayer setPath:BezierPath.CGPath];
    return shapeLayer;
}


- (void)p_setUpQRCodeCamera{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        /*创建Session*/
        _session = [[AVCaptureSession alloc]init];
        
        //音视频质量
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        /* 定义所使用的 Device */
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        /*获取其input*/
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        //添加到当前会话
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        
        _output = [[AVCaptureMetadataOutput alloc]init];
        
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // 条码类型 AVMetadataObjectTypeQRCode
        if ([_session canAddOutput:self.output]) {
            [_session addOutput:self.output];
        }
        // 条码类型 AVMetadataObjectTypeQRCode 支持所有类型  必须先add进session 再设置types
        //    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        _output.metadataObjectTypes = @[
                                        AVMetadataObjectTypeUPCECode,
                                        AVMetadataObjectTypeCode39Code,
                                        AVMetadataObjectTypeCode39Mod43Code,
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode93Code,
                                        AVMetadataObjectTypeCode128Code,
                                        AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode
                                        ];
        //设置可识别扫描的区域 默认是（0,0,1,1）整个rootlayer。（0.5，0.5，0.5，0.5）是代表左下角的四分之一。
        CGRect visibleMetadataOutputRect = CGRectMake(
                                                      ((SCREENSIZE.width-kScanSize)/2.0f)/SCREENSIZE.width,
                                                      kScanFrameOriginY/(SCREENSIZE.height-64),
                                                      kScanSize/(SCREENSIZE.height-64),
                                                      kScanSize/SCREENSIZE.width
                                                      );
        _output.rectOfInterest = visibleMetadataOutputRect;
    });
    
}

- (void)p_setUpPreviewLayer{
    /*定义相机的“取景器”*/
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    [rootLayer insertSublayer:previewLayer atIndex:0];
}

- (void)p_startRunning{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(p_animateLine) userInfo:nil repeats:YES];
    [_session startRunning];
}

- (void)p_stopRunning{
    [self.timer invalidate];
    [_session stopRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self p_stopRunning];
        [self.timer invalidate];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        AudioServicesPlaySystemSound(1109);
        if ([[stringValue substringToIndex:7] isEqualToString:@"http://"]||[[stringValue substringToIndex:8] isEqualToString:@"https://"]) {
            NSLog(@"跳转web页面");
            KBWebViewController *target = [[KBWebViewController alloc] init];
            target.strUrl = stringValue;
            [self.navigationController pushViewController:target animated:YES];
        } else {
            //回调block 自定义操作
            self.captureOutputBlock(self, stringValue);
        }
    }
}

- (void)dealloc{
    NSLog(@"delloc the ScanQRCodeViewController");
}
@end
