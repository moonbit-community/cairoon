///|
struct FontFace(@font_face_impl.RawFontFace)

///|
fn FontFace::from_raw(raw : @font_face_impl.RawFontFace) -> FontFace {
  FontFace(raw)
}

///|
fn FontFace::to_raw(self : FontFace) -> @font_face_impl.RawFontFace {
  self.0
}

///|
fn font_face_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_font_face_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn font_slant_to_raw(slant : FontSlant) -> Int {
  match slant {
    FontSlantNormal => 0
    FontSlantItalic => 1
    FontSlantOblique => 2
  }
}

///|
fn font_weight_to_raw(weight : FontWeight) -> Int {
  match weight {
    FontWeightNormal => 0
    FontWeightBold => 1
  }
}

///|
pub fn FontFace::toy(
  family : String,
  slant? : FontSlant = FontSlantNormal,
  weight? : FontWeight = FontWeightNormal,
) -> FontFace raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  let raw = @font_face_impl.toy_create_value_raw(
    bytes,
    font_slant_to_raw(slant),
    font_weight_to_raw(weight),
  )
  check_font_face_status_raw(@font_face_impl.status_raw(raw))
  FontFace::from_raw(raw)
}

///|
pub fn FontFace::toy_raw(
  family : String,
  slant? : Int = 0,
  weight? : Int = 0,
) -> FontFace raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  let raw = @font_face_impl.toy_create_raw(bytes, slant, weight)
  check_font_face_status_raw(@font_face_impl.status_raw(raw))
  FontFace::from_raw(raw)
}

///|
pub fn FontFace::status(self : FontFace) -> Status {
  font_face_status_from_raw(@font_face_impl.status_raw(self.to_raw()))
}

///|
pub fn FontFace::equal(self : FontFace, other : FontFace) -> Bool {
  @font_face_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub fn FontFace::hash(self : FontFace) -> UInt64 {
  @font_face_impl.hash_raw(self.to_raw())
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
  let status = Ref(0)
  let family = @font_face_impl.get_family_raw(self.to_raw(), status)
  check_font_face_status_raw(status.val)
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
  let status = Ref(0)
  let slant = @font_face_impl.get_slant_raw(self.to_raw(), status)
  check_font_face_status_raw(status.val)
  slant
}

///|
pub fn FontFace::get_weight(self : FontFace) -> FontWeight raise CairoError {
  font_weight_from_raw(self.get_weight_raw())
}

///|
pub fn FontFace::get_weight_raw(self : FontFace) -> Int raise CairoError {
  let status = Ref(0)
  let weight = @font_face_impl.get_weight_raw(self.to_raw(), status)
  check_font_face_status_raw(status.val)
  weight
}
