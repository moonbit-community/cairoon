///|
#borrow(filename, status)
extern "C" fn ps_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_ps_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn ps_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_ps_surface_create_for_stream"

///|
#borrow(status)
extern "C" fn ps_get_level_count_ffi(status : Ref[Status]) -> Int = "cairoon_ps_get_level_count"

///|
#borrow(status)
extern "C" fn ps_get_level_ffi(index : Int, status : Ref[Status]) -> PSLevel = "cairoon_ps_get_level"

///|
#borrow(status)
extern "C" fn ps_level_to_string_ffi(
  level : PSLevel,
  status : Ref[Status],
) -> Bytes = "cairoon_ps_level_to_string"

///|
#borrow(status)
extern "C" fn ps_level_to_string_raw_ffi(
  level : Int,
  status : Ref[Status],
) -> Bytes = "cairoon_ps_level_to_string"

///|
#borrow(surface)
extern "C" fn ps_surface_restrict_to_level_ffi(
  surface : Surface,
  level : PSLevel,
) -> Status = "cairoon_ps_surface_restrict_to_level"

///|
#borrow(surface)
extern "C" fn ps_surface_restrict_to_level_raw_ffi(
  surface : Surface,
  level : Int,
) -> Status = "cairoon_ps_surface_restrict_to_level"

///|
#borrow(surface, status)
extern "C" fn ps_surface_get_eps_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Bool = "cairoon_ps_surface_get_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_eps_ffi(surface : Surface, eps : Bool) -> Status = "cairoon_ps_surface_set_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_size_ffi(
  surface : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Status = "cairoon_ps_surface_set_size"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_setup_ffi(surface : Surface) -> Status = "cairoon_ps_surface_dsc_begin_setup"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_page_setup_ffi(surface : Surface) -> Status = "cairoon_ps_surface_dsc_begin_page_setup"

///|
#borrow(surface, comment)
extern "C" fn ps_surface_dsc_comment_ffi(
  surface : Surface,
  comment : Bytes,
) -> Status = "cairoon_ps_surface_dsc_comment"
