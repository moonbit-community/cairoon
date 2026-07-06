///|
extern "C" fn region_create_ffi() -> Region = "cairoon_region_create"

///|
extern "C" fn region_create_rectangle_ffi(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Region = "cairoon_region_create_rectangle"

///|
#borrow(xs, ys, widths, heights, status)
extern "C" fn region_create_rectangles_ffi(
  xs : FixedArray[Int],
  ys : FixedArray[Int],
  widths : FixedArray[Int],
  heights : FixedArray[Int],
  status : Ref[Status],
) -> Region = "cairoon_region_create_rectangles"

///|
#borrow(region)
extern "C" fn region_copy_ffi(region : Region) -> Region = "cairoon_region_copy"

///|
#borrow(region)
extern "C" fn region_status_ffi(region : Region) -> Status = "cairoon_region_status"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_extents_ffi(
  region : Region,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Status = "cairoon_region_get_extents"

///|
#borrow(region)
extern "C" fn region_num_rectangles_ffi(region : Region) -> Int = "cairoon_region_num_rectangles"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_rectangle_ffi(
  region : Region,
  index : Int,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Status = "cairoon_region_get_rectangle"

///|
#borrow(region)
extern "C" fn region_is_empty_ffi(region : Region) -> Bool = "cairoon_region_is_empty"

///|
#borrow(region)
extern "C" fn region_contains_point_ffi(
  region : Region,
  x : Int,
  y : Int,
) -> Bool = "cairoon_region_contains_point"

///|
#borrow(region)
extern "C" fn region_contains_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> RegionOverlap = "cairoon_region_contains_rectangle"

///|
#borrow(region, other)
extern "C" fn region_equal_ffi(region : Region, other : Region) -> Bool = "cairoon_region_equal"

///|
#borrow(region)
extern "C" fn region_translate_ffi(
  region : Region,
  dx : Int,
  dy : Int,
) -> Status = "cairoon_region_translate"

///|
#borrow(region, other)
extern "C" fn region_intersect_ffi(region : Region, other : Region) -> Status = "cairoon_region_intersect"

///|
#borrow(region)
extern "C" fn region_intersect_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_intersect_rectangle"

///|
#borrow(region, other)
extern "C" fn region_subtract_ffi(region : Region, other : Region) -> Status = "cairoon_region_subtract"

///|
#borrow(region)
extern "C" fn region_subtract_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_subtract_rectangle"

///|
#borrow(region, other)
extern "C" fn region_union_ffi(region : Region, other : Region) -> Status = "cairoon_region_union"

///|
#borrow(region)
extern "C" fn region_union_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_union_rectangle"

///|
#borrow(region, other)
extern "C" fn region_xor_ffi(region : Region, other : Region) -> Status = "cairoon_region_xor"

///|
#borrow(region)
extern "C" fn region_xor_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_xor_rectangle"
