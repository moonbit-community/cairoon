///|
pub fn Region::new() -> Region raise CairoError {
  let region = region_create_ffi()
  check_status(region_status_ffi(region))
  region
}

///|
pub fn Region::from_rectangle(
  rectangle : RectangleInt,
) -> Region raise CairoError {
  let region = region_create_rectangle_ffi(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height,
  )
  check_status(region_status_ffi(region))
  region
}

///|
pub fn Region::copy(self : Region) -> Region raise CairoError {
  let region = region_copy_ffi(self)
  check_status(region_status_ffi(region))
  region
}

///|
pub fn Region::status(self : Region) -> Status {
  region_status_ffi(self)
}

///|
fn rectangle_int_from_region_output(
  f : (Ref[Int], Ref[Int], Ref[Int], Ref[Int]) -> Status,
) -> RectangleInt raise CairoError {
  let x = Ref(0)
  let y = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  check_status(f(x, y, width, height))
  RectangleInt::new(x=x.val, y=y.val, width=width.val, height=height.val)
}

///|
pub fn Region::get_extents(self : Region) -> RectangleInt raise CairoError {
  rectangle_int_from_region_output((x, y, width, height) => {
    region_get_extents_ffi(self, x, y, width, height)
  })
}

///|
pub fn Region::num_rectangles(self : Region) -> Int {
  region_num_rectangles_ffi(self)
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
    region_get_rectangle_ffi(self, index, x, y, width, height)
  })
}

///|
pub fn Region::is_empty(self : Region) -> Bool {
  region_is_empty_ffi(self)
}

///|
pub fn Region::contains_point(self : Region, x : Int, y : Int) -> Bool {
  region_contains_point_ffi(self, x, y)
}

///|
pub fn Region::contains_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> RegionOverlap {
  region_contains_rectangle_ffi(
    self,
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height,
  )
}

///|
pub fn Region::equal(self : Region, other : Region) -> Bool {
  region_equal_ffi(self, other)
}

///|
pub fn Region::translate(
  self : Region,
  dx : Int,
  dy : Int,
) -> Unit raise CairoError {
  check_status(region_translate_ffi(self, dx, dy))
}

///|
pub fn Region::intersect(
  self : Region,
  other : Region,
) -> Unit raise CairoError {
  check_status(region_intersect_ffi(self, other))
}

///|
pub fn Region::intersect_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Unit raise CairoError {
  check_status(
    region_intersect_rectangle_ffi(
      self,
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}

///|
pub fn Region::subtract(self : Region, other : Region) -> Unit raise CairoError {
  check_status(region_subtract_ffi(self, other))
}

///|
pub fn Region::subtract_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Unit raise CairoError {
  check_status(
    region_subtract_rectangle_ffi(
      self,
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}

///|
pub fn Region::union(self : Region, other : Region) -> Unit raise CairoError {
  check_status(region_union_ffi(self, other))
}

///|
pub fn Region::union_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Unit raise CairoError {
  check_status(
    region_union_rectangle_ffi(
      self,
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}

///|
pub fn Region::xor(self : Region, other : Region) -> Unit raise CairoError {
  check_status(region_xor_ffi(self, other))
}

///|
pub fn Region::xor_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Unit raise CairoError {
  check_status(
    region_xor_rectangle_ffi(
      self,
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}
