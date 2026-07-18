///|
#borrow(filename, status)
extern "C" fn image_surface_create_from_png_ffi(
  filename : Bytes,
  status : Ref[Int],
) -> RawSurface = "cairoon_image_surface_create_from_png"

///|
#owned(reader)
#borrow(call_reader, status)
extern "C" fn image_surface_create_from_png_stream_ffi(
  call_reader : FuncRef[(Int, (Int) -> Bytes) -> Bytes],
  reader : (Int) -> Bytes,
  status : Ref[Int],
) -> RawSurface = "cairoon_image_surface_create_from_png_stream"

///|
#borrow(surface, filename)
extern "C" fn surface_write_to_png_ffi(
  surface : RawSurface,
  filename : Bytes,
) -> Int = "cairoon_surface_write_to_png"

///|
#borrow(surface, call_writer)
#owned(writer)
extern "C" fn surface_write_to_png_stream_ffi(
  surface : RawSurface,
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
) -> Int = "cairoon_surface_write_to_png_stream"
