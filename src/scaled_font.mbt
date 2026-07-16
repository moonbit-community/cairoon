///|
/// An owning handle to a Cairo font fixed to a face, size, CTM, and options.
///
/// The internal `RawScaledFont` owns exactly one `cairo_scaled_font_t`
/// reference and destroys it through its external-object finalizer. Cairo
/// retains or copies the native face and options state it needs, so this value
/// remains usable after the constructor arguments leave MoonBit scope.
struct ScaledFont(@scaled_font_impl.RawScaledFont)

///|
fn ScaledFont::from_raw(raw : @scaled_font_impl.RawScaledFont) -> ScaledFont {
  ScaledFont(raw)
}

///|
fn ScaledFont::to_raw(self : ScaledFont) -> @scaled_font_impl.RawScaledFont {
  self.0
}

///|
fn scaled_font_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_scaled_font_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn text_cluster_flags_from_raw(raw : Int) -> TextClusterFlags raise CairoError {
  match raw {
    0 => TextClusterNone
    1 => TextClusterBackward
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo text cluster flags: \{raw}",
      )
  }
}

///|
/// Create a scaled font from a face and font-to-user/user-to-device matrices.
///
/// `font_matrix` controls font size, shear, and stretch. `ctm` describes the
/// device transform; Cairo ignores its translation components. Degenerate
/// matrices are valid, including a zero-size font, but non-finite determinants
/// raise `CairoInvalidArgument(InvalidMatrix, _)`. Face, option, allocation,
/// and backend failures are raised through `CairoError`.
pub fn ScaledFont::new(
  font_face : FontFace,
  font_matrix : Matrix,
  ctm : Matrix,
  options : FontOptions,
) -> ScaledFont raise CairoError {
  check_status(font_face.status())
  check_status(options.status())
  let raw = @scaled_font_impl.create_raw(
    font_face.to_raw(),
    font_matrix.xx,
    font_matrix.yx,
    font_matrix.xy,
    font_matrix.yy,
    font_matrix.x0,
    font_matrix.y0,
    ctm.xx,
    ctm.yx,
    ctm.xy,
    ctm.yy,
    ctm.x0,
    ctm.y0,
    options.to_raw(),
  )
  check_scaled_font_status_raw(@scaled_font_impl.status_raw(raw))
  ScaledFont::from_raw(raw)
}

///|
/// Return the current Cairo status without raising.
///
/// Safe methods check and raise this status themselves. This diagnostic is
/// primarily useful when inspecting identity or values obtained through lower
/// level integration code.
pub fn ScaledFont::status(self : ScaledFont) -> Status {
  scaled_font_status_from_raw(@scaled_font_impl.status_raw(self.to_raw()))
}

///|
/// Return whether two wrappers reference the same native scaled font.
///
/// Equality is pointer identity, not equality of face, matrices, options, or
/// metrics. Separately created fonts may be internally cached by Cairo and can
/// therefore share identity when all native creation parameters match.
pub fn ScaledFont::equal(self : ScaledFont, other : ScaledFont) -> Bool {
  @scaled_font_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return a process-local hash of the native scaled-font pointer.
///
/// Equal live scaled fonts have equal hashes. The value is suitable for
/// identity collections in the current process but is not stable across runs.
pub fn ScaledFont::hash(self : ScaledFont) -> UInt64 {
  @scaled_font_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for ScaledFont with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for ScaledFont with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for ScaledFont with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
/// Return an independently owned wrapper for this scaled font's face.
///
/// Cairo returns a borrowed face, so cairoon adds a native reference before
/// wrapping it. The result remains valid after `self` leaves scope. Some font
/// backends may return the face actually used rather than the original input;
/// face and scaled-font failures raise checked `CairoError` values.
pub fn ScaledFont::get_font_face(
  self : ScaledFont,
) -> FontFace raise CairoError {
  let status = Ref(0)
  let raw = @scaled_font_impl.get_font_face_raw(self.to_raw(), status)
  check_scaled_font_status_raw(status.val)
  FontFace::from_raw(raw)
}

///|
/// Return an independent copy of this scaled font's rendering options.
///
/// Mutating the returned `FontOptions` does not alter `self`. Allocation and
/// scaled-font or options failures raise the corresponding `CairoError`.
pub fn ScaledFont::get_font_options(
  self : ScaledFont,
) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @scaled_font_impl.get_font_options_raw(self.to_raw(), status)
  check_scaled_font_status_raw(status.val)
  FontOptions::from_raw(raw)
}

///|
fn matrix_from_scaled_font_output(
  f : (
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
  ) -> Int,
) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_scaled_font_status_raw(f(xx, yx, xy, yy, x0, y0))
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
/// Return the font-space to user-space matrix used to create this font.
///
/// The matrix includes font sizing, shear, stretch, and any font-matrix
/// translation exactly as stored by Cairo. Failed scaled fonts raise their
/// checked `CairoError` status.
pub fn ScaledFont::get_font_matrix(
  self : ScaledFont,
) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    @scaled_font_impl.get_font_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
/// Return the user-space to device-space CTM used to create this font.
///
/// Cairo ignores CTM translation for scaled fonts, so `x0` and `y0` are always
/// zero in the returned matrix. Failed scaled fonts raise checked
/// `CairoError` values.
pub fn ScaledFont::get_ctm(self : ScaledFont) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    @scaled_font_impl.get_ctm_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
/// Return the matrix mapping font space directly to device space.
///
/// Cairo defines this as the product of the stored font matrix and CTM, with
/// CTM translation omitted. Failed scaled fonts raise checked `CairoError`
/// values.
pub fn ScaledFont::get_scale_matrix(
  self : ScaledFont,
) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    @scaled_font_impl.get_scale_matrix_raw(
      self.to_raw(),
      xx,
      yx,
      xy,
      yy,
      x0,
      y0,
    )
  })
}

