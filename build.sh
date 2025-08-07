X264_GIT="https://code.videolan.org/videolan/x264.git"
X264_BRANCH=stable

FFMPEG_GIT="https://github.com/FFmpeg/FFmpeg.git"
FFMPEG_TAG=n7.1.1

BUILD_DIR=$(pwd)/build
DOWNLOAD_DIR=$(pwd)/dl
INSTALL_DIR=$(pwd)
DEST_DIR=$(pwd)/dest

ARCH=$(uname -m)

build_x264() {
    arch=$1

    echo "Building x264 for $arch..."
    git clone --depth 1 --branch $X264_BRANCH $X264_GIT $DOWNLOAD_DIR/x264

    cd $DOWNLOAD_DIR/x264
    ./configure --prefix="$BUILD_DIR/x264" --enable-static --enable-strip --enable-pic --disable-cli --disable-opencl

    make -j$(nproc)
    make install
}

build_ffmpeg() {
    arch=$1
    echo "Building FFmpeg for $arch..."
    git clone --depth 1 --branch $FFMPEG_TAG $FFMPEG_GIT $DOWNLOAD_DIR/ffmpeg

    export PKG_CONFIG_PATH=$BUILD_DIR/x264/lib/pkgconfig

    cd $DOWNLOAD_DIR/ffmpeg

    ./configure --prefix="$INSTALL_DIR/ffmpeg" --pkg-config-flags="--static" --extra-libs="-lpthread -lm" --enable-gpl \
                --disable-static --enable-shared --disable-programs --disable-doc --disable-avdevice --disable-avformat --disable-swresample \
                --disable-postproc --disable-avfilter --disable-everything --enable-encoder=mjpeg --enable-encoder=libx264 --enable-decoder=h264 \
                --enable-decoder=hevc --enable-libx264 --disable-sdl2 --disable-alsa

    make -j$(nproc)
    make install
}

build_x264 $ARCH
build_ffmpeg $ARCH

for pc in $INSTALL_DIR/ffmpeg/lib/pkgconfig/*.pc; do
    sed -i '1s|.*|prefix=${pcfiledir}/../..|' "$pc"
    sed -i '2s|.*|exec_prefix=${prefix}|' "$pc"
    sed -i '3s|.*|libdir=${prefix}/lib|' "$pc"
    sed -i '4s|.*|includedir=${prefix}/include|' "$pc"
    sed -i '/^Libs\.private:/d' "$pc"
done

echo "Packaging FFmpeg for $arch..."
mkdir $DEST_DIR && cd $DEST_DIR
VERSION=$(printf "%s" "$FFMPEG_TAG" | cut -c2-)
tar -cvJf ffmpeg-linux-$arch-$VERSION.tar.xz -C $INSTALL_DIR/ffmpeg .