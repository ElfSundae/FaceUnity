//
//  FUAPIDemoBar+FUAPIDemoBarDelegate.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBar+FUAPIDemoBarDelegate.h"
#import <Masonry/Masonry.h>
#import <FURenderer.h>
#import "FUManager.h"

@implementation FUAPIDemoBar (FUAPIDemoBarDelegate)

- (void)beautyParamValueChange:(FUBeautyParam *)param
{
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]) {//程度值 只去一半
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    } else if ([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    } else {
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }
}

- (void)filterValueChange:(FUBeautyParam *)param
{
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度

    [FUManager shareManager].seletedFliter = param;
}

- (void)restDefaultValue:(int)type
{
    if (type == 1) {//美肤
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
    }

    if (type == 2) {
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
    }
}

- (void)showTopView:(BOOL)shown
{
    float h = shown ? 231 : 49;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.superview.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.superview.mas_bottom);
        }
        make.left.right.equalTo(self.superview);
        make.height.mas_equalTo(h);
    }];
}

- (void)filterShowMessage:(NSString *)message
{
    NSLog(@"滤镜：%@", message);
}

@end
