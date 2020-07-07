//
//  UIImage+demobar.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/24.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (demobar)

/**
 * Creates an image object with the name loaded from the FaceUnity bundle.
 */
+ (nullable UIImage *)fu_imageWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
