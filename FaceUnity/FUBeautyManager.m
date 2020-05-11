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
#import "FURenderer.h"
#import "FUManager.h"
#import "FUBeautyPreferences.h"

static NSString *const FUDefaultPreferencesFilename = @"default";
static const char *FUPreferencesSavingQueueLabel = "com.0x123.FUBeautyManager.preferencesSaving";

@interface FUBeautyManager ()

// Code copied from FUBaseViewController
/* 监听屏幕方向 */
@property (nonatomic, strong) CMMotionManager *motionManager;
/* 当前方向 */
@property (nonatomic, assign) int orientation;

/// preferences 文件路径，同时标记是否已替换过 FUManager 的美颜参数变量
@property (nullable, nonatomic, copy) NSString *preferencesFilePath;
@property (nonatomic, strong) dispatch_queue_t preferencesSavingQueue;

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

#pragma mark - Beauty Preferences

- (void)setPreferencesIdentifier:(NSString *)identifier
{
    if (_preferencesIdentifier != identifier
        && ![_preferencesIdentifier isEqual:identifier]) {
        _preferencesIdentifier = [identifier copy];

        self.preferencesFilePath = nil;
    }
}

- (void)loadPreferences
{
    if (self.preferencesFilePath) {
        return;
    }

    NSString *filename = self.preferencesIdentifier ?: FUDefaultPreferencesFilename;
    self.preferencesFilePath = ESLibraryPath([NSString stringWithFormat:@"FaceUnity/Preferences/%@.plist", filename]);

    FUBeautyPreferences *prefs = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.preferencesFilePath];
    if (dict) {
        prefs = [FUBeautyPreferences preferencesWithDictionary:dict];
    }

    // TODO: 升级 Nama 版本时兼容升级(逐一比较各个参数)本地旧版本的美颜配置
    if (prefs && ![prefs.version isEqualToString:[FURenderer getVersion]]) {
        prefs = nil;
    }

    if (prefs) {
        [FUManager shareManager].skinParams = prefs.skinParams;
        [FUManager shareManager].shapeParams = prefs.shapeParams;
        [FUManager shareManager].filters = prefs.filters;
        [FUManager shareManager].seletedFliter = prefs.selectedFilter;
    } else {
        // Use the default beauty parameters
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
        [FUManager shareManager].filters = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ESInvokeSelector([FUManager shareManager], @selector(setupFilterData), NULL);
#pragma clang diagnostic pop
    }
}

- (void)savePreferences
{
    FUBeautyPreferences *prefs = [FUBeautyPreferences new];
    prefs.version = [FURenderer getVersion];
    prefs.skinParams = [FUManager shareManager].skinParams;
    prefs.shapeParams = [FUManager shareManager].shapeParams;
    prefs.filters = [FUManager shareManager].filters;
    prefs.selectedFilter = [FUManager shareManager].seletedFliter;

    dispatch_async(self.preferencesSavingQueue, ^{
        if (!self.preferencesFilePath) {
            return;
        }

        [NSFileManager.defaultManager createDirectoryAtPath:
         [self.preferencesFilePath stringByDeletingLastPathComponent]];

        [[prefs encodeToDictionary] writeToFile:self.preferencesFilePath atomically:YES];
    });
}

- (dispatch_queue_t)preferencesSavingQueue
{
    if (!_preferencesSavingQueue) {
        _preferencesSavingQueue = dispatch_queue_create(FUPreferencesSavingQueueLabel,
                                                        DISPATCH_QUEUE_SERIAL);
    }
    return _preferencesSavingQueue;
}

#pragma mark - Capture Helpers

- (void)prepareToCapture
{
    // Code from -[FUBaseViewController viewDidLoad]
    /* 加载美颜道具 */
    [[FUManager shareManager] loadFilter];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = YES;

    [self loadPreferences];
}

- (void)captureStarted
{
    // Code from -[FUBaseViewController viewWillAppear:]
    /* 监听屏幕方向 */
    [self startListeningDirectionOfDevice];
}

- (void)captureStopped
{
    // Code from -[FUBaseViewController viewWillDisappear:]
    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [FURenderer onCameraChange];
    /* 监听屏幕方向 */
    [self stopListeningDirectionOfDevice];
}

// Code from FUBaseViewController
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

// Code from FUBaseViewController
- (void)stopListeningDirectionOfDevice
{
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
}

// Code from FUBaseViewController
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

// Code from FUBaseViewController
- (void)setOrientation:(int)orientation
{
    _orientation = orientation;

    // Code from -[FUBeautyController setOrientation:]
    fuSetDefaultRotationMode(orientation);
}

@end
