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
pub fn Path::status(self : Path) -> Status {
  path_status_ffi(self)
}

///|
pub fn Path::equal(self : Path, other : Path) -> Bool {
  path_equal_ffi(self, other)
}

///|
pub fn Path::hash(self : Path) -> UInt64 {
  path_hash_ffi(self)
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
  let status = Ref(Success)
  let count = path_num_segments_ffi(self, status)
  check_status(status.val)
  count
}

///|
pub fn Path::segments(self : Path) -> Array[PathSegment] raise CairoError {
  let status = Ref(Success)
  let data_count = path_num_data_ffi(self, status)
  check_status(status.val)
  let segment_count = path_num_segments_ffi(self, status)
  check_status(status.val)
  let segments : Array[PathSegment] = Array::new(capacity=segment_count)
  for data_index = 0; data_index < data_count; {
    let type_ = Ref(PathClosePath)
    let length = Ref(0)
    let x1 = Ref(0.0)
    let y1 = Ref(0.0)
    let x2 = Ref(0.0)
    let y2 = Ref(0.0)
    let x3 = Ref(0.0)
    let y3 = Ref(0.0)
    check_status(
      path_get_data_ffi(self, data_index, type_, length, x1, y1, x2, y2, x3, y3),
    )
    match type_.val {
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
  let status = Ref(Success)
  let bytes = path_to_string_ffi(self, status)
  check_status(status.val)
  @utf8.decode_lossy(bytes)
}
