//
//  FUBeautyManager.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautyManager.h"
#import <CoreMotion/CoreMotion.h>
#import <ESFramework/ESFramework.h>
#import <Masonry/Masonry.h>
#import <FURenderer.h>
#import "FUManager.h"
#import "FUAPIDemoBar.h"
#import "FUAPIDemoBar+FUAPIDemoBarDelegate.h"

static const NSInteger SettingsPanelTag = -90008000;

@interface FUBeautyManager ()

// Code copied from FUBaseViewController
/* 监听屏幕方向 */
@property (nonatomic, strong) CMMotionManager *motionManager;
/* 当前方向 */
@property (nonatomic, assign) int orientation;

@end

@implementation FUBeautyManager

+ (instancetype)sharedManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

#pragma mark - Capture Helper

- (void)prepareToCapture
{
    // -[FUBaseViewController viewDidLoad]
    /* 加载美颜道具 */
    [[FUManager shareManager] loadFilter];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = YES;
}

- (void)captureStarted
{
    // -[FUBaseViewController viewWillAppear:]
    /* 监听屏幕方向 */
    [self startListeningDirectionOfDevice];
}

- (void)captureStopped
{
    // -[FUBaseViewController viewWillDisappear:]
    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [FURenderer onCameraChange];
    /* 监听屏幕方向 */
    [self stopListeningDirectionOfDevice];
}

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

    // -[FUBeautyController setOrientation:]
    fuSetDefaultRotationMode(orientation);
}

#pragma mark - SettingsPanel (FUAPIDemoBar)

- (FUAPIDemoBar *)showSettingsPanelInView:(UIView *)view
{
    [self hideSettingsPanelInView:view];

    FUAPIDemoBar *settingsPanel = [FUAPIDemoBar new];
    settingsPanel.mDelegate = settingsPanel;
    settingsPanel.tag = SettingsPanelTag;
    [view addSubview:settingsPanel];
    [settingsPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(view.mas_bottom);
        }
        make.left.right.equalTo(view);
        make.height.mas_equalTo(49);
    }];

    [settingsPanel reloadSkinView:[FUManager shareManager].skinParams];
    [settingsPanel reloadShapView:[FUManager shareManager].shapeParams];
    [settingsPanel reloadFilterView:[FUManager shareManager].filters];
    [settingsPanel setDefaultFilter:[FUManager shareManager].seletedFliter];

    // Open the "skin" section's topView by default
    UIButton *skinButton = (UIButton *)[settingsPanel valueForKey:@"skinBtn"];
    [skinButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    return settingsPanel;
}

- (void)hideSettingsPanelInView:(UIView *)view
{
    [[self settingsPanelInView:view] removeFromSuperview];
}

- (nullable FUAPIDemoBar *)settingsPanelInView:(UIView *)view;
{
    return [view viewWithTag:SettingsPanelTag];
}

@end
