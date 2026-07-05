///|
pub fn Surface::image_from_png(path : String) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = image_surface_create_from_png_ffi(
    checked_path_bytes(path),
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::image_from_png_stream(
  reader : (Int) -> Bytes,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = image_surface_create_from_png_stream_ffi(
    fn(length, reader) { reader(length) },
    reader,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::write_to_png(
  self : Surface,
  path : String,
) -> Unit raise CairoError {
  check_status(surface_write_to_png_ffi(self, checked_path_bytes(path)))
}

///|
pub fn Surface::write_to_png_stream(
  self : Surface,
  writer : (Bytes) -> Status,
) -> Unit raise CairoError {
  check_status(
    surface_write_to_png_stream_ffi(
      self,
      fn(chunk, writer) { writer(copy_stream_chunk(chunk)) },
      writer,
    ),
  )
}
