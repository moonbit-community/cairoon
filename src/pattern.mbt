///|
/// An owned Cairo drawing source used by `Context::set_source` and masks.
///
/// A value owns one native pattern reference through its private raw handle;
/// MoonBit finalization releases that reference. Solid, surface, gradient,
/// mesh, and raster-source subtypes share this wrapper. Equality and hashing
/// use native pointer identity, not rendered-value equality.
struct Pattern(@pattern_impl.RawPattern)

///|
fn Pattern::from_raw(raw : @pattern_impl.RawPattern) -> Pattern {
  Pattern(raw)
}

///|
fn Pattern::to_raw(self : Pattern) -> @pattern_impl.RawPattern {
  self.0
}

///|
fn pattern_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_pattern_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
/// Create an opaque solid-color pattern.
///
/// `red`, `green`, and `blue` are clamped to `[0.0, 1.0]`. The returned value
/// owns its native pattern and raises the checked creation status, including
/// allocation failure.
pub fn Pattern::solid_rgb(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_rgb_raw(red, green, blue)
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Create a solid-color pattern with explicit alpha.
///
/// All four components are clamped to `[0.0, 1.0]`. The returned value owns
/// its native pattern and raises the checked creation status.
pub fn Pattern::solid_rgba(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_rgba_raw(red, green, blue, alpha)
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Create a pattern that samples `surface`.
///
/// The new pattern retains the source surface, including MoonBit-managed image
/// data backing it, so the pattern remains usable after `surface` leaves scope.
/// Raises either the source or newly created pattern status.
pub fn Pattern::for_surface(surface : Surface) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_for_surface_raw(surface.to_raw())
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Return the surface sampled by a surface pattern.
///
/// The result owns an independent Cairo surface reference and remains valid
/// after this pattern leaves scope. Raises `PatternTypeMismatch` for any other
/// pattern subtype and propagates an existing sticky pattern or surface error.
pub fn Pattern::get_surface(self : Pattern) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @pattern_impl.get_surface_raw(self.to_raw(), status)
  check_pattern_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
/// Return this pattern's sticky Cairo status without raising.
///
/// Once Cairo records an error, later checked operations keep reporting it.
/// An unrecognized native status is conservatively returned as `InvalidStatus`.
pub fn Pattern::status(self : Pattern) -> Status {
  pattern_status_from_raw(@pattern_impl.status_raw(self.to_raw()))
}

///|
/// Test whether two wrappers refer to the same native Cairo pattern.
///
/// This is pointer identity; independently created patterns with equal colors
/// or geometry compare unequal.
pub fn Pattern::equal(self : Pattern, other : Pattern) -> Bool {
  @pattern_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return a stable hash of this native pattern's pointer identity.
///
/// It is consistent with `equal()` for the lifetime of the pattern and does
/// not describe its mutable drawing state.
pub fn Pattern::hash(self : Pattern) -> UInt64 {
  @pattern_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for Pattern with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Pattern with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Pattern with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
fn extend_from_raw(raw : Int) -> Extend raise CairoError {
  match raw {
    0 => ExtendNone
    1 => Repeat
    2 => Reflect
    3 => Pad
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo extend: \{raw}")
  }
}

///|
fn extend_to_raw(extend_mode : Extend) -> Int {
  match extend_mode {
    ExtendNone => 0
    Repeat => 1
    Reflect => 2
    Pad => 3
  }
}

///|
fn filter_from_raw(raw : Int) -> Filter raise CairoError {
  match raw {
    0 => Fast
    1 => Good
    2 => Best
    3 => Nearest
    4 => Bilinear
    5 => Gaussian
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo filter: \{raw}")
  }
}

///|
fn filter_to_raw(filter : Filter) -> Int {
  match filter {
    Fast => 0
    Good => 1
    Best => 2
    Nearest => 3
    Bilinear => 4
    Gaussian => 5
  }
}

///|
fn dither_from_raw(raw : Int) -> Dither raise CairoError {
  match raw {
    0 => DitherNone
    1 => DitherDefault
    2 => DitherFast
    3 => DitherGood
    4 => DitherBest
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo dither: \{raw}")
  }
}

///|
fn dither_to_raw(dither : Dither) -> Int {
  match dither {
    DitherNone => 0
    DitherDefault => 1
    DitherFast => 2
    DitherGood => 3
    DitherBest => 4
  }
}

///|
/// Return how sampling behaves outside this pattern's intrinsic bounds.
///
/// Surface patterns default to `ExtendNone`; gradient patterns default to
/// `Pad`. Raises a sticky pattern error or `InvalidStatus` if a prior raw setter
/// stored a value unknown to the typed `Extend` enum.
pub fn Pattern::get_extend(self : Pattern) -> Extend raise CairoError {
  extend_from_raw(self.get_extend_raw())
}

///|
/// Set how sampling behaves outside this pattern's intrinsic bounds.
///
/// The mode affects later uses of this mutable pattern. Raises the checked
/// sticky pattern status.
pub fn Pattern::set_extend(
  self : Pattern,
  extend_mode : Extend,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_extend_raw(self.to_raw(), extend_to_raw(extend_mode)),
  )
}

///|
/// Return Cairo's integer extend value without typed-enum conversion.
///
/// Known values are `0` through `3`; an arbitrary value previously supplied to
/// `set_extend_raw()` is returned unchanged. Raises an existing pattern error.
pub fn Pattern::get_extend_raw(self : Pattern) -> Int raise CairoError {
  check_pattern_status_raw(@pattern_impl.status_raw(self.to_raw()))
  @pattern_impl.get_extend_raw(self.to_raw())
}

///|
/// Pass an integer extend value directly to Cairo for pycairo compatibility.
///
/// The value is intentionally not range-checked. Unknown values can be read by
/// `get_extend_raw()`, while `get_extend()` raises `InvalidStatus` for them.
/// Raises the checked sticky pattern status.
pub fn Pattern::set_extend_raw(
  self : Pattern,
  extend_mode : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_extend_raw(self.to_raw(), extend_mode),
  )
}

///|
/// Return the sampling filter hint used when this pattern is rescaled.
///
/// New patterns normally use `Good`. Raises a sticky pattern error or
/// `InvalidStatus` when a prior raw setter stored an unknown integer.
pub fn Pattern::get_filter(self : Pattern) -> Filter raise CairoError {
  filter_from_raw(self.get_filter_raw())
}

///|
/// Set the quality/performance hint used to filter this pattern.
///
/// Cairo backends may choose an implementation compatible with the hint.
/// Raises the checked sticky pattern status.
pub fn Pattern::set_filter(
  self : Pattern,
  filter : Filter,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_filter_raw(self.to_raw(), filter_to_raw(filter)),
  )
}

///|
/// Return Cairo's integer filter hint without typed-enum conversion.
///
/// Known values are `0` through `5`; arbitrary values set through the raw API
/// are preserved. Raises an existing sticky pattern error.
pub fn Pattern::get_filter_raw(self : Pattern) -> Int raise CairoError {
  check_pattern_status_raw(@pattern_impl.status_raw(self.to_raw()))
  @pattern_impl.get_filter_raw(self.to_raw())
}

///|
/// Pass an integer filter hint directly to Cairo for pycairo compatibility.
///
/// The value is intentionally not range-checked. The typed getter later raises
/// `InvalidStatus` if Cairo returns a value outside the `Filter` enum.
pub fn Pattern::set_filter_raw(
  self : Pattern,
  filter : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.set_filter_raw(self.to_raw(), filter))
}

