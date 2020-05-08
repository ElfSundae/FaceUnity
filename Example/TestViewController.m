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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"显示" style:UIBarButtonItemStylePlain target:self action:@selector(toggleDemoBar)];
}

- (void)toggleDemoBar
{
    FUBeautyManager *manager = FUBeautyManager.sharedManager;
    if (![manager settingsPanelInView:self.view]) {
        [manager showSettingsPanelInView:self.view];
        self.navigationItem.rightBarButtonItem.title = @"隐藏";
    } else {
        [manager hideSettingsPanelInView:self.view];
        self.navigationItem.rightBarButtonItem.title = @"显示";
    }
}

@end
