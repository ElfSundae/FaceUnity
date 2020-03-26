//
//  FUAPIDemoBar+FUFixNibLocation.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/25.
//  Copyright © 2020 https://0x123.com . All rights reserved.
//

#import "FUAPIDemoBar.h"
#import "NSBundle+FaceUnity.h"
#import <ESFramework/ESFramework.h>

@interface FUAPIDemoBar (FUFixNibLocation)

@end

@implementation FUAPIDemoBar (FUFixNibLocation)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ESSwizzleInstanceMethod(self, @selector(initWithFrame:), @selector(initWithFrame_FUFixNibLocation:));
    });
}

- (instancetype)initWithFrame_FUFixNibLocation:(CGRect)frame
{
    return self = [[NSBundle fu_faceUnityBundle] loadNibNamed:@"FUAPIDemoBar" owner:self options:nil].firstObject;
}

@end
