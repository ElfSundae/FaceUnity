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
#import "FUAPIDemoBar.h"
#import "FUAPIDemoBar+FUAPIDemoBarDelegate.h"
#import "FUFilterView.h"

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

    // Scroll to the current filter item in the filter view
    FUFilterView *filterView = [settingsPanel valueForKey:@"beautyFilterView"];
    if ([filterView isKindOfClass:[FUFilterView class]]) {
        // Scrolling can only work after view displayed (layout at least once)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [filterView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:filterView.selectedIndex inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:NO];
        });
    }

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
