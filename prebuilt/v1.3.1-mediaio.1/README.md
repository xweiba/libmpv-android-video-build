# v1.3.1-mediaio.1（GitHub Actions 构建）

基于 Predidit 上游 v1.3.1（NDK r30、FFmpeg master `24e860f6`、mpv master `c3ac7f39`、
libplacebo bump、mpv `tls-verify` 默认 no 恢复补丁）叠加 PaoPao 统一内核补丁：

- `ffmpeg-segmented-custom-io`：HLS/DASH `allow_custom_io`（默认关）。
- `ffmpeg-segmented-io-cancel`：HLS/DASH `open_url` 命中中断即 `AVERROR_EXIT`（Android 首次携带）。
- `nested-stream-callback`：嵌套 `mpv_stream_cb_add_ro` 协议；打开前后取消检查、顶层 CUSTOM_IO、
  `priv->pb` 防护、墓碑防重复关闭、关闭后释放全部回调条目并解开取消令牌。
- FFmpeg 新增 `mp4`/`mov` muxer 与 `aac_adtstoasc` bsf；保留 astats/asplit/bandpass/amerge 等分析滤镜。
- mpv master 已含 filter-metadata GET_TYPE 修复，不再单独打补丁。

构建：Actions run 39897926817（commit 077206b）。SHA-256 见 SHA256SUMS，同名文件也挂在
GitHub release `v1.3.1-mediaio.1`。
