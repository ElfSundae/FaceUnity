//
//  FUBeautyManager.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FUAPIDemoBar;

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautyManager : NSObject

+ (instancetype)sharedManager;

- (void)prepareToCapture;
- (void)captureStarted;
- (void)captureStopped;

@end

@interface FUBeautyManager (FUSettingsPanel)

- (FUAPIDemoBar *)showSettingsPanelInView:(UIView *)view;
- (void)hideSettingsPanelInView:(UIView *)view;
- (nullable FUAPIDemoBar *)settingsPanelInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
