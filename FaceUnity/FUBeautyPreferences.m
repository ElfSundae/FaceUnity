//
//  FUBeautyPreferences.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautyPreferences.h"
#import <MJExtension/MJExtension.h>
#import <ESFramework/ESFramework.h>
#import "FUBeautyParam.h"

@interface FUBeautyPreferences ()

@property (nonatomic) NSUInteger selectedFilterIndex;

@end

@implementation FUBeautyPreferences

+ (void)load
{
    [self mj_setupIgnoredPropertyNames:^NSArray *{
        return @[
            NSStringFromSelector(@selector(selectedFilter))
        ];
    }];

    [self mj_setupObjectClassInArray:^NSDictionary *{
        return @{
            NSStringFromSelector(@selector(skinParams)): [FUBeautyParam class],
            NSStringFromSelector(@selector(shapeParams)): [FUBeautyParam class],
            NSStringFromSelector(@selector(filters)): [FUBeautyParam class],
        };
    }];
}

- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues
{
    _selectedFilter = self.filters[self.selectedFilterIndex];
}

- (void)setSelectedFilter:(FUBeautyParam *)filter
{
    if (_selectedFilter != filter) {
        _selectedFilter = filter;

        NSUInteger index = [self.filters indexOfObjectIdenticalTo:filter];
        _selectedFilterIndex = (index != NSNotFound ? index : 0);
    }
}

+ (nullable instancetype)preferencesWithContentsOfFile:(NSString *)path
{
    return [self mj_objectWithFile:path];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [[self mj_keyValues] writeToFile:path atomically:useAuxiliaryFile];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> %@",
            NSStringFromClass([self class]), self, [self mj_keyValues]];
}

@end
