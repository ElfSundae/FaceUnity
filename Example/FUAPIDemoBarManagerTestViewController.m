//
//  FUAPIDemoBarManagerTestViewController.m
//  Example
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBarManagerTestViewController.h"
#import <FaceUnity/FaceUnity.h>

@interface FUAPIDemoBarManagerTestViewController ()

@end

@implementation FUAPIDemoBarManagerTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"显示" style:UIBarButtonItemStylePlain target:self action:@selector(toggleDemoBar)];
}

- (void)toggleDemoBar
{
    FUAPIDemoBarManager *manager = FUAPIDemoBarManager.sharedManager;
    if (!manager.isShowing) {
        [manager showInView:self.view];
        self.navigationItem.rightBarButtonItem.title = @"隐藏";
    } else {
        [manager hide];
        self.navigationItem.rightBarButtonItem.title = @"显示";
    }
}

@end
