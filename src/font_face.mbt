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
pub fn FontFace::toy_raw(
  family : String,
  slant? : Int = 0,
  weight? : Int = 0,
) -> FontFace raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  let font_face = toy_font_face_create_raw_ffi(bytes, slant, weight)
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
pub impl Eq for FontFace with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for FontFace with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for FontFace with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub fn FontFace::get_family(self : FontFace) -> String raise CairoError {
  let status = Ref(Success)
  let family = toy_font_face_get_family_ffi(self, status)
  check_status(status.val)
  @utf8.decode_lossy(family)
}

///|
fn font_slant_from_raw(raw : Int) -> FontSlant raise CairoError {
  match raw {
    0 => FontSlantNormal
    1 => FontSlantItalic
    2 => FontSlantOblique
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo font slant: \{raw}",
      )
  }
}

///|
fn font_weight_from_raw(raw : Int) -> FontWeight raise CairoError {
  match raw {
    0 => FontWeightNormal
    1 => FontWeightBold
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo font weight: \{raw}",
      )
  }
}

///|
pub fn FontFace::get_slant(self : FontFace) -> FontSlant raise CairoError {
  font_slant_from_raw(self.get_slant_raw())
}

///|
pub fn FontFace::get_slant_raw(self : FontFace) -> Int raise CairoError {
  let status = Ref(Success)
  let slant = toy_font_face_get_slant_raw_ffi(self, status)
  check_status(status.val)
  slant
}

///|
pub fn FontFace::get_weight(self : FontFace) -> FontWeight raise CairoError {
  font_weight_from_raw(self.get_weight_raw())
}

///|
pub fn FontFace::get_weight_raw(self : FontFace) -> Int raise CairoError {
  let status = Ref(Success)
  let weight = toy_font_face_get_weight_raw_ffi(self, status)
  check_status(status.val)
  weight
}
