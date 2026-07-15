///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn toy_create_value_raw(
  family : Bytes,
  slant : Int,
  weight : Int,
) -> RawFontFace {
  ensure_native()
  toy_font_face_create_ffi(family, slant, weight)
}

///|
pub fn toy_create_raw(family : Bytes, slant : Int, weight : Int) -> RawFontFace {
  ensure_native()
  toy_font_face_create_raw_ffi(family, slant, weight)
}

///|
pub fn status_raw(font_face : RawFontFace) -> Int {
  ensure_native()
  font_face_status_ffi(font_face)
}

///|
pub fn equal_raw(font_face : RawFontFace, other : RawFontFace) -> Bool {
  ensure_native()
  font_face_equal_ffi(font_face, other)
}

///|
pub fn hash_raw(font_face : RawFontFace) -> UInt64 {
  ensure_native()
  font_face_hash_ffi(font_face)
}

///|
pub fn get_family_raw(font_face : RawFontFace, status : Ref[Int]) -> Bytes {
  ensure_native()
  toy_font_face_get_family_ffi(font_face, status)
}

///|
pub fn get_slant_raw(font_face : RawFontFace, status : Ref[Int]) -> Int {
  ensure_native()
  toy_font_face_get_slant_raw_ffi(font_face, status)
}

///|
pub fn get_weight_raw(font_face : RawFontFace, status : Ref[Int]) -> Int {
  ensure_native()
  toy_font_face_get_weight_raw_ffi(font_face, status)
}
