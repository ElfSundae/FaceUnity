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

/**
 * The singleton instance.
 */
+ (instancetype)sharedManager;

/**
 * The identifier of the user's beauty preferences.
 */
@property (nullable, nonatomic, copy) NSString *preferencesIdentifier;

/**
 * Prepares FaceUnity SDK for capturing.
 * @discussion In this method, we configure the Nama SDK, load beauty items,
 * load user's beauty preferences. You may call this method inside \c -viewDidLoad .
 */
- (void)prepareToCapture;

/**
 * This method should be invoked when starting capturing.
 */
- (void)startCapturing;

/**
 * This method should be invoked when the capture stopped.
 */
- (void)captureStopped;

/**
 * Updates the given beauty parameter for rendering, and save the preferences.
 */
- (void)updateBeautyParam:(FUBeautyParam *)param;

/**
 * Updates the given filter parameter for rendering, and save the preferences.
 */
- (void)updateFilterParam:(FUBeautyParam *)param;

/**
 * Resets the beauty parameters for the module type.
 */
- (void)resetBeautyParamsForType:(FUBeautyModuleType)type;

@end

@interface FUBeautyManager (FUSettingsPanel)

- (FUAPIDemoBar *)showSettingsPanelInView:(UIView *)view;
- (void)hideSettingsPanelInView:(UIView *)view;
- (nullable FUAPIDemoBar *)settingsPanelInView:(UIView *)view;
- (nullable FUAPIDemoBar *)toggleSettingsPanelInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
