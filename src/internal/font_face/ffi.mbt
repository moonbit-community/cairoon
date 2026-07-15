///|
type RawFontFace

///|
#borrow(family)
extern "C" fn toy_font_face_create_ffi(
  family : Bytes,
  slant : Int,
  weight : Int,
) -> RawFontFace = "cairoon_toy_font_face_create"

///|
#borrow(family)
extern "C" fn toy_font_face_create_raw_ffi(
  family : Bytes,
  slant : Int,
  weight : Int,
) -> RawFontFace = "cairoon_toy_font_face_create_raw"

///|
#borrow(font_face)
extern "C" fn font_face_status_ffi(font_face : RawFontFace) -> Int = "cairoon_font_face_status"

///|
#borrow(font_face, other)
extern "C" fn font_face_equal_ffi(
  font_face : RawFontFace,
  other : RawFontFace,
) -> Bool = "cairoon_font_face_equal"

///|
#borrow(font_face)
extern "C" fn font_face_hash_ffi(font_face : RawFontFace) -> UInt64 = "cairoon_font_face_hash"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_family_ffi(
  font_face : RawFontFace,
  status : Ref[Int],
) -> Bytes = "cairoon_toy_font_face_get_family"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_slant_raw_ffi(
  font_face : RawFontFace,
  status : Ref[Int],
) -> Int = "cairoon_toy_font_face_get_slant_raw"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_weight_raw_ffi(
  font_face : RawFontFace,
  status : Ref[Int],
) -> Int = "cairoon_toy_font_face_get_weight_raw"
