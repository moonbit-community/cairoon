///|
pub fn svg_create_raw(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  svg_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
}

///|
pub fn svg_restrict_to_version_raw(surface : RawSurface, version : Int) -> Int {
  ensure_native()
  svg_surface_restrict_to_version_ffi(surface, version)
}

///|
pub fn svg_get_document_unit_raw(
  surface : RawSurface,
  status : Ref[Int],
) -> Int {
  ensure_native()
  svg_surface_get_document_unit_ffi(surface, status)
}

///|
pub fn svg_set_document_unit_raw(surface : RawSurface, unit : Int) -> Int {
  ensure_native()
  svg_surface_set_document_unit_ffi(surface, unit)
}
