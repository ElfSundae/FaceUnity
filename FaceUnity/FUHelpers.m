//
//  FUHelpers.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/11/28.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUHelpers.h"
#import "NSBundle+FaceUnity.h"

NSString *FUNSLocalizedString(NSString *key, NSString * _Nullable comment)
{
    static NSBundle *languageBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filename = @"en";
        // zh-Hans or zh-Hant
        if ([[NSLocale preferredLanguages].firstObject hasPrefix:@"zh-Han"]) {
            filename = @"zh-Hans";
        }

        NSString *path = [[NSBundle fu_faceUnityBundle] pathForResource:filename ofType:@"lproj"];
        languageBundle = [NSBundle bundleWithPath:path];
    });

    return [languageBundle localizedStringForKey:key value:nil table:nil];
}
