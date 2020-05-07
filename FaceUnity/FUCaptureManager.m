//
//  FUCaptureManager.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/07.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUCaptureManager.h"
#import <FURenderer.h>
#import "FUManager.h"

@implementation FUCaptureManager

+ (instancetype)sharedManager
{
    static FUCaptureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)start
{
   
}

@end
