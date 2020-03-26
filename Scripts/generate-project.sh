#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

rm -f FaceUnity/FaceUnity.h
find FaceUnity -type f -name "*.h" -exec bash -c \
    'echo "#import <FaceUnity/$(basename {})>" >> FaceUnity/FaceUnity.h' \;
cat <<EOT > FaceUnity/FaceUnity.h
//
//  FaceUnity.h
//  FaceUnity
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com . All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double FaceUnityVersionNumber;
FOUNDATION_EXPORT const unsigned char FaceUnityVersionString[];

$(cat FaceUnity/FaceUnity.h)
EOT

xcodegen -c

pod update "$@"
