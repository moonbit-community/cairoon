///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn pdf_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> @surface_impl.RawSurface = "cairoon_pdf_surface_create_for_stream"
