//
//  FUAPIDemoBarManager.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBarManager.h"
#import <Masonry/Masonry.h>
#import <ESFramework/ESFramework.h>
#import <FURenderer.h>
#import "FUManager.h"
#import "FUAPIDemoBar.h"

@interface FUAPIDemoBarManager () <FUAPIDemoBarDelegate>

@property (nullable, nonatomic, strong) FUAPIDemoBar *demoBar;

@end

@implementation FUAPIDemoBarManager

+ (instancetype)sharedManager
{
    static FUAPIDemoBarManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)showInView:(UIView *)view
{
    [self hide];

    /* 美颜道具 */
    [[FUManager shareManager] loadFilter];

    self.demoBar = [[FUAPIDemoBar alloc] init];
    self.demoBar.mDelegate = self;
    [view addSubview:self.demoBar];
    [self.demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(view.mas_bottom);
        }
        make.left.right.equalTo(view);
        make.height.mas_equalTo(49);
    }];

    [self.demoBar reloadSkinView:[FUManager shareManager].skinParams];
    [self.demoBar reloadShapView:[FUManager shareManager].shapeParams];
    [self.demoBar reloadFilterView:[FUManager shareManager].filters];

    [self.demoBar setDefaultFilter:[FUManager shareManager].seletedFliter];

    // 默认打开「美颜」面板
    UIButton *skinButton = (UIButton *)[self.demoBar valueForKey:@"skinBtn"];
    [skinButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)hide
{
    if (self.demoBar) {
        [self.demoBar removeFromSuperview];
        self.demoBar = nil;
    }
}

- (BOOL)isShowing
{
    return !!self.demoBar;
}

#pragma mark - FUAPIDemoBarDelegate

// 滤镜程度改变
- (void)filterValueChange:(FUBeautyParam *)param
{
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度

    [FUManager shareManager].seletedFliter = param;
}

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

// 显示提示语
- (void)filterShowMessage:(NSString *)message
{
    NSLog(@"选择滤镜：%@", message);
}

// 显示上半部分View
- (void)showTopView:(BOOL)shown
{
    float h = shown ? 231 : 49;
    UIView *superview = self.demoBar.superview;
    [self.demoBar mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(superview.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(superview.mas_bottom);
        }
        make.left.right.equalTo(superview);
        make.height.mas_equalTo(h);
    }];
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

@end
