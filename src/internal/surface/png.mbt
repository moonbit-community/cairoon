///|
pub fn image_create_from_png_raw(
  filename : Bytes,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  image_surface_create_from_png_ffi(filename, status)
}

///|
pub fn image_create_from_png_stream_raw(
  reader : (Int) -> Bytes,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  image_surface_create_from_png_stream_ffi(
    fn(length, reader) { reader(length) },
    reader,
    status,
  )
}

///|
pub fn write_to_png_raw(surface : RawSurface, filename : Bytes) -> Int {
  ensure_native()
  surface_write_to_png_ffi(surface, filename)
}

///|
pub fn write_to_png_stream_raw(
  surface : RawSurface,
  writer : (Bytes) -> Int,
) -> Int {
  ensure_native()
  surface_write_to_png_stream_ffi(
    surface,
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
  )
}
