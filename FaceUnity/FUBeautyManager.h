//
//  FUBeautyManager.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FUManager.h"
@class FUAPIDemoBar;

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautyManager : NSObject

+ (instancetype)sharedManager;

/**
 * The beauty preferences identifier.
 */
@property (nullable, nonatomic, copy) NSString *preferencesIdentifier;

/**
 * Called before capturing: configure Nama SDK, load beauty items, load beauty
 * preferences.
 */
- (void)prepareToCapture;
- (void)captureStarted;
- (void)captureStopped;

- (void)updateBeautyParam:(FUBeautyParam *)param;
- (void)updateFilterParam:(FUBeautyParam *)param;
- (void)resetBeautyParamsForType:(FUBeautyModuleType)type;

@end

@interface FUBeautyManager (FUSettingsPanel)

- (FUAPIDemoBar *)showSettingsPanelInView:(UIView *)view;
- (void)hideSettingsPanelInView:(UIView *)view;
- (nullable FUAPIDemoBar *)settingsPanelInView:(UIView *)view;
- (nullable FUAPIDemoBar *)toggleSettingsPanelInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
