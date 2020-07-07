//
//  FUBeautySettingsViewController.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautySettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FURenderer.h"
#import "FUManager.h"
#import "FUCamera.h"
#import "FUOpenGLView.h"
#import "FUBeautyManager.h"

@interface FUBeautySettingsViewController () <FUCameraDelegate, FUCameraDataSource>
{
    float imageW;
    float imageH;
}

@property (nonatomic, strong) FUCamera *mCamera;
@property (nonatomic, strong) FUOpenGLView *renderView;

@end

@implementation FUBeautySettingsViewController

- (void)dealloc
{
    [FUBeautyManager.sharedManager captureStopped];
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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScreenAction:)];
    [self.renderView addGestureRecognizer:tap];
    // self.renderView.contentMode = FUOpenGLViewContentModeScaleAspectFit;

    [FUBeautyManager.sharedManager prepareToCapture];

    [FUBeautyManager.sharedManager showSettingsPanelInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [FUBeautyManager.sharedManager startCapturing];
    [self.mCamera startCapture];
    [self.mCamera changeSessionPreset:AVCaptureSessionPreset1280x720];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.mCamera resetFocusAndExposureModes];
    [self.mCamera stopCapture];
    [FUBeautyManager.sharedManager captureStopped];
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

    fuSetDefaultRotationMode([FUManager shareManager].deviceOrientation);

    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];

    [self.renderView displayPixelBuffer:pixelBuffer];
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
        [FUBeautyManager.sharedManager captureStopped];
    }
}

- (void)didBecomeActive
{
    if (self.navigationController.visibleViewController == self) {
        [FUBeautyManager.sharedManager startCapturing];
        [self.mCamera startCapture];
    }
}

@end
