///|
#borrow(filename, status)
extern "C" fn svg_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_svg_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn svg_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_svg_surface_create_for_stream"

///|
#borrow(surface)
extern "C" fn svg_surface_restrict_to_version_ffi(
  surface : Surface,
  version : SVGVersion,
) -> Status = "cairoon_svg_surface_restrict_to_version"

///|
#borrow(surface)
extern "C" fn svg_surface_restrict_to_version_raw_ffi(
  surface : Surface,
  version : Int,
) -> Status = "cairoon_svg_surface_restrict_to_version"

///|
#borrow(surface, status)
extern "C" fn svg_surface_get_document_unit_raw_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_svg_surface_get_document_unit"

///|
#borrow(surface)
extern "C" fn svg_surface_set_document_unit_ffi(
  surface : Surface,
  unit : SVGUnit,
) -> Status = "cairoon_svg_surface_set_document_unit"

///|
#borrow(surface)
extern "C" fn svg_surface_set_document_unit_raw_ffi(
  surface : Surface,
  unit : Int,
) -> Status = "cairoon_svg_surface_set_document_unit"