///|
fn font_extents_from_output(
  f : (Ref[Double], Ref[Double], Ref[Double], Ref[Double], Ref[Double]) -> Status,
) -> FontExtents raise CairoError {
  let ascent = Ref(0.0)
  let descent = Ref(0.0)
  let height = Ref(0.0)
  let max_x_advance = Ref(0.0)
  let max_y_advance = Ref(0.0)
  check_status(f(ascent, descent, height, max_x_advance, max_y_advance))
  FontExtents::new(
    ascent.val,
    descent.val,
    height.val,
    max_x_advance.val,
    max_y_advance.val,
  )
}

///|
fn text_extents_from_output(
  f : (
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
  ) -> Status,
) -> TextExtents raise CairoError {
  let x_bearing = Ref(0.0)
  let y_bearing = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  let x_advance = Ref(0.0)
  let y_advance = Ref(0.0)
  check_status(f(x_bearing, y_bearing, width, height, x_advance, y_advance))
  TextExtents::new(
    x_bearing.val,
    y_bearing.val,
    width.val,
    height.val,
    x_advance.val,
    y_advance.val,
  )
}

///|
/// Return this font's aggregate metrics in user-space units.
///
/// The result contains ascent, descent, recommended line height, and maximum
/// X/Y advances. Backend or scaled-font failures raise checked `CairoError`
/// values.
pub fn ScaledFont::extents(self : ScaledFont) -> FontExtents raise CairoError {
  font_extents_from_output((
    ascent,
    descent,
    height,
    max_x_advance,
    max_y_advance,
  ) => {
    scaled_font_status_from_raw(
      @scaled_font_impl.extents_raw(
        self.to_raw(),
        ascent,
        descent,
        height,
        max_x_advance,
        max_y_advance,
      ),
    )
  })
}

///|
/// Measure UTF-8 text as drawn at user-space origin `(0, 0)`.
///
/// Ink bounds exclude whitespace itself, while advances still account for it.
/// The input is encoded to UTF-8 and an embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. Conversion, backend, and sticky
/// scaled-font failures are raised through `CairoError`.
pub fn ScaledFont::text_extents(
  self : ScaledFont,
  text : String,
) -> TextExtents raise CairoError {
  let bytes = checked_c_string_bytes(text)
  text_extents_from_output((
    x_bearing,
    y_bearing,
    width,
    height,
    x_advance,
    y_advance,
  ) => {
    scaled_font_status_from_raw(
      @scaled_font_impl.text_extents_raw(
        self.to_raw(),
        bytes,
        x_bearing,
        y_bearing,
        width,
        height,
        x_advance,
        y_advance,
      ),
    )
  })
}

