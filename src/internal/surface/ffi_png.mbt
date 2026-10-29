///|
#borrow(filename, status)
extern "C" fn image_surface_create_from_png_ffi(
  filename : Bytes,
  status : Ref[Int32],
) -> RawSurface = "cairoon_image_surface_create_from_png"

///|
#owned(reader)
#borrow(call_reader, status)
extern "C" fn image_surface_create_from_png_stream_ffi(
  call_reader : FuncRef[(Int32, (Int32) -> Bytes) -> Bytes],
  reader : (Int32) -> Bytes,
  status : Ref[Int32],
) -> RawSurface = "cairoon_image_surface_create_from_png_stream"

///|
#borrow(surface, filename)
extern "C" fn surface_write_to_png_ffi(
  surface : RawSurface,
  filename : Bytes,
) -> Int32 = "cairoon_surface_write_to_png"

///|
#borrow(surface, call_writer)
#owned(writer)
extern "C" fn surface_write_to_png_stream_ffi(
  surface : RawSurface,
  call_writer : FuncRef[(Bytes, (Bytes) -> Int32) -> Int32],
  writer : (Bytes) -> Int32,
) -> Int32 = "cairoon_surface_write_to_png_stream"
