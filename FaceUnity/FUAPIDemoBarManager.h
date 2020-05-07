//
//  FUAPIDemoBarManager.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FUAPIDemoBar;

NS_ASSUME_NONNULL_BEGIN

@interface FUAPIDemoBarManager : NSObject

+ (instancetype)sharedManager;

@property (nullable, nonatomic, strong, readonly) FUAPIDemoBar *demoBar;

- (void)showInView:(UIView *)view;
- (void)hide;
- (BOOL)isShowing;

@end

NS_ASSUME_NONNULL_END
