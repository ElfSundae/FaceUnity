#!/bin/bash
set -euo pipefail
#
# Update FULiveDemo source code.
#

# GIT_REF can be a tag name, branch name, or a commit SHA.
GIT_REF=7.2.0
ARCHIVE_URL="https://github.com/ElfSundae/FULiveDemo/archive/${GIT_REF}.tar.gz"

WORKING=working

download()
{
    destFile="$WORKING/$(basename "$1")"
    tempFile="$destFile.tmp"

    if [[ "$GIT_REF" == "master" ]]; then
        rm -rf "$destFile" "$tempFile"
    fi

    if [[ ! -f "$destFile" ]]; then
        wget "$1" -c -O "$tempFile" \
            && mv "$tempFile" "$destFile" \
            || rm -f "$tempFile"
    fi

    if [[ -f "$destFile" ]]; then
        echo "$destFile"
    fi
}

cd "$(dirname "$0")/.."
mkdir -p "$WORKING"

downloadedFile=$(download "$ARCHIVE_URL")
[ -z "$downloadedFile" ] && exit 4

echo "Extracting $downloadedFile..."
srcRoot=${downloadedFile%.tar.gz}
rm -rf "$srcRoot"
mkdir -p "$srcRoot"
tar -xf "$downloadedFile" -C "$srcRoot" --strip-components=1

echo "Updating FULiveDemo source code..."
demoSrc="$srcRoot/FULiveDemo"
demoDest=FaceUnity/FULiveDemo
rm -rf $demoDest
rsync -a --delete "$srcRoot/docs/" Docs
rsync -a "$demoSrc/Config" $demoDest --exclude="*.json"
rsync -a "$demoSrc/Helpers" $demoDest \
    --exclude="FURenderer+header.[hm]" \
    --exclude="FUColor.[hm]" \
    --exclude="FUVolumeObserver.[hm]" \
    --exclude="FUVideoDecoder.[hm]" \
    --exclude="FUVideoReader.[hm]" \
    --exclude="FURenderRotate.[hm]"
rsync -a "$demoSrc/Main" $demoDest \
    --include="*/" \
    --include="FULiveModel.[hm]" \
    --include="FUOpenGLView.[hm]" \
    --include="FUSquareButton.[hm]" \
    --exclude="*"
rsync -a "$demoSrc/Modules/Beauty" $demoDest/Modules \
    --exclude="*Controller.*" \
    --exclude="*.strings" \
    --exclude="FUBeautyEditView.[hm]" \
    --exclude="FUBottomColletionView.[hm]" \
    --exclude="UIImage+demobar.[hm]"

git apply Patches/*.patch

Scripts/generate-project.sh "$@"
