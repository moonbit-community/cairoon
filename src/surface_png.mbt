///|
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
pub fn Surface::image_from_png_stream(
  reader : (Int) -> Bytes,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let raw = image_surface_create_from_png_stream_ffi(
    fn(length, reader) { reader(length) },
    reader,
    status,
  )
  check_status(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::write_to_png(
  self : Surface,
  path : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.write_to_png_raw(self.to_raw(), checked_path_bytes(path)),
  )
}

///|
pub fn Surface::write_to_png_stream(
  self : Surface,
  writer : (Bytes) -> Status,
) -> Unit raise CairoError {
  check_status(
    surface_write_to_png_stream_ffi(
      self.to_raw(),
      fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
      writer,
    ),
  )
}
