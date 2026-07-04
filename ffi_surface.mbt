///|
#borrow(surface, status)
extern "C" fn surface_create_similar_ffi(
  surface : Surface,
  content : Content,
  width : Int,
  height : Int,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_similar"

///|
#borrow(surface, status)
extern "C" fn surface_create_similar_image_ffi(
  surface : Surface,
  format : Format,
  width : Int,
  height : Int,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_similar_image"

///|
#borrow(surface, status)
extern "C" fn surface_create_for_rectangle_ffi(
  surface : Surface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_for_rectangle"

///|
#borrow(surface)
extern "C" fn surface_status_ffi(surface : Surface) -> Status = "cairoon_surface_status"

///|
#borrow(surface, other)
extern "C" fn surface_equal_ffi(surface : Surface, other : Surface) -> Bool = "cairoon_surface_equal"

///|
#borrow(surface)
extern "C" fn surface_hash_ffi(surface : Surface) -> UInt64 = "cairoon_surface_hash"

///|
#borrow(surface)
extern "C" fn surface_get_content_ffi(surface : Surface) -> Content = "cairoon_surface_get_content"

///|
#borrow(surface)
extern "C" fn surface_get_type_ffi(surface : Surface) -> SurfaceType = "cairoon_surface_get_type"

///|
#borrow(surface)
extern "C" fn surface_finish_ffi(surface : Surface) -> Status = "cairoon_surface_finish"
