///|
type RawRegion

///|
extern "C" fn region_create_ffi() -> RawRegion = "cairoon_region_create"

///|
extern "C" fn region_create_rectangle_ffi(
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> RawRegion = "cairoon_region_create_rectangle"

///|
#borrow(xs, ys, widths, heights, status)
extern "C" fn region_create_rectangles_ffi(
  xs : FixedArray[Int32],
  ys : FixedArray[Int32],
  widths : FixedArray[Int32],
  heights : FixedArray[Int32],
  status : Ref[Int32],
) -> RawRegion = "cairoon_region_create_rectangles"

///|
#borrow(region)
extern "C" fn region_copy_ffi(region : RawRegion) -> RawRegion = "cairoon_region_copy"

///|
#borrow(region)
extern "C" fn region_status_ffi(region : RawRegion) -> Int32 = "cairoon_region_status"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_extents_ffi(
  region : RawRegion,
  x : Ref[Int32],
  y : Ref[Int32],
  width : Ref[Int32],
  height : Ref[Int32],
) -> Int32 = "cairoon_region_get_extents"

///|
#borrow(region)
extern "C" fn region_num_rectangles_ffi(region : RawRegion) -> Int32 = "cairoon_region_num_rectangles"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_rectangle_ffi(
  region : RawRegion,
  index : Int32,
  x : Ref[Int32],
  y : Ref[Int32],
  width : Ref[Int32],
  height : Ref[Int32],
) -> Int32 = "cairoon_region_get_rectangle"

///|
#borrow(region)
extern "C" fn region_is_empty_ffi(region : RawRegion) -> Bool = "cairoon_region_is_empty"

///|
#borrow(region)
extern "C" fn region_contains_point_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
) -> Bool = "cairoon_region_contains_point"

///|
#borrow(region)
extern "C" fn region_contains_rectangle_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_region_contains_rectangle"

///|
#borrow(region, other)
extern "C" fn region_equal_ffi(region : RawRegion, other : RawRegion) -> Bool = "cairoon_region_equal"

///|
#borrow(region)
extern "C" fn region_translate_ffi(
  region : RawRegion,
  dx : Int32,
  dy : Int32,
) -> Int32 = "cairoon_region_translate"

///|
#borrow(region, other)
extern "C" fn region_intersect_ffi(
  region : RawRegion,
  other : RawRegion,
) -> Int32 = "cairoon_region_intersect"

///|
#borrow(region)
extern "C" fn region_intersect_rectangle_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_region_intersect_rectangle"

///|
#borrow(region, other)
extern "C" fn region_subtract_ffi(
  region : RawRegion,
  other : RawRegion,
) -> Int32 = "cairoon_region_subtract"

///|
#borrow(region)
extern "C" fn region_subtract_rectangle_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_region_subtract_rectangle"

///|
#borrow(region, other)
extern "C" fn region_union_ffi(region : RawRegion, other : RawRegion) -> Int32 = "cairoon_region_union"

///|
#borrow(region)
extern "C" fn region_union_rectangle_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_region_union_rectangle"

///|
#borrow(region, other)
extern "C" fn region_xor_ffi(region : RawRegion, other : RawRegion) -> Int32 = "cairoon_region_xor"

///|
#borrow(region)
extern "C" fn region_xor_rectangle_ffi(
  region : RawRegion,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_region_xor_rectangle"
