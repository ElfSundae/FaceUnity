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
    if (_preferencesIdentifier != identifier && ![_preferencesIdentifier isEqual:identifier]) {
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
    [NSFileManager.defaultManager createDirectoryAtPath:[self.preferencesFilePath stringByDeletingLastPathComponent]];

    FUBeautyPreferences *prefs = [FUBeautyPreferences preferencesWithContentsOfFile:self.preferencesFilePath];

    if (prefs) {
        [self upgradePreferences:prefs];
    }

    if (prefs) {
        [self resetAllParamsWithPreferences:prefs];
    } else {
        [self resetAllParamsToDefault];
    }
}

/**
 * Make the given preferences up-to-date with the current Nama SDK.
 */
- (void)upgradePreferences:(FUBeautyPreferences *)prefs
{
    if ([prefs.version isEqualToString:[FURenderer getVersion]]) {
        return;
    }

    FUManager *manager = [FUManager shareManager];

    prefs.version = [FURenderer getVersion];
    prefs.skinParams = [self upgradeBeautyParams:prefs.skinParams
                                        toParams:manager.skinParams];
    prefs.shapeParams = [self upgradeBeautyParams:prefs.shapeParams
                                         toParams:manager.shapeParams];
    prefs.filters = [self upgradeBeautyParams:prefs.filters
                                     toParams:manager.filters];
    prefs.selectedFilter = [prefs.filters objectPassingTest:^BOOL (FUBeautyParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.mParam isEqualToString:prefs.selectedFilter.mParam];
    }] ?: manager.seletedFliter;

    [self writePreferencesToFile:prefs];
}

- (NSMutableArray<FUBeautyParam *> *)upgradeBeautyParams:(NSArray<FUBeautyParam *> *)params
                                                toParams:(NSArray<FUBeautyParam *> *)toParams
{
    NSMutableArray<FUBeautyParam *> *result = [NSMutableArray arrayWithCapacity:toParams.count];

    for (FUBeautyParam *param in toParams) {
        FUBeautyParam *existing = [params objectPassingTest:^BOOL (FUBeautyParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.mParam isEqualToString:param.mParam];
        }];

        if (existing) {
            param.mValue = existing.mValue;
        }

        [result addObject:param];
    }

    return result;
}

- (void)resetAllParamsWithPreferences:(FUBeautyPreferences *)prefs
{
    FUManager *manager = [FUManager shareManager];

    manager.skinParams = prefs.skinParams;
    for (FUBeautyParam *param in manager.skinParams) {
        [self updateBeautyParam:param savePreferences:NO];
    }

    manager.shapeParams = prefs.shapeParams;
    for (FUBeautyParam *param in manager.shapeParams) {
        [self updateBeautyParam:param savePreferences:NO];
    }

    manager.filters = prefs.filters;
    manager.seletedFliter = prefs.selectedFilter;
    [self updateFilterParam:manager.seletedFliter savePreferences:NO];
}

- (void)resetAllParamsToDefault
{
    [self resetBeautyParamsForType:(FUBeautyModuleTypeSkin | FUBeautyModuleTypeShape)
                   savePreferences:NO];

    [FUManager shareManager].filters = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ESInvokeSelector([FUManager shareManager], @selector(setupFilterData), NULL);
#pragma clang diagnostic pop

    [self updateFilterParam:[FUManager shareManager].seletedFliter
            savePreferences:NO];
}

/**
 * Save the current preferences.
 */
- (void)savePreferences
{
    FUBeautyPreferences *prefs = [FUBeautyPreferences new];
    prefs.version = [FURenderer getVersion];
    prefs.skinParams = [FUManager shareManager].skinParams;
    prefs.shapeParams = [FUManager shareManager].shapeParams;
    prefs.filters = [FUManager shareManager].filters;
    prefs.selectedFilter = [FUManager shareManager].seletedFliter;

    [self writePreferencesToFile:prefs];
}

- (void)writePreferencesToFile:(FUBeautyPreferences *)prefs
{
    dispatch_async(self.preferencesSavingQueue, ^{
        if (self.preferencesFilePath) {
            [prefs writeToFile:self.preferencesFilePath atomically:YES];
        }
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
    /* 抗锯齿 */
    [[FUManager shareManager] loadBundleWithName:@"fxaa" aboutType:FUNamaHandleTypeFxaa];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = YES;

    [self loadPreferences];
}

- (void)startCapturing
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
    if (self.motionManager) {
        return;
    }

    self.motionManager = [[CMMotionManager alloc] init];
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

#pragma mark - Beauty Parameters

- (void)updateBeautyParam:(FUBeautyParam *)param
{
    [self updateBeautyParam:param savePreferences:YES];
}

- (void)updateBeautyParam:(FUBeautyParam *)param savePreferences:(BOOL)save
{
    // Code from -[FUBeautyController beautyParamValueChange:]
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]) {//程度值 只去一半
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    } else if ([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    } else {
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }

    if (save) {
        [self savePreferences];
    }
}

- (void)updateFilterParam:(FUBeautyParam *)param
{
    [self updateFilterParam:param savePreferences:YES];
}

- (void)updateFilterParam:(FUBeautyParam *)param savePreferences:(BOOL)save
{
    // Code from -[FUBeautyController filterValueChange:]
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度

    [FUManager shareManager].seletedFliter = param;

    if (save) {
        [self savePreferences];
    }
}

- (void)resetBeautyParamsForType:(FUBeautyModuleType)type
{
    [self resetBeautyParamsForType:type savePreferences:YES];
}

- (void)resetBeautyParamsForType:(FUBeautyModuleType)type savePreferences:(BOOL)save
{
    // Code ref -[FUBeautyController restDefaultValue:]
    [[FUManager shareManager] setBeautyDefaultParameters:type];

    if (save) {
        [self savePreferences];
    }
}

@end
