///|
/// An owning facade for a Cairo font face without size or transformation.
///
/// A `FontFace` holds one internal `RawFontFace` owner whose finalizer calls
/// `cairo_font_face_destroy`; this facade adds no second finalizer. Font faces
/// have native pointer identity and can be shared independently by contexts
/// and scaled fonts through Cairo references.
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
/// Create a face through Cairo's simplified toy-font selector.
///
/// `slant` and `weight` default to their normal typed variants. An empty
/// `family` asks Cairo for the platform-specific default. The family is UTF-8;
/// an embedded NUL raises `CairoInvalidArgument(InvalidString, _)`. This API is
/// intended for simple text and demonstrations, not font discovery, shaping,
/// kerning, fallback, or complex-script layout. Allocation and backend errors
/// use the checked `CairoError` hierarchy.
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
/// Create a toy face from pycairo-compatible raw C enum integers.
///
/// Prefer `FontFace::toy()` for typed code. Known values round-trip through the
/// typed getters; unsupported values are passed to Cairo and raise
/// `CairoError(InvalidSlant, _)` or `CairoError(InvalidWeight, _)`. Family-name
/// encoding, empty-family behavior, ownership, and other failures match
/// `FontFace::toy()`.
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
/// Return the font face's current sticky Cairo status without raising.
///
/// `Success` means no error has been recorded. An unknown raw status at the
/// native boundary is represented as `InvalidStatus`.
pub fn FontFace::status(self : FontFace) -> Status {
  font_face_status_from_raw(@font_face_impl.status_raw(self.to_raw()))
}

///|
/// Test whether two wrappers refer to the same native font face.
///
/// This is pointer identity, not equality of family, slant, or weight. It is
/// consistent with the `Eq` implementation and `hash()`; independently
/// constructed faces are not promised to compare equal.
pub fn FontFace::equal(self : FontFace, other : FontFace) -> Bool {
  @font_face_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return a stable identity hash for this native font face.
///
/// Wrappers that compare equal produce the same hash. The value identifies the
/// pointer only during its lifetime and is not a persistent font identifier.
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
/// Return a MoonBit-owned copy of this toy face's family name.
///
/// For an empty constructor family, Cairo may return its platform-specific
/// default. The native string is copied before loss-tolerant UTF-8 decoding, so
/// the result remains valid after the face leaves scope. A non-toy face raises
/// `CairoError(FontTypeMismatch, _)`; other failures use its checked status.
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
/// Return this toy face's slant as a typed `FontSlant`.
///
/// A non-toy face raises `CairoError(FontTypeMismatch, _)`. If a future Cairo
/// version returns an unknown raw value, this typed boundary raises
/// `CairoInvalidArgument(InvalidStatus, _)` rather than guessing.
pub fn FontFace::get_slant(self : FontFace) -> FontSlant raise CairoError {
  font_slant_from_raw(self.get_slant_raw())
}

///|
/// Return this toy face's slant as the underlying Cairo C integer.
///
/// This pycairo compatibility entry point preserves the raw value. Prefer
/// `get_slant()` when exhaustive typed handling is desired. A non-toy face or
/// errored object raises its checked `CairoError`.
pub fn FontFace::get_slant_raw(self : FontFace) -> Int raise CairoError {
  let status = Ref(0)
  let slant = @font_face_impl.get_slant_raw(self.to_raw(), status)
  check_font_face_status_raw(status.val)
  slant
}

///|
/// Return this toy face's weight as a typed `FontWeight`.
///
/// A non-toy face raises `CairoError(FontTypeMismatch, _)`. An unknown future
/// raw value raises `CairoInvalidArgument(InvalidStatus, _)` at this typed
/// boundary.
pub fn FontFace::get_weight(self : FontFace) -> FontWeight raise CairoError {
  font_weight_from_raw(self.get_weight_raw())
}

///|
/// Return this toy face's weight as the underlying Cairo C integer.
///
/// This pycairo compatibility entry point preserves the raw value. Prefer
/// `get_weight()` for typed code. A non-toy face or errored object raises its
/// checked `CairoError`.
pub fn FontFace::get_weight_raw(self : FontFace) -> Int raise CairoError {
  let status = Ref(0)
  let weight = @font_face_impl.get_weight_raw(self.to_raw(), status)
  check_font_face_status_raw(status.val)
  weight
}
