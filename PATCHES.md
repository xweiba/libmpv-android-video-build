# Downstream patches

This fork follows `Predidit/libmpv-android-video-build` and retains its pinned
FFmpeg 7.1.3 and mpv source revisions.

## Nested custom media I/O

- `ffmpeg-segmented-custom-io.patch` adds a default-off `allow_custom_io`
  demuxer option for HLS and DASH. Unknown protocols are delegated only when
  the application opts in; existing HTTP, file, and protocol checks are
  unchanged.
- `nested-stream-callback.patch` lets nested FFmpeg reads use protocols
  registered through `mpv_stream_cb_add_ro`. A protocol must also appear in
  FFmpeg's `protocol_whitelist`; access-reference origin and cancellation are
  inherited from the parent stream.
- FFmpeg's HLS main playlist bypasses `io_close2` and closes `AVIOContext`
  as if its opaque value were an FFmpeg `URLContext`. For a callback stream,
  mpv instead marks that context custom and releases the stream and buffer
  itself after `avformat_close_input`. DASH manifest close likewise routes
  custom I/O through `ff_format_io_close`. Nested streams closed through
  `io_close2` release their AVIO buffer as well as the stream exactly once.

Both default and encoders-GPL flavors consume the same patch files. Regression
validation uses one immutable HLS URL for direct and callback I/O, then checks
full duration, continuous playback, seek, and cache growth. The patches can be
removed when both behaviors are available in released upstream FFmpeg and mpv
builds used by media-kit.
