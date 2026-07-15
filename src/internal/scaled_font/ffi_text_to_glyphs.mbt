///|
type RawTextToGlyphs

///|
#borrow(scaled_font, text)
extern "C" fn scaled_font_text_to_glyphs_ffi(
  scaled_font : RawScaledFont,
  x : Double,
  y : Double,
  text : Bytes,
) -> RawTextToGlyphs = "cairoon_scaled_font_text_to_glyphs"

///|
#borrow(result)
extern "C" fn text_to_glyphs_status_ffi(result : RawTextToGlyphs) -> Int = "cairoon_text_to_glyphs_status"

///|
#borrow(result)
extern "C" fn text_to_glyphs_indices_ffi(
  result : RawTextToGlyphs,
) -> FixedArray[UInt64] = "cairoon_text_to_glyphs_indices"

///|
#borrow(result)
extern "C" fn text_to_glyphs_positions_ffi(
  result : RawTextToGlyphs,
) -> FixedArray[Double] = "cairoon_text_to_glyphs_positions"

///|
#borrow(result)
extern "C" fn text_to_glyphs_clusters_ffi(
  result : RawTextToGlyphs,
) -> FixedArray[Int] = "cairoon_text_to_glyphs_clusters"

///|
#borrow(result)
extern "C" fn text_to_glyphs_flags_ffi(result : RawTextToGlyphs) -> Int = "cairoon_text_to_glyphs_flags"
