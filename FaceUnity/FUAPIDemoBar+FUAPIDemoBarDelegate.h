//
//  FUAPIDemoBar+FUAPIDemoBarDelegate.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBar.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * FUAPIDemoBarDelegate 的默认实现：调用 FUManager 设置美颜参数，-showTopView 回调时
 * 更新自己的高度。
 * FUAPIDemoBar 在回调 -showTopView 时没有传递 self ，所以调用方在处理回调时不知道是来自
 * 哪个 demoBar ，因此给 FUAPIDemoBar 类添加 category 以在回调方法中使用 self 。
 * 
 * @code
 * demoBar.mDelegate = demoBar;
 * @endcode
 */
@interface FUAPIDemoBar (FUAPIDemoBarDelegate) <FUAPIDemoBarDelegate>

@end

NS_ASSUME_NONNULL_END
