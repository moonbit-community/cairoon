///|
pub fn Surface::svg(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let raw = @surface_impl.svg_create_raw(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::svg_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let raw = svg_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
  check_status(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
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
fn SVGUnit::to_raw(self : SVGUnit) -> Int {
  match self {
    SvgUnitUser => 0
    SvgUnitEm => 1
    SvgUnitEx => 2
    SvgUnitPx => 3
    SvgUnitIn => 4
    SvgUnitCm => 5
    SvgUnitMm => 6
    SvgUnitPt => 7
    SvgUnitPc => 8
    SvgUnitPercent => 9
  }
}

///|
pub fn Surface::svg_restrict_to_version(
  self : Surface,
  version : SVGVersion,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_restrict_to_version_raw(self.to_raw(), version.to_raw()),
  )
}

///|
pub fn Surface::svg_restrict_to_version_raw(
  self : Surface,
  version : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_restrict_to_version_raw(self.to_raw(), version),
  )
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
  let status = Ref(0)
  let unit = @surface_impl.svg_get_document_unit_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  unit
}

///|
pub fn Surface::svg_set_document_unit(
  self : Surface,
  unit : SVGUnit,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_set_document_unit_raw(self.to_raw(), unit.to_raw()),
  )
}

///|
pub fn Surface::svg_set_document_unit_raw(
  self : Surface,
  unit : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_set_document_unit_raw(self.to_raw(), unit),
  )
}
