//
//  TestViewController.m
//  Example
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "TestViewController.h"
#import <FaceUnity/FaceUnity.h>

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"显示面板" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSettingsPanel)],
        [[UIBarButtonItem alloc] initWithTitle:@"切换配置" style:UIBarButtonItemStylePlain target:self action:@selector(changeBeautyPreferences)],
    ];
}

- (void)toggleSettingsPanel
{
    UIView *settingsPanel = [FUBeautyManager.sharedManager toggleSettingsPanelInView:self.view];
    self.navigationItem.rightBarButtonItem.title = settingsPanel ? @"隐藏面板" : @"显示面板";
}

- (void)changeBeautyPreferences
{
    FUBeautyManager *manager = FUBeautyManager.sharedManager;
    manager.preferencesIdentifier = manager.preferencesIdentifier ? nil : @"123456";
    NSLog(@"Beauty preferences identifier: %@", manager.preferencesIdentifier);

    if ([manager settingsPanelInView:self.view]) {
        [manager hideSettingsPanelInView:self.view];
        [manager showSettingsPanelInView:self.view];
    }
}

@end
