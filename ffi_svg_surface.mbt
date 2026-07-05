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
#borrow(status)
extern "C" fn svg_get_version_count_ffi(status : Ref[Status]) -> Int = "cairoon_svg_get_version_count"

///|
#borrow(status)
extern "C" fn svg_get_version_ffi(
  index : Int,
  status : Ref[Status],
) -> SVGVersion = "cairoon_svg_get_version"

///|
#borrow(status)
extern "C" fn svg_version_to_string_ffi(
  version : SVGVersion,
  status : Ref[Status],
) -> Bytes = "cairoon_svg_version_to_string"

///|
#borrow(surface)
extern "C" fn svg_surface_restrict_to_version_ffi(
  surface : Surface,
  version : SVGVersion,
) -> Status = "cairoon_svg_surface_restrict_to_version"

///|
#borrow(surface, status)
extern "C" fn svg_surface_get_document_unit_ffi(
  surface : Surface,
  status : Ref[Status],
) -> SVGUnit = "cairoon_svg_surface_get_document_unit"

///|
#borrow(surface)
extern "C" fn svg_surface_set_document_unit_ffi(
  surface : Surface,
  unit : SVGUnit,
) -> Status = "cairoon_svg_surface_set_document_unit"
