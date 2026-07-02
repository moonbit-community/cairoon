///|
pub fn Surface::svg(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let surface = svg_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn SVGVersion::supported() -> Array[SVGVersion] raise CairoError {
  let status = Ref(Success)
  let count = svg_get_version_count_ffi(status)
  check_status(status.val)
  let versions : Array[SVGVersion] = Array::new(capacity=count)
  for index in 0..<count {
    let version = svg_get_version_ffi(index, status)
    check_status(status.val)
    versions.push(version)
  }
  versions
}

///|
pub fn SVGVersion::to_string(self : SVGVersion) -> String raise CairoError {
  let status = Ref(Success)
  let bytes = svg_version_to_string_ffi(self, status)
  check_status(status.val)
  @utf8.decode_lossy(bytes)
}

///|
pub fn Surface::svg_restrict_to_version(
  self : Surface,
  version : SVGVersion,
) -> Unit raise CairoError {
  check_status(svg_surface_restrict_to_version_ffi(self, version))
}

///|
pub fn Surface::svg_get_document_unit(
  self : Surface,
) -> SVGUnit raise CairoError {
  let status = Ref(Success)
  let unit = svg_surface_get_document_unit_ffi(self, status)
  check_status(status.val)
  unit
}

///|
pub fn Surface::svg_set_document_unit(
  self : Surface,
  unit : SVGUnit,
) -> Unit raise CairoError {
  check_status(svg_surface_set_document_unit_ffi(self, unit))
}
