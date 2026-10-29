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
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> RawRegion {
  ensure_native()
  region_create_rectangle_ffi(x, y, width, height)
}

///|
pub fn create_rectangles_raw(
  xs : FixedArray[Int32],
  ys : FixedArray[Int32],
  widths : FixedArray[Int32],
  heights : FixedArray[Int32],
  status : Ref[Int32],
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
pub fn status_raw(region : RawRegion) -> Int32 {
  ensure_native()
  region_status_ffi(region)
}

///|
pub fn get_extents_raw(
  region : RawRegion,
  x : Ref[Int32],
  y : Ref[Int32],
  width : Ref[Int32],
  height : Ref[Int32],
) -> Int32 {
  ensure_native()
  region_get_extents_ffi(region, x, y, width, height)
}

///|
pub fn num_rectangles_raw(region : RawRegion) -> Int32 {
  ensure_native()
  region_num_rectangles_ffi(region)
}

///|
pub fn get_rectangle_raw(
  region : RawRegion,
  index : Int32,
  x : Ref[Int32],
  y : Ref[Int32],
  width : Ref[Int32],
  height : Ref[Int32],
) -> Int32 {
  ensure_native()
  region_get_rectangle_ffi(region, index, x, y, width, height)
}

///|
pub fn is_empty_raw(region : RawRegion) -> Bool {
  ensure_native()
  region_is_empty_ffi(region)
}

///|
pub fn contains_point_raw(region : RawRegion, x : Int32, y : Int32) -> Bool {
  ensure_native()
  region_contains_point_ffi(region, x, y)
}

///|
pub fn contains_rectangle_raw(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  region_contains_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn equal_raw(region : RawRegion, other : RawRegion) -> Bool {
  ensure_native()
  region_equal_ffi(region, other)
}

///|
pub fn translate_raw(region : RawRegion, dx : Int32, dy : Int32) -> Int32 {
  ensure_native()
  region_translate_ffi(region, dx, dy)
}

///|
pub fn intersect_raw(region : RawRegion, other : RawRegion) -> Int32 {
  ensure_native()
  region_intersect_ffi(region, other)
}

///|
pub fn intersect_rectangle_raw(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  region_intersect_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn subtract_raw(region : RawRegion, other : RawRegion) -> Int32 {
  ensure_native()
  region_subtract_ffi(region, other)
}

///|
pub fn subtract_rectangle_raw(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  region_subtract_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn union_raw(region : RawRegion, other : RawRegion) -> Int32 {
  ensure_native()
  region_union_ffi(region, other)
}

///|
pub fn union_rectangle_raw(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  region_union_rectangle_ffi(region, x, y, width, height)
}

///|
pub fn xor_raw(region : RawRegion, other : RawRegion) -> Int32 {
  ensure_native()
  region_xor_ffi(region, other)
}

///|
pub fn xor_rectangle_raw(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  region_xor_rectangle_ffi(region, x, y, width, height)
}
