//
//  FUAuthData.m
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/25.
//  Copyright © 2020 https://0x123.com. All rights reserved.
//

#import "FUAuthData.h"

static NSData *authData = nil;

void FUSetAuthData(const void *data, int length)
{
    authData = [NSData dataWithBytes:data length:(NSUInteger)length];
}

void *FUGetAuthData(void)
{
    return (void *)authData.bytes;
}

int FUGetAuthDataLength(void)
{
    return (int)authData.length;
}
