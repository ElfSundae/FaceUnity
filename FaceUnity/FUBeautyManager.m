//
//  FUBeautyManager.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautyManager.h"
#import <Masonry/Masonry.h>
#import <ESFramework/ESFramework.h>
#import <FURenderer.h>
#import "FUManager.h"
#import "FUAPIDemoBar.h"
#import "FUAPIDemoBar+FUAPIDemoBarDelegate.h"

static const NSInteger SettingsPanelTag = -90008000;

@interface FUBeautyManager ()

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
