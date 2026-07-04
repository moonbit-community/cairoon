///|
#borrow(family)
extern "C" fn toy_font_face_create_ffi(
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> FontFace = "cairoon_toy_font_face_create"

///|
#borrow(font_face)
extern "C" fn font_face_status_ffi(font_face : FontFace) -> Status = "cairoon_font_face_status"

///|
#borrow(font_face, other)
extern "C" fn font_face_equal_ffi(
  font_face : FontFace,
  other : FontFace,
) -> Bool = "cairoon_font_face_equal"

///|
#borrow(font_face)
extern "C" fn font_face_hash_ffi(font_face : FontFace) -> UInt64 = "cairoon_font_face_hash"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_family_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> Bytes = "cairoon_toy_font_face_get_family"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_slant_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontSlant = "cairoon_toy_font_face_get_slant"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_weight_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontWeight = "cairoon_toy_font_face_get_weight"
