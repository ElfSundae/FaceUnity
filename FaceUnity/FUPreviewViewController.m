//
//  FUPreviewViewController.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com . All rights reserved.
//

#import "FUPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <Masonry/Masonry.h>
#import "FUManager.h"
#import "FULiveModel.h"
#import "FUCamera.h"
#import "FUOpenGLView.h"
#import "FUAPIDemoBar.h"

#define iPhoneXStyle ((KScreenWidth == 375.f && KScreenHeight == 812.f ? YES : NO) || (KScreenWidth == 414.f && KScreenHeight == 896.f ? YES : NO))
#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

typedef NS_ENUM(NSInteger, FUCameraFocusModel) {
    FUCameraModelAutoFace,
    FUCameraModelChangeless
};

@interface FUPreviewViewController () <FUCameraDelegate, FUAPIDemoBarDelegate>
{
    float imageW;
    float imageH;
}

@property (nonatomic, strong) FULiveModel *model;
@property (nonatomic, strong) FUCamera *mCamera;
@property (nonatomic, strong) FUOpenGLView *renderView;

@property (nonatomic, assign) int orientation;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) FUCameraFocusModel cameraFocusModel;

@property (strong, nonatomic) FUAPIDemoBar *demoBar;

@end

@implementation FUPreviewViewController

- (void)dealloc
{
    [self stopListeningDirectionOfDevice];
    NSLog(@"----界面销毁");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    /* 美颜道具 */
    [[FUManager shareManager] loadFilter];

    /* opengl */
    self.renderView = [[FUOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.renderView];

    self.model = [FUManager shareManager].dataSource.firstObject;
    [FUManager shareManager].currentModel = self.model;

    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view insertSubview:_demoBar atIndex:1];

    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(49);
    }];

    //重置曝光值为0
    [self.mCamera setExposureValue:0];
    _cameraFocusModel = FUCameraModelAutoFace;
    // [self setupLightingValue];
    /* 道具切信号 */
    // signal = dispatch_semaphore_create(1);
    /* 后台监听 */
    [self addObserver];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = self.model.maxFace == 4;

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

    dispatch_async([FUManager shareManager].asyncLoadQueue, ^{
        int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
        /* 单独美颜点位点位*/
        [FURenderer itemSetParam:handle withName:@"landmarks_type" value:@(FUAITYPE_FACEPROCESSOR)];
    });

    [_demoBar reloadShapView:[FUManager shareManager].shapeParams];
    [_demoBar reloadSkinView:[FUManager shareManager].skinParams];
    [_demoBar reloadFilterView:[FUManager shareManager].filters];

    [_demoBar setDefaultFilter:[FUManager shareManager].seletedFliter];

    dispatch_async([FUManager shareManager].asyncLoadQueue, ^{
        int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
        /* 单独美颜点位点位*/
        [FURenderer itemSetParam:handle withName:@"landmarks_type" value:@(FUAITYPE_FACELANDMARKS75)];
    });
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
        _cameraFocusModel = FUCameraModelChangeless;
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
    }
    return _mCamera;
}

#pragma mark - FUCameraDelegate

static int faceframe = 60;
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    imageW = CVPixelBufferGetWidth(pixelBuffer);
    imageH = CVPixelBufferGetHeight(pixelBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];

    [self cameraFocusAndExpose];

    [self.renderView displayPixelBuffer:pixelBuffer];
}

- (void)cameraSubjectAreaDidChange
{
    _cameraFocusModel = FUCameraModelAutoFace;
}

#pragma mark -  人脸曝光逻辑
//主题区域发生了变化，60帧人脸检测对焦人脸
- (void)cameraFocusAndExpose
{
    if (_cameraFocusModel == FUCameraModelAutoFace) {
        BOOL isHaveFace = [[FUManager shareManager] isTracking];
        if (isHaveFace) {
            [self cameraFocusAndExposeFace];
        }
        faceframe--;
        if (faceframe == 0) {
            faceframe = 60;
            _cameraFocusModel = FUCameraModelChangeless;
            NSLog(@"------取消人脸对焦----");
        }
    }
}

- (void)cameraFocusAndExposeFace
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

    if (center.y > 0) {
        CGPoint point = CGPointMake(center.y / imageH, self.mCamera.isFrontCamera ? center.x / imageW : 1 - center.x / imageW);
        [self.mCamera focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:point monitorSubjectAreaChange:YES];
    }
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
        _cameraFocusModel = FUCameraModelAutoFace;
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

#pragma mark -  FUAPIDemoBarDelegate

- (void)restDefaultValue:(int)type
{
    if (type == 1) {//美肤
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
    }

    if (type == 2) {
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
    }
}

- (void)showTopView:(BOOL)shown
{
    float h = shown ? 231 : 49;
    [_demoBar mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(h);
    }];

    // [self setPhotoScaleWithHeight:h show:shown];
}

- (void)filterShowMessage:(NSString *)message
{
    NSLog(@"选择滤镜：%@", message);
}

- (void)filterValueChange:(FUBeautyParam *)param
{
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度

    [FUManager shareManager].seletedFliter = param;
}

- (void)beautyParamValueChange:(FUBeautyParam *)param
{
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]) {//程度值 只去一半
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    } else if ([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    } else {
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.demoBar hiddenTopViewWithAnimation:YES];
}

@end
