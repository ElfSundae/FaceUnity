//
//  FUAPIDemoBar+FUExtended.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/12.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBar+FUExtended.h"
#import <ESFramework/ESFramework.h>
#import <Masonry/Masonry.h>
#import "NSBundle+FaceUnity.h"
#import "FURenderer.h"
#import "FUManager.h"
#import "FUBeautyManager.h"

@implementation FUAPIDemoBar (FUExtended)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ESSwizzleInstanceMethod(self, @selector(initWithFrame:), @selector(initWithFrame_FUFixNibLocation:));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ESSwizzleInstanceMethod(self, @selector(bottomBtnsSelected:), @selector(fu_bottomBtnsSelected:));
#pragma clang diagnostic pop
    });
}

#pragma mark - Fixes

- (instancetype)initWithFrame_FUFixNibLocation:(CGRect)frame
{
    return self = [[NSBundle fu_faceUnityBundle] loadNibNamed:@"FUAPIDemoBar" owner:self options:nil].firstObject;
}

#pragma mark - Patches

- (IBAction)fu_bottomBtnsSelected:(UIButton *)sender
{
    [self fu_bottomBtnsSelected:sender];

    // Check if the topView is shown or not
    if (!sender.selected) {
        return;
    }

    // Find the current shown collectionView
    UICollectionView *collectionView = nil;
    for (NSString *key in @[ @"skinView", @"shapeView", @"beautyFilterView" ]) {
        UICollectionView *view = [self valueForKey:key];
        if (view && !view.isHidden) {
            collectionView = view;
            break;
        }
    }

    // Scroll to the selected item in the collectionView
    if (collectionView) {
        NSUInteger selectedIndex = ESUnsignedIntegerValue([collectionView valueForKey:@"selectedIndex"]);
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
    }
}

#pragma mark - FUAPIDemoBarDelegate

// <FUAPIDemoBarDelegate> 的默认实现：设置美颜参数，-showTopView 回调时更新自己的高度。
// 因为 FUAPIDemoBar 在回调 -showTopView 时没有传递 self ，所以调用方在处理回调时不知道
// 是来自哪个 demoBar，因此给 FUAPIDemoBar 类添加 category 以在回调方法中使用 self。

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
