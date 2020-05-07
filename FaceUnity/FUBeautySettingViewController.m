//
//  FUBeautySettingViewController.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautySettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <FURenderer.h>
#import "FUManager.h"
#import "FULiveModel.h"
#import "FUCamera.h"
#import "FUOpenGLView.h"
#import "FUCaptureManager.h"
#import "FUAPIDemoBarManager.h"

#define iPhoneXStyle ((KScreenWidth == 375.f && KScreenHeight == 812.f ? YES : NO) || (KScreenWidth == 414.f && KScreenHeight == 896.f ? YES : NO))
#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface FUBeautySettingViewController () <FUCameraDelegate, FUCameraDataSource>
{
    float imageW;
    float imageH;
}

@property (nonatomic, strong) FUCamera *mCamera;
@property (nonatomic, strong) FUOpenGLView *renderView;

@property (nonatomic, assign) int orientation;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation FUBeautySettingViewController

- (void)dealloc
{
    [self stopListeningDirectionOfDevice];
    NSLog(@"----界面销毁");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.renderView = [[FUOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.renderView];

    //重置曝光值为0
    [self.mCamera setExposureValue:0];

    /* 后台监听 */
    [self addObserver];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = YES;

    [FUAPIDemoBarManager.sharedManager showInView:self.view];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScreenAction:)];
    [self.renderView addGestureRecognizer:tap];
    //    self.renderView.contentMode = FUOpenGLViewContentModeScaleAspectFit;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.mCamera startCapture];
    [self.mCamera changeSessionPreset:AVCaptureSessionPreset1280x720];
    /* 监听屏幕方向 */
    [self startListeningDirectionOfDevice];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.mCamera resetFocusAndExposureModes];
    [self.mCamera stopCapture];

    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [FURenderer onCameraChange];
    /* 监听屏幕方向 */
    [self stopListeningDirectionOfDevice];
}

#pragma mark -  UI事件
- (void)touchScreenAction:(UITapGestureRecognizer *)tap
{
    if (tap.view == self.renderView) {
        [self.mCamera cameraChangeModle:FUCameraModelChangeless];
        CGPoint center = [tap locationInView:self.renderView];

        if (self.renderView.contentMode == FUOpenGLViewContentModeScaleToFill) {
            float scal2 = imageH / imageW;

            float apaceLead = (self.view.bounds.size.height / scal2 - self.view.bounds.size.width ) / 2;
            float imagecW = self.view.bounds.size.width + 2 * apaceLead;
            center.x = center.x + apaceLead;

            if (center.y > 0) {
                CGPoint point = CGPointMake(center.y / self.view.bounds.size.height, self.mCamera.isFrontCamera ? center.x / imagecW : 1 - center.x / imagecW);
                [self.mCamera focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:point monitorSubjectAreaChange:YES];
            }
        } else if (self.renderView.contentMode == FUOpenGLViewContentModeScaleAspectFit) {
            float scal2 = imageH / imageW;

            float apaceTOP = (self.view.bounds.size.height - self.view.bounds.size.width * scal2) / 2;
            float imagecH = self.view.bounds.size.height - 2 * apaceTOP;
            center.y = center.y - apaceTOP;

            if (center.y > 0) {
                CGPoint point = CGPointMake(center.y / imagecH, self.mCamera.isFrontCamera ? center.x / self.view.bounds.size.width : 1 - center.x / self.view.bounds.size.width);
                [self.mCamera focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:point monitorSubjectAreaChange:YES];
            }
        } else {
            CGPoint point = CGPointMake(center.y / self.view.bounds.size.height, self.mCamera.isFrontCamera ? center.x / self.view.bounds.size.width : 1 - center.x / self.view.bounds.size.width);
            [self.mCamera focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:point monitorSubjectAreaChange:YES];
        }
    }
}

#pragma mark -  Loading