///|
/// Measure positioned glyphs in user-space coordinates.
///
/// Glyph indexes and positions are copied into a temporary native array for
/// this call and are never retained. Empty input returns zero extents.
/// `UInt64` indexes that do not fit Cairo's native `unsigned long` raise
/// `CairoInvalidArgument(InvalidIndex, _)`; other backend failures use
/// `CairoError`.
pub fn ScaledFont::glyph_extents(
  self : ScaledFont,
  glyphs : ArrayView[Glyph],
) -> TextExtents raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  text_extents_from_output((
    x_bearing,
    y_bearing,
    width,
    height,
    x_advance,
    y_advance,
  ) => {
    scaled_font_status_from_raw(
      @scaled_font_impl.glyph_extents_raw(
        self.to_raw(),
        indices,
        xs,
        ys,
        x_bearing,
        y_bearing,
        width,
        height,
        x_advance,
        y_advance,
      ),
    )
  })
}

///|
fn glyphs_from_native(
  result : @scaled_font_impl.RawTextToGlyphs,
) -> Array[Glyph] raise CairoError {
  check_scaled_font_status_raw(
    @scaled_font_impl.text_to_glyphs_status_raw(result),
  )
  let indices = @scaled_font_impl.text_to_glyphs_indices_raw(result)
  let positions = @scaled_font_impl.text_to_glyphs_positions_raw(result)
  if positions.length() != indices.length() * 2 {
    raise CairoInvalidArgument(InvalidSize, InvalidSize.message())
  }
  Array::makei(indices.length(), index => {
    let offset = index * 2
    Glyph::new(indices[index], positions[offset], positions[offset + 1])
  })
}

///|
fn text_glyph_run_from_native(
  result : @scaled_font_impl.RawTextToGlyphs,
) -> TextGlyphRun raise CairoError {
  let glyphs = glyphs_from_native(result)
  let cluster_values = @scaled_font_impl.text_to_glyphs_clusters_raw(result)
  if cluster_values.length() % 2 != 0 {
    raise CairoInvalidArgument(InvalidSize, InvalidSize.message())
  }
  let clusters = Array::makei(cluster_values.length() / 2, index => {
    let offset = index * 2
    TextCluster::new(cluster_values[offset], cluster_values[offset + 1])
  })
  TextGlyphRun::new(
    glyphs,
    clusters,
    text_cluster_flags_from_raw(
      @scaled_font_impl.text_to_glyphs_flags_raw(result),
    ),
  )
}

///|
fn[T] with_released_text_to_glyphs_result(
  result : @scaled_font_impl.RawTextToGlyphs,
  decode : (@scaled_font_impl.RawTextToGlyphs) -> T raise CairoError,
) -> T raise CairoError {
  try decode(result) catch {
    err => {
      @scaled_font_impl.text_to_glyphs_release_raw(result)
      raise err
    }
  } noraise {
    value => {
      @scaled_font_impl.text_to_glyphs_release_raw(result)
      value
    }
  }
}

///|
/// Convert UTF-8 text to copied glyphs plus byte-to-glyph cluster mapping.
///
/// `x` and `y` position the first glyph in user space. Returned arrays are pure
/// MoonBit values and remain valid after Cairo's temporary native arrays are
/// released. Cluster byte counts refer to UTF-8 bytes, not Unicode scalars.
/// The result must be rendered with the same scaled font for matching
/// placement. Embedded NUL raises `CairoInvalidArgument(InvalidString, _)`;
/// conversion, allocation, and backend failures raise checked `CairoError`
/// values.
pub fn ScaledFont::text_to_glyphs(
  self : ScaledFont,
  x : Double,
  y : Double,
  text : String,
) -> TextGlyphRun raise CairoError {
  with_released_text_to_glyphs_result(
    @scaled_font_impl.text_to_glyphs_raw(
      self.to_raw(),
      x,
      y,
      checked_c_string_bytes(text),
      true,
    ),
    text_glyph_run_from_native,
  )
}

///|
/// Convert UTF-8 text to copied glyphs without computing cluster mapping.
///
/// This is the statically typed counterpart of pycairo's
/// `with_clusters=False`: cairoon passes null cluster outputs to Cairo instead
/// of allocating and discarding them. Coordinates, ownership, NUL validation,
/// and checked errors match `text_to_glyphs()`.
pub fn ScaledFont::text_to_glyphs_only(
  self : ScaledFont,
  x : Double,
  y : Double,
  text : String,
) -> Array[Glyph] raise CairoError {
  with_released_text_to_glyphs_result(
    @scaled_font_impl.text_to_glyphs_raw(
      self.to_raw(),
      x,
      y,
      checked_c_string_bytes(text),
      false,
    ),
    glyphs_from_native,
  )
}
