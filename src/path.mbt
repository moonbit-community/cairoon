///|
/// A typed element of an owned Cairo path snapshot.
///
/// Move and line elements store their endpoint. Curve elements store the
/// first control point, second control point, and endpoint in that order.
/// Coordinates use the user space in effect when the path was copied.
pub(all) enum PathSegment {
  PathSegmentMoveTo(Double, Double)
  PathSegmentLineTo(Double, Double)
  PathSegmentCurveTo(Double, Double, Double, Double, Double, Double)
  PathSegmentClosePath
} derive(Eq, Debug)

///|
/// Return the Cairo path-data discriminator for this segment.
pub fn PathSegment::data_type(self : PathSegment) -> PathDataType {
  match self {
    PathSegmentMoveTo(_, _) => PathMoveTo
    PathSegmentLineTo(_, _) => PathLineTo
    PathSegmentCurveTo(_, _, _, _, _, _) => PathCurveTo
    PathSegmentClosePath => PathClosePath
  }
}

///|
/// Return this segment's coordinates in Cairo order.
///
/// The new array contains two values for move/line, six for curve, and none
/// for close-path.
pub fn PathSegment::coordinates(self : PathSegment) -> Array[Double] {
  match self {
    PathSegmentMoveTo(x, y) | PathSegmentLineTo(x, y) => [x, y]
    PathSegmentCurveTo(x1, y1, x2, y2, x3, y3) => [x1, y1, x2, y2, x3, y3]
    PathSegmentClosePath => []
  }
}

///|
/// Return the segment discriminator and a newly allocated coordinate array.
pub fn PathSegment::components(
  self : PathSegment,
) -> (PathDataType, Array[Double]) {
  (self.data_type(), self.coordinates())
}

///|
/// An owned, opaque snapshot of Cairo path data.
///
/// Paths come from `Context::copy_path`, `Context::copy_path_flat`, or another
/// Cairo producer and cannot be directly constructed. A path remains valid
/// independently of the context or pattern that produced it.
struct Path(@path_impl.RawPath)

///|
fn Path::from_raw(raw : @path_impl.RawPath) -> Path {
  Path(raw)
}

///|
fn Path::to_raw(self : Path) -> @path_impl.RawPath {
  self.0
}

///|
fn path_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_path_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn path_data_type_from_raw(raw : Int) -> PathDataType raise CairoError {
  match raw {
    0 => PathMoveTo
    1 => PathLineTo
    2 => PathCurveTo
    3 => PathClosePath
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo path data type: \{raw}",
      )
  }
}

///|
/// Return the status stored in this path without raising it.
pub fn Path::status(self : Path) -> Status {
  path_status_from_raw(@path_impl.status_raw(self.to_raw()))
}

///|
/// Test whether two wrappers own the same Cairo path allocation.
///
/// This is identity equality, not geometric or segment-content equality.
pub fn Path::equal(self : Path, other : Path) -> Bool {
  @path_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return an identity hash for the underlying Cairo path allocation.
///
/// The value is process-local and must not be persisted.
pub fn Path::hash(self : Path) -> UInt64 {
  @path_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for Path with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Compare for Path with fn compare(self, other) {
  self.hash().compare(other.hash())
}

///|
pub impl Hash for Path with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Path with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
/// Return the number of independent path segments.
///
/// Cairo may insert an explicit move segment after close-path; it counts as a
/// segment. Raises the path's checked `CairoError` status if it is invalid.
pub fn Path::length(self : Path) -> Int raise CairoError {
  let status = Ref(0)
  let count = @path_impl.num_segments_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  count
}

///|
/// Copy all path data into typed MoonBit segments.
///
/// Raises the path's checked `CairoError` status for invalid path data.
pub fn Path::segments(self : Path) -> Array[PathSegment] raise CairoError {
  let status = Ref(0)
  let data_count = @path_impl.num_data_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  let segment_count = @path_impl.num_segments_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  let segments : Array[PathSegment] = Array::new(capacity=segment_count)
  for data_index = 0; data_index < data_count; {
    let type_ = Ref(3)
    let length = Ref(0)
    let x1 = Ref(0.0)
    let y1 = Ref(0.0)
    let x2 = Ref(0.0)
    let y2 = Ref(0.0)
    let x3 = Ref(0.0)
    let y3 = Ref(0.0)
    check_path_status_raw(
      @path_impl.get_data_raw(
        self.to_raw(),
        data_index,
        type_,
        length,
        x1,
        y1,
        x2,
        y2,
        x3,
        y3,
      ),
    )
    match path_data_type_from_raw(type_.val) {
      PathMoveTo => segments.push(PathSegmentMoveTo(x1.val, y1.val))
      PathLineTo => segments.push(PathSegmentLineTo(x1.val, y1.val))
      PathCurveTo =>
        segments.push(
          PathSegmentCurveTo(x1.val, y1.val, x2.val, y2.val, x3.val, y3.val),
        )
      PathClosePath => segments.push(PathSegmentClosePath)
    }
    continue data_index + length.val
  }
  segments
}

///|
/// Return an iterator over a copied, validated segment snapshot.
///
/// Constructing the iterator materializes the complete `segments()` array and
/// can raise the same checked errors.
pub fn Path::iter(self : Path) -> Iter[PathSegment] raise CairoError {
  self.segments().iter()
}

///|
/// Format segments in pycairo's newline-separated debug representation.
///
/// This representation is for diagnostics, not stable serialization. Raises
/// the path's checked `CairoError` status for invalid data or allocation errors.
pub fn Path::to_string(self : Path) -> String raise CairoError {
  let status = Ref(0)
  let bytes = @path_impl.to_string_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  @utf8.decode_lossy(bytes)
}
