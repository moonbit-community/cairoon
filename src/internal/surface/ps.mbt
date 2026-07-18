///|
pub fn ps_create_raw(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  ps_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
}

///|
pub fn ps_create_stream_raw(
  writer : (Bytes) -> Int,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  ps_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
}

///|
pub fn ps_restrict_to_level_raw(surface : RawSurface, level : Int) -> Int {
  ensure_native()
  ps_surface_restrict_to_level_ffi(surface, level)
}

///|
pub fn ps_get_eps_raw(surface : RawSurface, status : Ref[Int]) -> Bool {
  ensure_native()
  ps_surface_get_eps_ffi(surface, status)
}

///|
pub fn ps_set_eps_raw(surface : RawSurface, eps : Bool) -> Int {
  ensure_native()
  ps_surface_set_eps_ffi(surface, eps)
}

///|
pub fn ps_set_size_raw(
  surface : RawSurface,
  width_in_points : Double,
  height_in_points : Double,
) -> Int {
  ensure_native()
  ps_surface_set_size_ffi(surface, width_in_points, height_in_points)
}

///|
pub fn ps_dsc_begin_setup_raw(surface : RawSurface) -> Int {
  ensure_native()
  ps_surface_dsc_begin_setup_ffi(surface)
}

///|
pub fn ps_dsc_begin_page_setup_raw(surface : RawSurface) -> Int {
  ensure_native()
  ps_surface_dsc_begin_page_setup_ffi(surface)
}

///|
pub fn ps_dsc_comment_raw(surface : RawSurface, comment : Bytes) -> Int {
  ensure_native()
  ps_surface_dsc_comment_ffi(surface, comment)
}
