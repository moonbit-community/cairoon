///|
extern "C" fn pattern_create_raster_source_ffi(
  content : Content,
  width : Int,
  height : Int,
) -> Pattern = "cairoon_pattern_create_raster_source"

///|
#owned(acquire)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_acquire_ffi(
  pattern : Pattern,
  call_acquire : FuncRef[
    (Surface, Int, Int, Int, Int, (Surface, RectangleInt) -> Surface) -> Surface,
  ],
  acquire : (Surface, RectangleInt) -> Surface,
) -> Status = "cairoon_raster_source_pattern_set_acquire"

///|
#owned(acquire, release)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_acquire_with_release_ffi(
  pattern : Pattern,
  call_acquire : FuncRef[
    (Surface, Int, Int, Int, Int, (Surface, RectangleInt) -> Surface) -> Surface,
  ],
  acquire : (Surface, RectangleInt) -> Surface,
  call_release : FuncRef[(Surface, (Surface) -> Unit) -> Unit],
  release : (Surface) -> Unit,
) -> Status = "cairoon_raster_source_pattern_set_acquire_with_release"

///|
#owned(release)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_release_ffi(
  pattern : Pattern,
  call_release : FuncRef[(Surface, (Surface) -> Unit) -> Unit],
  release : (Surface) -> Unit,
) -> Status = "cairoon_raster_source_pattern_set_release"

///|
#borrow(pattern)
extern "C" fn raster_source_pattern_clear_acquire_ffi(
  pattern : Pattern,
) -> Status = "cairoon_raster_source_pattern_clear_acquire"

///|
#borrow(pattern, has_acquire, has_release, status)
extern "C" fn raster_source_pattern_has_callbacks_ffi(
  pattern : Pattern,
  has_acquire : Ref[Int],
  has_release : Ref[Int],
  status : Ref[Status],
) -> Bool = "cairoon_raster_source_pattern_has_callbacks"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_acquire_callback_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> (Surface, RectangleInt) -> Surface = "cairoon_raster_source_pattern_get_acquire_callback"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_release_callback_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> (Surface) -> Unit = "cairoon_raster_source_pattern_get_release_callback"
