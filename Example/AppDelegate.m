//
//  AppDelegate.m
//  FaceUnityExample
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <FaceUnity/FaceUnity.h>
#import "authpack.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[MainViewController new]];

    FUSetAuthData(&g_auth_package, sizeof(g_auth_package));

    [self.window makeKeyAndVisible];
    return YES;
}

@end
