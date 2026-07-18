///|
#borrow(filename, status)
extern "C" fn ps_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_ps_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn ps_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_ps_surface_create_for_stream"

///|
#borrow(surface)
extern "C" fn ps_surface_restrict_to_level_ffi(
  surface : RawSurface,
  level : Int,
) -> Int = "cairoon_ps_surface_restrict_to_level"

///|
#borrow(surface, status)
extern "C" fn ps_surface_get_eps_ffi(
  surface : RawSurface,
  status : Ref[Int],
) -> Bool = "cairoon_ps_surface_get_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_eps_ffi(surface : RawSurface, eps : Bool) -> Int = "cairoon_ps_surface_set_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_size_ffi(
  surface : RawSurface,
  width_in_points : Double,
  height_in_points : Double,
) -> Int = "cairoon_ps_surface_set_size"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_setup_ffi(surface : RawSurface) -> Int = "cairoon_ps_surface_dsc_begin_setup"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_page_setup_ffi(surface : RawSurface) -> Int = "cairoon_ps_surface_dsc_begin_page_setup"

///|
#borrow(surface, comment)
extern "C" fn ps_surface_dsc_comment_ffi(
  surface : RawSurface,
  comment : Bytes,
) -> Int = "cairoon_ps_surface_dsc_comment"