///|
/// Return this pattern's dithering hint.
///
/// Dithering is available with Cairo 1.18 or newer and is currently honored by
/// pixman-backed rendering. Older runtimes raise `InvalidStatus`; an unknown
/// raw value also raises `InvalidStatus` during typed conversion.
pub fn Pattern::get_dither(self : Pattern) -> Dither raise CairoError {
  dither_from_raw(self.get_dither_raw())
}

///|
/// Set this pattern's dithering hint for later rendering.
///
/// Requires Cairo 1.18 or newer; older runtimes raise `InvalidStatus`. The hint
/// does not guarantee that every backend performs dithering.
pub fn Pattern::set_dither(
  self : Pattern,
  dither : Dither,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_dither_raw(self.to_raw(), dither_to_raw(dither)),
  )
}

///|
/// Return Cairo's raw integer dithering hint.
///
/// Requires Cairo 1.18 or newer and otherwise raises `InvalidStatus`. Values
/// outside the typed enum are returned unchanged.
pub fn Pattern::get_dither_raw(self : Pattern) -> Int raise CairoError {
  let status = Ref(0)
  let dither = @pattern_impl.get_dither_raw(self.to_raw(), status)
  check_pattern_status_raw(status.val)
  dither
}

///|
/// Pass a dithering integer directly to Cairo for pycairo compatibility.
///
/// No enum range check is performed. Requires Cairo 1.18 or newer; older
/// runtimes raise `InvalidStatus`, and the typed getter rejects unknown values.
pub fn Pattern::set_dither_raw(
  self : Pattern,
  dither : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.set_dither_raw(self.to_raw(), dither))
}

///|
/// Return the affine transform from user space to pattern space.
///
/// New patterns start with identity. Because this direction is the inverse of
/// the apparent pattern-to-user transform, scaling the matrix down makes the
/// rendered pattern appear larger. Raises an existing sticky pattern error.
pub fn Pattern::get_matrix(self : Pattern) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0),
  )
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
/// Set the affine transform from user space to pattern space.
///
/// `matrix` is copied; later changes to the value do not affect the pattern.
/// A non-invertible matrix raises `CairoInvalidArgument(InvalidMatrix, _)` and
/// leaves that error sticky on the pattern.
pub fn Pattern::set_matrix(
  self : Pattern,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_matrix_raw(
      self.to_raw(),
      matrix.xx,
      matrix.yx,
      matrix.xy,
      matrix.yy,
      matrix.x0,
      matrix.y0,
    ),
  )
}

///|
/// Return a solid pattern's unpremultiplied RGBA components.
///
/// Components are in `[0.0, 1.0]`; an RGB pattern reports alpha `1.0`. Raises
/// `PatternTypeMismatch` for surface, gradient, mesh, or raster-source patterns
/// and propagates any existing sticky pattern error.
pub fn Pattern::get_rgba(
  self : Pattern,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_rgba_raw(self.to_raw(), red, green, blue, alpha),
  )
  (red.val, green.val, blue.val, alpha.val)
}
