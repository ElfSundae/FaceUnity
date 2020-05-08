//
//  FUBeautyPreferences.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/05/09.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUBeautyPreferences.h"
#import <MJExtension/MJExtension.h>

@interface FUBeautyPreferences ()

@property (nonatomic) NSUInteger selectedFilterIndex;

@end

@implementation FUBeautyPreferences

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[ @"selectedFilter" ];
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

@end
