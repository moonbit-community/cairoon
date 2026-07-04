///|
#borrow(result)
extern "C" fn text_to_glyphs_status_ffi(result : TextToGlyphsNative) -> Status = "cairoon_text_to_glyphs_status"

///|
#borrow(result)
extern "C" fn text_to_glyphs_indices_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[UInt64] = "cairoon_text_to_glyphs_indices"

///|
#borrow(result)
extern "C" fn text_to_glyphs_positions_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Double] = "cairoon_text_to_glyphs_positions"

///|
#borrow(result)
extern "C" fn text_to_glyphs_clusters_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Int] = "cairoon_text_to_glyphs_clusters"

///|
#borrow(result)
extern "C" fn text_to_glyphs_flags_ffi(
  result : TextToGlyphsNative,
) -> TextClusterFlags = "cairoon_text_to_glyphs_flags"
