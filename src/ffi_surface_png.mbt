///|
#owned(reader)
#borrow(call_reader, status)
extern "C" fn image_surface_create_from_png_stream_ffi(
  call_reader : FuncRef[(Int, (Int) -> Bytes) -> Bytes],
  reader : (Int) -> Bytes,
  status : Ref[Status],
) -> @surface_impl.RawSurface = "cairoon_image_surface_create_from_png_stream"

///|
#borrow(surface, call_writer)
#owned(writer)
extern "C" fn surface_write_to_png_stream_ffi(
  surface : @surface_impl.RawSurface,
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
) -> Status = "cairoon_surface_write_to_png_stream"
