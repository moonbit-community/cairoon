///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn create_similar_raw(
  surface : RawSurface,
  content : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  surface_create_similar_raw_ffi(surface, content, width, height, status)
}

///|
pub fn create_similar_image_raw(
  surface : RawSurface,
  format : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  surface_create_similar_image_raw_ffi(surface, format, width, height, status)
}

///|
pub fn create_for_rectangle_raw(
  surface : RawSurface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  surface_create_for_rectangle_ffi(surface, x, y, width, height, status)
}

///|
pub fn status_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_status_ffi(surface)
}

///|
pub fn equal_raw(surface : RawSurface, other : RawSurface) -> Bool {
  ensure_native()
  surface_equal_ffi(surface, other)
}

///|
pub fn hash_raw(surface : RawSurface) -> UInt64 {
  ensure_native()
  surface_hash_ffi(surface)
}

///|
pub fn get_content_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_get_content_ffi(surface)
}

///|
pub fn get_type_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_get_type_ffi(surface)
}

///|
pub fn finish_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_finish_ffi(surface)
}
