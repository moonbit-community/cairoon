///|
type RawSurface

///|
#borrow(surface, status)
extern "C" fn surface_create_similar_raw_ffi(
  surface : RawSurface,
  content : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawSurface = "cairoon_surface_create_similar"

///|
#borrow(surface, status)
extern "C" fn surface_create_similar_image_raw_ffi(
  surface : RawSurface,
  format : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawSurface = "cairoon_surface_create_similar_image"

///|
#borrow(surface, status)
extern "C" fn surface_create_for_rectangle_ffi(
  surface : RawSurface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_surface_create_for_rectangle"

///|
#borrow(surface)
extern "C" fn surface_status_ffi(surface : RawSurface) -> Int = "cairoon_surface_status"

///|
#borrow(surface, other)
extern "C" fn surface_equal_ffi(
  surface : RawSurface,
  other : RawSurface,
) -> Bool = "cairoon_surface_equal"

///|
#borrow(surface)
extern "C" fn surface_hash_ffi(surface : RawSurface) -> UInt64 = "cairoon_surface_hash"

///|
#borrow(surface)
extern "C" fn surface_get_content_ffi(surface : RawSurface) -> Int = "cairoon_surface_get_content"

///|
#borrow(surface)
extern "C" fn surface_get_type_ffi(surface : RawSurface) -> Int = "cairoon_surface_get_type"

///|
#borrow(surface)
extern "C" fn surface_finish_ffi(surface : RawSurface) -> Int = "cairoon_surface_finish"
