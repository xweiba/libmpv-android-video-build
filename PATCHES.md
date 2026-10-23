# Downstream patches

This fork follows `Predidit/libmpv-android-video-build` (merged up to the
NDK r30 / FFmpeg master `24e860f6` / mpv master `c3ac7f39` bump) and layers
the PaoPao unified media-kernel patches on top. Patch file names and
semantics are shared with the Darwin, Linux and Windows builds.

| Patch | Flavors | Origin | Verification |
| --- | --- | --- | --- |
| `ffmpeg/ffmpeg-hls-kazumi-combined.patch` | default, encoders-gpl (own copy) | Predidit upstream (PTS-offset ad filter, `seg_allow_img`, HLS probe) | CI build; `strings` finds `hls_ad_filter`, `seg_allow_img` |
| `ffmpeg/ffmpeg-segmented-custom-io.patch` | default, encoders-gpl | PaoPao | applies on FFmpeg `24e860f6`; host compile of `hls.o`/`dashdec.o`; `strings` finds `allow_custom_io` |
| `ffmpeg/ffmpeg-segmented-io-cancel.patch` | default, encoders-gpl | PaoPao (ported from Darwin) | as above |
| `mpv/nested-stream-callback.patch` | default, encoders-gpl | PaoPao | applies on mpv `c3ac7f39`; host libmpv build; semantic parity with the Linux canonical patch |
| `mpv/mpv_lavc_set_java_vm.patch` | default, encoders-gpl (symlink) | Predidit upstream | libmpv exports `mpv_lavc_set_java_vm` |
| `mpv/mpv_restore_tls_verify_default.patch` | default, encoders-gpl (symlink) | Predidit upstream | keeps `tls-verify=no` default of older builds |
| `libplacebo/fix_gles_shader_compile_error.patch` | default | Predidit upstream | CI build |

Dropped with the upstream merge (fixed upstream in mpv / libplacebo master):
`mpv_fence_leak-fix.patch`, `fix_shaderc_vulkan_dismatch.patch`.

Not carried: `mpv-filter-metadata-key-type.patch`. mpv master `c3ac7f39`
already contains the equivalent fix in `mp_property_filter_metadata`
(`remaining || ka->action != M_PROPERTY_GET_TYPE`).

## Nested custom media I/O

- `ffmpeg-segmented-custom-io.patch` adds a default-off `allow_custom_io`
  demuxer option for HLS and DASH. When `avio_find_protocol_name()` does not
  know a URL with a non-empty `scheme:`, `open_url` delegates to `s->io_open`
  only if the application opted in; otherwise `AVERROR_INVALIDDATA`. NULL
  `proto_name` is handled (`proto_name_len`, `is_http`). FFmpeg master already
  opens/closes the DASH manifest through `io_open`/`ff_format_io_close`.
- `ffmpeg-segmented-io-cancel.patch` makes HLS/DASH `open_url` return
  `AVERROR_EXIT` as soon as the interrupt callback fires.
- `nested-stream-callback.patch` lets nested FFmpeg reads use protocols
  registered through `mpv_stream_cb_add_ro`. A protocol must also appear in
  FFmpeg's `protocol_whitelist`. Opening is cancel-checked before and after
  `stream_create` (`AVERROR_EXIT`); access-reference origin and cancellation
  are inherited from the parent stream. A top-level callback open marks the
  context `AVFMT_FLAG_CUSTOM_IO`. `io_close2` ignores mpv's own `priv->pb`,
  and closing a callback entry leaves a tombstone so a repeated close never
  reaches `avio_close()` (which treats `opaque` as a `URLContext`). On demuxer
  close, a leaking HLS main playlist callback context is marked custom before
  `avformat_close_input`; afterwards every callback entry is released via
  `nested_stream_cb_free` after `stream_cb_detach_cancel()` unhooks its cancel
  from `demuxer->cancel` (avoids the `cancel_destroy` slave assertion).
  Callback streams are tried before mpv's libcurl nested backend.

## FFmpeg configure (default flavor)

Analysis filters `overlay equalizer astats aresample aformat anull asplit pan
bandpass amerge`; `mp4`/`mov` muxers and the `aac_adtstoasc` BSF for exporting
the original audio cache. encoders-gpl enables all muxers, filters and BSFs.

## Prebuilt artifacts

Release tags `v<upstream>-mediaio.<n>` on `xweiba/libmpv-android-video-build`
carry `default-<abi>.jar` plus `SHA256SUMS`; the same files are mirrored under
`prebuilt/<tag>/` for raw.githubusercontent.com consumption by media-kit.

The patches can be removed when both behaviors are available in released
upstream FFmpeg and mpv builds used by media-kit.
