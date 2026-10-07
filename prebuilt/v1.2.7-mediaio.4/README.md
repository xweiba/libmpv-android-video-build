# v1.2.7-mediaio.4（本机编译）

在 v1.2.7-mediaio.3 基础上：

- 修复打开中途取消 / 打开失败时 libmpv 在 `cancel_destroy` 断言崩溃（`!c->slaves.head`，线程 opener）：
  FFmpeg 没关掉的嵌套回调流照旧泄漏，但它们挂在 demuxer 取消令牌下的子令牌没解开，demuxer
  销毁时撞断言。现在 `demux_close_lavf` 对这些流调用新加的 `stream_cb_detach_cancel()` 解开子令牌
  （不释放流、不碰 AVIO：试过直接释放会与 FFmpeg 的释放重复，造成堆损坏）。真机反复「片源打开中退出」
  12 轮 0 崩溃（修复前 5 轮崩 4 次）。
- FFmpeg 再开 asplit / pan / bandpass / amerge 四个音频滤镜，供 PaoPao 音乐横屏特效按频段取电平。

CI 只能手动触发，这一版在本机按 `buildscripts/bundle_default.sh` 同配置编出（NDK r27c），SHA-256 见 SHA256SUMS。
