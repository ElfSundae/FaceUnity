//
//  FUCaptureManager.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUCaptureManager : NSObject

+ (instancetype)sharedManager;

- (void)prepare;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
