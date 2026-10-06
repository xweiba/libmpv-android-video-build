# v1.2.7-mediaio.3（本机编译）

在 v1.2.7-mediaio.2 基础上开启 FFmpeg 音频分析滤镜 astats / aresample / aformat / anull
（commit 54b16d0），供 PaoPao 音乐横屏特效读取实时电平。CI 只能手动触发，这一版在本机
按 `buildscripts/bundle_default.sh` 编出（NDK r27c，与 CI 同配置），SHA-256 见 SHA256SUMS。
