///|
struct Region(@region_impl.RawRegion)

///|
fn Region::from_raw(raw : @region_impl.RawRegion) -> Region {
  Region(raw)
}

///|
fn Region::to_raw(self : Region) -> @region_impl.RawRegion {
  self.0
}

///|
fn region_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_region_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn region_overlap_from_raw(raw : Int) -> RegionOverlap {
  match raw {
    0 => RegionOverlapIn
    1 => RegionOverlapOut
    2 => RegionOverlapPart
    _ => RegionOverlapOut
  }
}

///|
pub fn Region::new() -> Region raise CairoError {
  let raw = @region_impl.create_raw()
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
pub fn Region::from_rectangle(
  rectangle : RectangleInt,
) -> Region raise CairoError {
  let raw = @region_impl.create_rectangle_raw(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height,
  )
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
pub fn Region::from_rectangles(
  rectangles : ArrayView[RectangleInt],
) -> Region raise CairoError {
  let count = rectangles.length()
  let status = Ref(0)
  let raw = @region_impl.create_rectangles_raw(
    FixedArray::makei(count, index => rectangles[index].x),
    FixedArray::makei(count, index => rectangles[index].y),
    FixedArray::makei(count, index => rectangles[index].width),
    FixedArray::makei(count, index => rectangles[index].height),
    status,
  )
  check_region_status_raw(status.val)
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
pub fn Region::copy(self : Region) -> Region raise CairoError {
  let raw = @region_impl.copy_raw(self.to_raw())
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
pub fn Region::status(self : Region) -> Status {
  region_status_from_raw(@region_impl.status_raw(self.to_raw()))
}

///|
fn rectangle_int_from_region_output(
  f : (Ref[Int], Ref[Int], Ref[Int], Ref[Int]) -> Int,
) -> RectangleInt raise CairoError {
  let x = Ref(0)
  let y = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  check_region_status_raw(f(x, y, width, height))
  RectangleInt::new(x=x.val, y=y.val, width=width.val, height=height.val)
}

///|
pub fn Region::get_extents(self : Region) -> RectangleInt raise CairoError {
  rectangle_int_from_region_output((x, y, width, height) => {
    @region_impl.get_extents_raw(self.to_raw(), x, y, width, height)
  })
}

///|
pub fn Region::num_rectangles(self : Region) -> Int {
  @region_impl.num_rectangles_raw(self.to_raw())
}

///|
pub fn Region::get_rectangle(
  self : Region,
  index : Int,
) -> RectangleInt raise CairoError {
  if index < 0 || index >= self.num_rectangles() {
    raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
  rectangle_int_from_region_output((x, y, width, height) => {
    @region_impl.get_rectangle_raw(self.to_raw(), index, x, y, width, height)
  })
}

///|
pub fn Region::is_empty(self : Region) -> Bool {
  @region_impl.is_empty_raw(self.to_raw())
}

///|
pub fn Region::contains_point(self : Region, x : Int, y : Int) -> Bool {
  @region_impl.contains_point_raw(self.to_raw(), x, y)
}

///|
pub fn Region::contains_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> RegionOverlap {
  region_overlap_from_raw(
    @region_impl.contains_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}

///|
pub fn Region::equal(self : Region, other : Region) -> Bool {
  @region_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub impl Eq for Region with fn equal(self, other) {
  self.equal(other)
}

///|
pub fn Region::translate(
  self : Region,
  dx : Int,
  dy : Int,
) -> Unit raise CairoError {
  check_region_status_raw(@region_impl.translate_raw(self.to_raw(), dx, dy))
}

///|
pub fn Region::intersect(
  self : Region,
  other : Region,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.intersect_raw(self.to_raw(), other.to_raw()),
  )
  self
}

///|
pub fn Region::intersect_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.intersect_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
pub fn Region::subtract(
  self : Region,
  other : Region,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.subtract_raw(self.to_raw(), other.to_raw()),
  )
  self
}

///|
pub fn Region::subtract_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.subtract_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
pub fn Region::union(self : Region, other : Region) -> Region raise CairoError {
  check_region_status_raw(@region_impl.union_raw(self.to_raw(), other.to_raw()))
  self
}

///|
pub fn Region::union_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.union_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
pub fn Region::xor(self : Region, other : Region) -> Region raise CairoError {
  check_region_status_raw(@region_impl.xor_raw(self.to_raw(), other.to_raw()))
  self
}

///|
pub fn Region::xor_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.xor_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}
