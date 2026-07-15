///|
#borrow(pattern)
extern "C" fn pattern_set_extend_ffi(
  pattern : @pattern_impl.RawPattern,
  extend_mode : Extend,
) -> Status = "cairoon_pattern_set_extend"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_ffi(
  pattern : @pattern_impl.RawPattern,
  filter : Filter,
) -> Status = "cairoon_pattern_set_filter"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_ffi(
  pattern : @pattern_impl.RawPattern,
  dither : Dither,
) -> Status = "cairoon_pattern_set_dither"
