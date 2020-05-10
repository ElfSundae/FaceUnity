# FaceUnity

[![Build status](https://github.com/ElfSundae/FaceUnity/workflows/Build/badge.svg)](https://github.com/ElfSundae/FaceUnity/actions?query=workflow%3ABuild)
![CocoaPods](https://img.shields.io/cocoapods/v/FaceUnity)

iOS face-beautification toolkit built upon [FaceUnity](https://www.faceunity.com) Nama SDK and [FULiveDemo](https://github.com/Faceunity/FULiveDemo).

相芯美颜 SDK 集成工具包。

## Installation

Install along with the **lite** version of Nama SDK which without physics engine:

```ruby
pod 'FaceUnity'
```

Or install along with the **full** version of Nama SDK:

```ruby
pod 'FaceUnity/Full'
```

## Usage

### Configure auth data for Nama SDK

You must call `FUSetAuthData()` to configure your FaceUnity auth data before invoking any methods of Nama SDK:

```objc
#import <FaceUnity/FaceUnity.h>
#import "authpack.h"

FUSetAuthData(&g_auth_package, sizeof(g_auth_package));
```

`FUSetAuthData()` can be called multiple times before you use any FaceUnity functions, it is useful when you want to load the auth data from a remote location, for example:

```objc
if (! loadFromCache(cacheFile)) {
    // Load the default authpack.
    FUSetAuthData(&g_auth_package, sizeof(g_auth_package));
}

downloadAuthData(cacheFile, ^{
    loadFromCache(cacheFile);
});
```

### Preload items

After configuring the auth data, you may preload items to speed up the first loading time:

```objc
// Preload FaceUnity dataSource and items.
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[FUManager shareManager] loadFilter];
});
```

### Nama SDK documentation

See [Docs](Docs/).
