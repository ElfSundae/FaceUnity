# FaceUnity

![Cocoapods](https://img.shields.io/cocoapods/v/FaceUnity)

iOS face-beautification toolkit built upon [FaceUnity](https://www.faceunity.com) Nama SDK and [FULiveDemo](https://github.com/Faceunity/FULiveDemo).

## Installation

Install along with the lite version of Nama SDK which without physics engine:

```ruby
pod 'FaceUnity'
```

Or install along with the full version of Nama SDK:

```ruby
pod 'FaceUnity/Full'
```

## Usage

### Configure your authpack

You must use `FUSetAuthData()` to configure your FaceUnity authpack before invoking any methods of Nama SDK.

```objc
#import <FaceUnity/FaceUnity.h>
#import "authpack.h"

FUSetAuthData(&g_auth_package, sizeof(g_auth_package));
```

### Nama SDK documentation

See [Docs](Docs/).
