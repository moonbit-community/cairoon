///|
#borrow(filename, status)
extern "C" fn svg_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_svg_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn svg_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_svg_surface_create_for_stream"

///|
#borrow(surface)
extern "C" fn svg_surface_restrict_to_version_ffi(
  surface : RawSurface,
  version : Int,
) -> Int = "cairoon_svg_surface_restrict_to_version"

///|
#borrow(surface, status)
extern "C" fn svg_surface_get_document_unit_ffi(
  surface : RawSurface,
  status : Ref[Int],
) -> Int = "cairoon_svg_surface_get_document_unit"

///|
#borrow(surface)
extern "C" fn svg_surface_set_document_unit_ffi(
  surface : RawSurface,
  unit : Int,
) -> Int = "cairoon_svg_surface_set_document_unit"
