//
//  FUBeautyPreferences.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FUBeautyParam;

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautyPreferences : NSObject

@property (nonatomic, copy) NSString *SDKVersion;

@property (nonatomic, strong) NSArray<FUBeautyParam *> *skinParams;
@property (nonatomic, strong) NSArray<FUBeautyParam *> *shapeParams;
@property (nonatomic, strong) NSArray<FUBeautyParam *> *filters;
@property (nonatomic, readonly) NSUInteger selectedFilterIndex;
@property (nonatomic, strong) FUBeautyParam *selectedFilter;

@end

NS_ASSUME_NONNULL_END
