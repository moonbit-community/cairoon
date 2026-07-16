///|
/// Create an owning SVG surface with a page size measured in points.
///
/// One point is 1/72 inch. `None` creates a queryable/drawable no-output
/// surface; `Some(path)` writes UTF-8 SVG to that file and rejects embedded NUL
/// with `CairoInvalidArgument(InvalidString, _)`. Call `finish` to finalize the
/// document and surface any write error. This requires Cairo's SVG backend
/// (`CAIRO_HAS_SVG_SURFACE`, available since Cairo 1.2).
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
/// Create an owning SVG surface that sends encoded output to `writer`.
///
/// Width and height are points. Cairoon retains the writer until the Surface is
/// collected and passes it independent `Bytes` chunks that remain valid after
/// each callback. Return `Success` to continue; non-success statuses are raised
/// by the drawing or `finish` operation, and invalid status integers become
/// `CairoIOError(WriteError, _)`. Construction failures release the writer only
/// after Cairo can no longer invoke it.
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
/// Return a fresh array of SVG versions supported by the linked Cairo build.
///
/// The result is copied from Cairo's static version table and can be mutated by
/// the caller. An unavailable SVG backend raises
/// `CairoError(InvalidStatus, _)`.
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
/// Return a copied Cairo display string for this SVG version.
///
/// The result does not borrow Cairo storage. Backend or conversion failures are
/// reported as checked `CairoError` values.
pub fn SVGVersion::to_string(self : SVGVersion) -> String raise CairoError {
  let status = Ref(0)
  let text = @svg_impl.version_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
/// Convert a pycairo-compatible `cairo_svg_version_t` integer to text.
///
/// Portable values are `0` (SVG 1.1) and `1` (SVG 1.2). Unknown positive or
/// negative integers raise `CairoError(InvalidStatus, _)`; the returned string
/// is copied into MoonBit-owned storage.
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
/// Restrict this document to `version` before performing any drawing.
///
/// Cairo otherwise defaults to its backend version. Calling this after output
/// has begun has backend-defined results, so set it immediately after
/// construction. Finished and non-SVG surfaces raise `SurfaceFinished` and
/// `SurfaceTypeMismatch` respectively.
pub fn Surface::svg_restrict_to_version(
  self : Surface,
  version : SVGVersion,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_restrict_to_version_raw(self.to_raw(), version.to_raw()),
  )
}

///|
/// Restrict SVG output using an exact pycairo-compatible C integer.
///
/// Values `0` and `1` select SVG 1.1 and 1.2. The positive sentinel `99`
/// crosses the raw ABI unchanged and is observed as a no-op on Cairo 1.15.10
/// and 1.18.4. Other out-of-range values are unsupported; use the typed method
/// unless preserving tested C-int behavior is required. The same timing and
/// checked receiver errors apply.
pub fn Surface::svg_restrict_to_version_raw(
  self : Surface,
  version : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_restrict_to_version_raw(self.to_raw(), version),
  )
}

///|
/// Return the unit used for the generated SVG root width and height.
///
/// This API is present at cairoon's Cairo 1.15.10 compatibility floor and in
/// Cairo 1.16 or newer. Historical Cairo builds may default to `SvgUnitUser` or
/// `SvgUnitPt`; call `svg_set_document_unit` for deterministic output.
/// Finished and non-SVG receivers raise checked Surface errors.
pub fn Surface::svg_get_document_unit(
  self : Surface,
) -> SVGUnit raise CairoError {
  svg_unit_from_raw(self.svg_get_document_unit_raw())
}

///|
/// Return the exact `cairo_svg_unit_t` integer for this document.
///
/// Values `0` through `9` correspond to `SvgUnitUser` through
/// `SvgUnitPercent`. The result follows the same version requirement and
/// checked receiver behavior as `svg_get_document_unit`.
pub fn Surface::svg_get_document_unit_raw(
  self : Surface,
) -> Int raise CairoError {
  let status = Ref(0)
  let unit = @surface_impl.svg_get_document_unit_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  unit
}

///|
/// Set the unit written on the SVG root width and height attributes.
///
/// This does not rescale drawing coordinates. Cairo permits the call before it
/// generates the document, but setting it immediately after construction keeps
/// intent unambiguous. The API requires Cairo 1.15.10/1.16 or newer; finished
/// and non-SVG receivers raise checked Surface errors.
pub fn Surface::svg_set_document_unit(
  self : Surface,
  unit : SVGUnit,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_set_document_unit_raw(self.to_raw(), unit.to_raw()),
  )
}

///|
/// Set the document unit from an exact pycairo-compatible C integer.
///
/// Portable values are `0` through `9`. The positive sentinel `99` crosses the
/// raw ABI unchanged and is observed as a no-op on Cairo 1.15.10 and 1.18.4;
/// other out-of-range values are unsupported. Prefer the typed method for new
/// code. Unit effects, version requirements, and checked receiver errors match
/// `svg_set_document_unit`.
pub fn Surface::svg_set_document_unit_raw(
  self : Surface,
  unit : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.svg_set_document_unit_raw(self.to_raw(), unit),
  )
}
