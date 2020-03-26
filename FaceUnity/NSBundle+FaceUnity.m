//
//  NSBundle+FaceUnity.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/24.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "NSBundle+FaceUnity.h"
#import "FUAPIDemoBar.h"

@implementation NSBundle (FaceUnity)

+ (nullable instancetype)fu_faceUnityBundle
{
    static NSBundle *_faceUnityBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[FUAPIDemoBar class]];
        NSURL *url = [bundle URLForResource:@"FaceUnity" withExtension:@"bundle"];
        _faceUnityBundle = [NSBundle bundleWithURL:url];
    });
    return _faceUnityBundle;
}

@end
