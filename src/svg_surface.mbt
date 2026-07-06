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
pub fn Surface::svg_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = svg_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(copy_stream_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn SVGVersion::supported() -> Array[SVGVersion] raise CairoError {
  let status = Ref(0)
  let count = @svg_impl.get_version_count_raw(status)
  check_status(status_from_raw(status.val))
  let versions : Array[SVGVersion] = Array::new(capacity=count)
  for index in 0..<count {
    let version = svg_version_from_raw(@svg_impl.get_version_raw(index, status))
    check_status(status_from_raw(status.val))
    versions.push(version)
  }
  versions
}

///|
pub fn SVGVersion::to_string(self : SVGVersion) -> String raise CairoError {
  let status = Ref(0)
  let text = @svg_impl.version_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
pub fn SVGVersion::to_string_raw(version : Int) -> String raise CairoError {
  let status = Ref(0)
  let text = @svg_impl.version_to_string_raw(version, status)
  check_status(status_from_raw(status.val))
  text
}

///|
fn SVGVersion::to_raw(self : SVGVersion) -> Int {
  match self {
    SvgVersion1_1 => 0
    SvgVersion1_2 => 1
  }
}

///|
fn svg_version_from_raw(raw : Int) -> SVGVersion raise CairoError {
  match raw {
    0 => SvgVersion1_1
    1 => SvgVersion1_2
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo svg version: \{raw}",
      )
  }
}

///|
fn svg_unit_from_raw(raw : Int) -> SVGUnit raise CairoError {
  match raw {
    0 => SvgUnitUser
    1 => SvgUnitEm
    2 => SvgUnitEx
    3 => SvgUnitPx
    4 => SvgUnitIn
    5 => SvgUnitCm
    6 => SvgUnitMm
    7 => SvgUnitPt
    8 => SvgUnitPc
    9 => SvgUnitPercent
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo svg unit: \{raw}",
      )
  }
}

///|
pub fn Surface::svg_restrict_to_version(
  self : Surface,
  version : SVGVersion,
) -> Unit raise CairoError {
  check_status(svg_surface_restrict_to_version_ffi(self, version))
}

///|
pub fn Surface::svg_restrict_to_version_raw(
  self : Surface,
  version : Int,
) -> Unit raise CairoError {
  check_status(svg_surface_restrict_to_version_raw_ffi(self, version))
}

///|
pub fn Surface::svg_get_document_unit(
  self : Surface,
) -> SVGUnit raise CairoError {
  svg_unit_from_raw(self.svg_get_document_unit_raw())
}

///|
pub fn Surface::svg_get_document_unit_raw(
  self : Surface,
) -> Int raise CairoError {
  let status = Ref(Success)
  let unit = svg_surface_get_document_unit_raw_ffi(self, status)
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

///|
pub fn Surface::svg_set_document_unit_raw(
  self : Surface,
  unit : Int,
) -> Unit raise CairoError {
  check_status(svg_surface_set_document_unit_raw_ffi(self, unit))
}
