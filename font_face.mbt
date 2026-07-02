///|
pub fn FontFace::toy(
  family : String,
  slant? : FontSlant = FontSlantNormal,
  weight? : FontWeight = FontWeightNormal,
) -> FontFace raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  let font_face = toy_font_face_create_ffi(bytes, slant, weight)
  check_status(font_face_status_ffi(font_face))
  font_face
}

///|
pub fn FontFace::status(self : FontFace) -> Status {
  font_face_status_ffi(self)
}

///|
pub fn FontFace::equal(self : FontFace, other : FontFace) -> Bool {
  font_face_equal_ffi(self, other)
}

///|
pub fn FontFace::hash(self : FontFace) -> UInt64 {
  font_face_hash_ffi(self)
}

///|
pub fn FontFace::get_family(self : FontFace) -> String raise CairoError {
  let status = Ref(Success)
  let family = toy_font_face_get_family_ffi(self, status)
  check_status(status.val)
  @utf8.decode_lossy(family)
}

///|
pub fn FontFace::get_slant(self : FontFace) -> FontSlant raise CairoError {
  let status = Ref(Success)
  let slant = toy_font_face_get_slant_ffi(self, status)
  check_status(status.val)
  slant
}

///|
pub fn FontFace::get_weight(self : FontFace) -> FontWeight raise CairoError {
  let status = Ref(Success)
  let weight = toy_font_face_get_weight_ffi(self, status)
  check_status(status.val)
  weight
}
