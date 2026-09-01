#!/bin/bash -e

PATCHES=(patches-encoders-gpl/*)
ROOT=$(pwd)

for dep_path in "${PATCHES[@]}"; do
    if [ -d "$dep_path" ]; then
        patches=($dep_path/*)
        dep=$(echo $dep_path |cut -d/ -f 2)
        cd deps/$dep
        echo Patching $dep
        git reset --hard
        for patch in "${patches[@]}"; do
            echo Applying $patch
            git apply "$ROOT/$patch"
        done
        cd $ROOT
    fi
done

# The custom-I/O bridge is shared by all flavors; encoder-specific patches stay
# isolated above while these generic patches retain one source of truth.
for patch in \
    patches/ffmpeg/ffmpeg-segmented-custom-io.patch \
    patches/mpv/nested-stream-callback.patch; do
    dep=$(basename "$(dirname "$patch")")
    cd "deps/$dep"
    git apply "$ROOT/$patch"
    cd "$ROOT"
done

exit 0
