//
//  FUAPIDemoBar+FUExtended.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/12.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAPIDemoBar.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Extended FUAPIDemoBar that implements \c FUAPIDemoBarDelegate delegate methods,
 * and applies some patches like scrolling to the selected item if it is not
 * fully visible in the collectionView.
 */
@interface FUAPIDemoBar (FUExtended) <FUAPIDemoBarDelegate>

@end

NS_ASSUME_NONNULL_END
