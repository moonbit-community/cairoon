///|
#owned(acquire)
#borrow(pattern, call_acquire)
extern "C" fn raster_source_pattern_set_acquire_ffi(
  pattern : RawPattern,
  call_acquire : FuncRef[
    (
      @surface_impl.RawSurface,
      Int32,
      Int32,
      Int32,
      Int32,
      (@surface_impl.RawSurface, Int32, Int32, Int32, Int32) -> @surface_impl.RawSurface,
    ) -> @surface_impl.RawSurface,
  ],
  acquire : (@surface_impl.RawSurface, Int32, Int32, Int32, Int32) -> @surface_impl.RawSurface,
) -> Int32 = "cairoon_raster_source_pattern_set_acquire"

///|
#owned(acquire, release)
#borrow(pattern, call_acquire, call_release)
extern "C" fn raster_source_pattern_set_acquire_with_release_ffi(
  pattern : RawPattern,
  call_acquire : FuncRef[
    (
      @surface_impl.RawSurface,
      Int32,
      Int32,
      Int32,
      Int32,
      (@surface_impl.RawSurface, Int32, Int32, Int32, Int32) -> @surface_impl.RawSurface,
    ) -> @surface_impl.RawSurface,
  ],
  acquire : (@surface_impl.RawSurface, Int32, Int32, Int32, Int32) -> @surface_impl.RawSurface,
  call_release : FuncRef[
    (@surface_impl.RawSurface, (@surface_impl.RawSurface) -> Unit) -> Unit,
  ],
  release : (@surface_impl.RawSurface) -> Unit,
) -> Int32 = "cairoon_raster_source_pattern_set_acquire_with_release"

///|
#owned(release)
#borrow(pattern, call_release)
extern "C" fn raster_source_pattern_set_release_ffi(
  pattern : RawPattern,
  call_release : FuncRef[
    (@surface_impl.RawSurface, (@surface_impl.RawSurface) -> Unit) -> Unit,
  ],
  release : (@surface_impl.RawSurface) -> Unit,
) -> Int32 = "cairoon_raster_source_pattern_set_release"

///|
#borrow(pattern)
extern "C" fn raster_source_pattern_clear_acquire_ffi(
  pattern : RawPattern,
) -> Int32 = "cairoon_raster_source_pattern_clear_acquire"

///|
#borrow(pattern, has_acquire, has_release, status)
extern "C" fn raster_source_pattern_has_callbacks_ffi(
  pattern : RawPattern,
  has_acquire : Ref[Int32],
  has_release : Ref[Int32],
  status : Ref[Int32],
) -> Bool = "cairoon_raster_source_pattern_has_callbacks"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_acquire_callback_ffi(
  pattern : RawPattern,
  status : Ref[Int32],
) -> (@surface_impl.RawSurface, Int32, Int32, Int32, Int32) -> @surface_impl.RawSurface = "cairoon_raster_source_pattern_get_acquire_callback"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_release_callback_ffi(
  pattern : RawPattern,
  status : Ref[Int32],
) -> (@surface_impl.RawSurface) -> Unit = "cairoon_raster_source_pattern_get_release_callback"
