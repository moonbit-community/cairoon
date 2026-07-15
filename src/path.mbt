///|
pub(all) enum PathSegment {
  PathSegmentMoveTo(Double, Double)
  PathSegmentLineTo(Double, Double)
  PathSegmentCurveTo(Double, Double, Double, Double, Double, Double)
  PathSegmentClosePath
} derive(Eq, Debug)

///|
pub fn PathSegment::data_type(self : PathSegment) -> PathDataType {
  match self {
    PathSegmentMoveTo(_, _) => PathMoveTo
    PathSegmentLineTo(_, _) => PathLineTo
    PathSegmentCurveTo(_, _, _, _, _, _) => PathCurveTo
    PathSegmentClosePath => PathClosePath
  }
}

///|
pub fn PathSegment::coordinates(self : PathSegment) -> Array[Double] {
  match self {
    PathSegmentMoveTo(x, y) | PathSegmentLineTo(x, y) => [x, y]
    PathSegmentCurveTo(x1, y1, x2, y2, x3, y3) => [x1, y1, x2, y2, x3, y3]
    PathSegmentClosePath => []
  }
}

///|
pub fn PathSegment::components(
  self : PathSegment,
) -> (PathDataType, Array[Double]) {
  (self.data_type(), self.coordinates())
}

///|
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
pub fn Path::status(self : Path) -> Status {
  path_status_from_raw(@path_impl.status_raw(self.to_raw()))
}

///|
pub fn Path::equal(self : Path, other : Path) -> Bool {
  @path_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
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
pub fn Path::length(self : Path) -> Int raise CairoError {
  let status = Ref(0)
  let count = @path_impl.num_segments_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  count
}

///|
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
pub fn Path::iter(self : Path) -> Iter[PathSegment] raise CairoError {
  self.segments().iter()
}

///|
pub fn Path::to_string(self : Path) -> String raise CairoError {
  let status = Ref(0)
  let bytes = @path_impl.to_string_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  @utf8.decode_lossy(bytes)
}
