# FaceUnity

![Cocoapods](https://img.shields.io/cocoapods/v/FaceUnity)

iOS face-beautification toolkit built upon [FaceUnity](https://www.faceunity.com) Nama SDK and [FULiveDemo](https://github.com/Faceunity/FULiveDemo).

## Installation

Install the **Lite** version without physics engine:

```ruby
pod 'FaceUnity'
```

Or install the **Full** version:

```ruby
pod 'FaceUnity/Full'
```

## Usage

### Configure your authpack

You must use `FUSetAuthData()` to configure your FaceUnity authpack before invoking any methods of Nama SDK.

```objc
#import "authpack.h"

FUSetAuthData(&g_auth_package, sizeof(g_auth_package));
```

### Nama SDK documentation

See [Docs](Docs/).
