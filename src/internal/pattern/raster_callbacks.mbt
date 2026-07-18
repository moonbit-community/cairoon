///|
pub fn raster_set_callbacks_raw(
  pattern : RawPattern,
  acquire? : ((@surface_impl.RawSurface, Int, Int, Int, Int) -> @surface_impl.RawSurface)? = None,
  release? : ((@surface_impl.RawSurface) -> Unit)? = None,
) -> Int {
  ensure_native()
  let call_acquire : FuncRef[
    (
      @surface_impl.RawSurface,
      Int,
      Int,
      Int,
      Int,
      (@surface_impl.RawSurface, Int, Int, Int, Int) -> @surface_impl.RawSurface,
    ) -> @surface_impl.RawSurface,
  ] = fn(target, x, y, width, height, acquire) {
    acquire(target, x, y, width, height)
  }
  let call_release : FuncRef[
    (@surface_impl.RawSurface, (@surface_impl.RawSurface) -> Unit) -> Unit,
  ] = fn(surface, release) { release(surface) }
  match release {
    None =>
      match acquire {
        None => raster_source_pattern_clear_acquire_ffi(pattern)
        Some(acquire) =>
          raster_source_pattern_set_acquire_ffi(pattern, call_acquire, acquire)
      }
    Some(release) =>
      match acquire {
        None =>
          raster_source_pattern_set_release_ffi(pattern, call_release, release)
        Some(acquire) =>
          raster_source_pattern_set_acquire_with_release_ffi(
            pattern, call_acquire, acquire, call_release, release,
          )
      }
  }
}

///|
pub fn raster_clear_callbacks_raw(pattern : RawPattern) -> Int {
  ensure_native()
  raster_source_pattern_clear_acquire_ffi(pattern)
}

///|
pub fn raster_has_callbacks_raw(
  pattern : RawPattern,
  has_acquire : Ref[Int],
  has_release : Ref[Int],
  status : Ref[Int],
) -> Bool {
  ensure_native()
  raster_source_pattern_has_callbacks_ffi(
    pattern, has_acquire, has_release, status,
  )
}

///|
pub fn raster_get_acquire_raw(
  pattern : RawPattern,
  status : Ref[Int],
) -> (@surface_impl.RawSurface, Int, Int, Int, Int) -> @surface_impl.RawSurface {
  ensure_native()
  raster_source_pattern_get_acquire_callback_ffi(pattern, status)
}

///|
pub fn raster_get_release_raw(
  pattern : RawPattern,
  status : Ref[Int],
) -> (@surface_impl.RawSurface) -> Unit {
  ensure_native()
  raster_source_pattern_get_release_callback_ffi(pattern, status)
}
