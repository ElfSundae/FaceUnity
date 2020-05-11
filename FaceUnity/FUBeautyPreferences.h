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

@property (nonatomic, copy) NSString *version;

@property (nonatomic, strong) NSMutableArray<FUBeautyParam *> *skinParams;
@property (nonatomic, strong) NSMutableArray<FUBeautyParam *> *shapeParams;
@property (nonatomic, strong) NSMutableArray<FUBeautyParam *> *filters;
@property (nonatomic, strong) FUBeautyParam *selectedFilter;
@property (nonatomic, readonly) NSUInteger selectedFilterIndex;

+ (nullable instancetype)preferencesWithContentsOfFile:(NSString *)path;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

@end

NS_ASSUME_NONNULL_END
