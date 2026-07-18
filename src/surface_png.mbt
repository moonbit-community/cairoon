///|
/// Load an image surface from a PNG file path.
///
/// The path is UTF-8 encoded and embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. The returned surface independently
/// owns decoded image storage. Missing files raise
/// `CairoError(FileNotFound, _)`, while PNG/read failures use `CairoIOError`;
/// PNG support must be enabled in linked Cairo.
pub fn Surface::image_from_png(path : String) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_create_from_png_raw(
    checked_path_bytes(path),
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Decode a PNG by synchronously requesting exact-size byte chunks.
///
/// Cairo calls `reader(length)` until decoding completes; every returned
/// `Bytes` value must contain exactly `length` bytes. The callback is borrowed
/// only during construction and cannot raise. Short reads map to
/// `CairoIOError(ReadError, _)`; decode failures use `CairoIOError(PngError, _)`.
pub fn Surface::image_from_png_stream(
  reader : (Int) -> Bytes,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_create_from_png_stream_raw(reader, status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Encode this surface as PNG at `path`.
///
/// The path is UTF-8 encoded and may not contain embedded NUL. Cairo flushes
/// the surface while encoding. Filesystem, PNG, allocation, and
/// finished-surface failures raise checked `CairoError`; PNG support must be
/// enabled in linked Cairo.
pub fn Surface::write_to_png(
  self : Surface,
  path : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.write_to_png_raw(self.to_raw(), checked_path_bytes(path)),
  )
}

///|
/// Encode this surface as PNG and deliver copied output chunks to `writer`.
///
/// Each chunk is MoonBit-owned and may be retained after the callback returns.
/// Return `Success` to continue or a Cairo status to stop; out-of-range status
/// values normalize to `WriteError`. The callback cannot raise through C.
/// Writer, PNG, and surface failures are reported through `CairoError`.
pub fn Surface::write_to_png_stream(
  self : Surface,
  writer : (Bytes) -> Status,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.write_to_png_stream_raw(self.to_raw(), fn(chunk) {
      writer(chunk).to_raw()
    }),
  )
}
