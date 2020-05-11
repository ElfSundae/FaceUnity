//
//  FUBeautyManager+FUSettingsPanel.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautyManager.h"
#import <Masonry/Masonry.h>
#import "FUManager.h"
#import "FUAPIDemoBar+FUExtended.h"

static const NSInteger SettingsPanelTag = -90008000;

@implementation FUBeautyManager (FUSettingsPanel)

- (FUAPIDemoBar *)showSettingsPanelInView:(UIView *)view
{
    // Make sure the beauty preferences are loaded.
    [self prepareToCapture];

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

    // Set data for settings panel
    [settingsPanel reloadSkinView:[FUManager shareManager].skinParams];
    [settingsPanel reloadShapView:[FUManager shareManager].shapeParams];
    [settingsPanel reloadFilterView:[FUManager shareManager].filters];
    [settingsPanel setDefaultFilter:[FUManager shareManager].seletedFliter];

    // By default, open the "skin" section's topView
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

- (nullable FUAPIDemoBar *)toggleSettingsPanelInView:(UIView *)view
{
    if (![self settingsPanelInView:view]) {
        return [self showSettingsPanelInView:view];
    } else {
        [self hideSettingsPanelInView:view];
        return nil;
    }
}

@end
