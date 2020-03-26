//
//  UIImage+demobar.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/24.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "UIImage+demobar.h"
#import "NSBundle+FaceUnity.h"

@implementation UIImage (demobar)

+ (nullable UIImage *)fu_imageWithName:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:[NSBundle fu_faceUnityBundle] compatibleWithTraitCollection:nil];
}

@end