- (FUCamera *)mCamera
{
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] init];
        _mCamera.delegate = self;
        _mCamera.dataSource = self;
    }
    return _mCamera;
}

#pragma mark - FUCameraDelegate

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    imageW = CVPixelBufferGetWidth(pixelBuffer);
    imageH = CVPixelBufferGetHeight(pixelBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];

    [self.renderView displayPixelBuffer:pixelBuffer];

    //    [self.renderView displayPixelBuffer:pixelBuffer withLandmarks:cetera count:2 MAX:NO];
    //    static float posterLandmarks[239* 2];
    //    [FURenderer getFaceInfo:0 name:@"landmarks" pret:posterLandmarks number:239* 2];
    //    [self.renderView displayPixelBuffer:pixelBuffer withLandmarks:posterLandmarks count:239* 2 MAX:NO];
}

#pragma mark - FUCameraDataSource
- (CGPoint)faceCenterInImage:(FUCamera *)camera
{
    CGPoint center = CGPointMake(-1, -1);
    BOOL isHaveFace = [[FUManager shareManager] isTracking];

    if (isHaveFace) {
        center = [self cameraFocusAndExposeFace];
    }
    return center;
}

- (CGPoint)cameraFocusAndExposeFace
{
    NSLog(@"------人脸对焦----");
    static float posterLandmarks[239 * 2];
    int ret = [FURenderer getFaceInfo:0 name:@"landmarks" pret:posterLandmarks number:75 * 2];
    if (ret == 0) {
        ret = [FURenderer getFaceInfo:0 name:@"landmarks_new" pret:posterLandmarks number:239 * 2];
        if (ret == 0) {
            memset(posterLandmarks, 0, sizeof(float) * 239 * 2);
        }
    }

    CGPoint center = [self getCenterFromeLandmarks:posterLandmarks];

    return CGPointMake(center.y / imageH, self.mCamera.isFrontCamera ? center.x / imageW : 1 - center.x / imageW);
}


- (CGPoint)getCenterFromeLandmarks:(float *)Landmarks
{
    float min_x = 10000, min_y = 10000, max_x = 0, max_y = 0;
    for (int i = 0; i < 75; i++) {
        min_x = MIN(min_x, Landmarks[i * 2 + 0]);
        min_y = MIN(min_y, Landmarks[i * 2 + 1]);
        max_x = MAX(max_x, Landmarks[i * 2 + 0]);
        max_y = MAX(max_y, Landmarks[i * 2 + 1]);
    }
    CGPoint center = CGPointMake((min_x + max_x) / 2.0, (min_y + max_y) / 2.0);
    return center;
}

#pragma mark -  Observer

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive
{
    if (self.navigationController.visibleViewController == self) {
        [self.mCamera stopCapture];
        //        self.mCamera = nil;
    }
}


- (void)didBecomeActive
{
    if (self.navigationController.visibleViewController == self) {
        [self.mCamera startCapture];
    }
}

#pragma mark -  方向监听

/// 开启屏幕旋转的检测
- (void)startListeningDirectionOfDevice
{
    if (self.motionManager == nil) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    self.motionManager.deviceMotionUpdateInterval = 0.3;

    // 判断设备传感器是否可用
    if (self.motionManager.deviceMotionAvailable) {
        // 启动设备的运动更新，通过给定的队列向给定的处理程序提供数据。
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    } else {
        [self setMotionManager:nil];
    }
}

- (void)stopListeningDirectionOfDevice
{
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    int orientation = 0;

    if (fabs(y) >= fabs(x)) {// 竖屏
        if (y < 0) {
            orientation = 0;
        }
        else {
            orientation = 2;
        }
    }
    else { // 横屏
        if (x < 0) {
            orientation = 1;
        }
        else {
            orientation = 3;
        }
    }

    if (orientation != _orientation) {
        self.orientation = orientation;
    }
}

- (void)setOrientation:(int)orientation
{
    _orientation = orientation;
    fuSetDefaultRotationMode(orientation);
}

@end
