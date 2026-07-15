///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn create_raw() -> RawRegion {
  ensure_native()
  region_create_ffi()
}

///|
pub fn create_rectangle_raw(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> RawRegion {
  ensure_native()
  region_create_rectangle_ffi(x, y, width, height)
}

///|
pub fn create_rectangles_raw(
  xs : FixedArray[Int],
  ys : FixedArray[Int],
  widths : FixedArray[Int],
  heights : FixedArray[Int],
  status : Ref[Int],
) -> RawRegion {
  ensure_native()
  region_create_rectangles_ffi(xs, ys, widths, heights, status)
}

///|
pub fn copy_raw(region : RawRegion) -> RawRegion {
  ensure_native()
  region_copy_ffi(region)
}

///|
pub fn status_raw(region : RawRegion) -> Int {
  ensure_native()
  region_status_ffi(region)
}

///|
pub fn get_extents_raw(
  region : RawRegion,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Int {
  ensure_native()
  region_get_extents_ffi(region, x, y, width, height)
}

///|
pub fn num_rectangles_raw(region : RawRegion) -> Int {
  ensure_native()
  region_num_rectangles_ffi(region)
}

///|
pub fn get_rectangle_raw(
  region : RawRegion,
  index : Int,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Int {
  ensure_native()
  region_get_rectangle_ffi(region, index, x, y, width, height)
}

///|
pub fn is_empty_raw(region : RawRegion) -> Bool {
  ensure_native()
  region_is_empty_ffi(region)
}

///|
pub fn contains_point_raw(region : RawRegion, x : Int, y : Int) -> Bool {
  ensure_native()
  region_contains_point_ffi(region, x, y)
}

///|
pub fn contains_rectangle_raw(
  region : RawRegion,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  region_contains_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn equal_raw(region : RawRegion, other : RawRegion) -> Bool {
  ensure_native()
  region_equal_ffi(region, other)
}

///|
pub fn translate_raw(region : RawRegion, dx : Int, dy : Int) -> Int {
  ensure_native()
  region_translate_ffi(region, dx, dy)
}

///|
pub fn intersect_raw(region : RawRegion, other : RawRegion) -> Int {
  ensure_native()
  region_intersect_ffi(region, other)
}

///|
pub fn intersect_rectangle_raw(
  region : RawRegion,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  region_intersect_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn subtract_raw(region : RawRegion, other : RawRegion) -> Int {
  ensure_native()
  region_subtract_ffi(region, other)
}

///|
pub fn subtract_rectangle_raw(
  region : RawRegion,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  region_subtract_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn union_raw(region : RawRegion, other : RawRegion) -> Int {
  ensure_native()
  region_union_ffi(region, other)
}

///|
pub fn union_rectangle_raw(
  region : RawRegion,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  region_union_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn xor_raw(region : RawRegion, other : RawRegion) -> Int {
  ensure_native()
  region_xor_ffi(region, other)
}

///|
pub fn xor_rectangle_raw(
  region : RawRegion,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  region_xor_rectangle_ffi(region, x, y, width, height)
}
