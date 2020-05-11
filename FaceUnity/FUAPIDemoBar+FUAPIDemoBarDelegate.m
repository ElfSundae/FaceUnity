//
//  FUAPIDemoBar+FUAPIDemoBarDelegate.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBar+FUAPIDemoBarDelegate.h"
#import <Masonry/Masonry.h>
#import "FURenderer.h"
#import "FUManager.h"
#import "FUBeautyManager.h"

@implementation FUAPIDemoBar (FUAPIDemoBarDelegate)

- (void)beautyParamValueChange:(FUBeautyParam *)param
{
    [FUBeautyManager.sharedManager updateBeautyParam:param];
}

- (void)filterValueChange:(FUBeautyParam *)param
{
    [FUBeautyManager.sharedManager updateFilterParam:param];
}

- (void)restDefaultValue:(int)type
{
    [FUBeautyManager.sharedManager resetBeautyParamsForType:type];
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
