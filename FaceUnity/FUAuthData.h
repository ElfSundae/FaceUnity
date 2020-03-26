//
//  FUAuthData.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/25.
//  Copyright © 2020 https://0x123.com . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Configure your authpack data.
 */
FOUNDATION_EXPORT void FUSetAuthData(const void *data, int length);

/**
 * Retrieve your authpack data.
 */
FOUNDATION_EXPORT void *FUGetAuthData(void);
FOUNDATION_EXPORT int FUGetAuthDataLength(void);

NS_ASSUME_NONNULL_END
