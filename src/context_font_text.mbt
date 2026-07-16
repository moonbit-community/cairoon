///|
/// Return a fresh copy of the context's explicitly configured font options.
///
/// The snapshot contains values supplied through `set_font_options()` but not
/// options later derived from the target surface. Mutating the returned
/// `FontOptions` does not change this context. Raises the checked context or
/// allocation status.
pub fn Context::get_font_options(
  self : Context,
) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_font_options_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  FontOptions::from_raw(raw)
}

///|
/// Set the custom font rendering options used by this context.
///
/// Cairo copies the values at this call. Later mutations of `options` do not
/// affect the context. Default-valued fields are merged with target-surface
/// options when a scaled font is realized. Raises a checked status from either
/// object.
pub fn Context::set_font_options(
  self : Context,
  options : FontOptions,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_font_options_raw(self.to_raw(), options.to_raw()),
  )
}

///|
/// Return an owning wrapper for the context's current font face.
///
/// Cairo owns the borrowed result internally; cairoon acquires a reference so
/// the returned `FontFace` remains valid after this context leaves scope.
/// Raises the checked context or font-face status.
pub fn Context::get_font_face(self : Context) -> FontFace raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_font_face_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  FontFace::from_raw(raw)
}

///|
/// Replace the current font face, or restore Cairo's default with `None`.
///
/// For `Some(face)`, the context retains its own Cairo reference and the caller
/// may release its wrapper independently. Installing a face invalidates the
/// previously realized scaled-font state. Raises a checked status from either
/// object.
pub fn Context::set_font_face(
  self : Context,
  font_face : FontFace?,
) -> Unit raise CairoError {
  match font_face {
    None =>
      check_context_status_raw(
        @context_impl.set_font_face_default_raw(self.to_raw()),
      )
    Some(face) =>
      check_context_status_raw(
        @context_impl.set_font_face_raw(self.to_raw(), face.to_raw()),
      )
  }
}

///|
/// Select a font through Cairo's simplified toy-text API.
///
/// `slant` and `weight` default to their normal typed variants. This is useful
/// for simple text but does not perform application-grade font discovery or
/// shaping. `family` is encoded as UTF-8; an embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. Other failures raise the checked
/// context status.
pub fn Context::select_font_face(
  self : Context,
  family : String,
  slant? : FontSlant = FontSlantNormal,
  weight? : FontWeight = FontWeightNormal,
) -> Unit raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  check_context_status_raw(
    @context_impl.select_font_face_raw(
      self.to_raw(),
      bytes,
      font_slant_to_raw(slant),
      font_weight_to_raw(weight),
    ),
  )
}

///|
/// Select a toy font using pycairo-compatible raw C enum integers.
///
/// Prefer `select_font_face()` for typed code. Known values match `FontSlant`
/// and `FontWeight`; Cairo maps unsupported values to `InvalidSlant` or
/// `InvalidWeight`. The UTF-8 family name rejects embedded NUL bytes before the
/// FFI call. Raises the checked context status.
pub fn Context::select_font_face_raw(
  self : Context,
  family : String,
  slant? : Int = 0,
  weight? : Int = 0,
) -> Unit raise CairoError {
  let bytes = @utf8.encode(family)
  check_no_embedded_nul(bytes)
  check_context_status_raw(
    @context_impl.select_font_face_raw(self.to_raw(), bytes, slant, weight),
  )
}

///|
/// Replace the design-space-to-user-space transformation for the current font.
///
/// The matrix is copied. It may express scaling, shear, rotation, translation,
/// or non-uniform stretching; `set_font_size()` is the simple uniform-scale
/// form. Raises the checked context status.
pub fn Context::set_font_matrix(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_font_matrix_raw(
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
/// Return a pure snapshot of the current font matrix.
///
/// The matrix maps the font's unit em square from design space into user space.
/// Later context changes do not modify the returned value. Raises the checked
/// context status.
pub fn Context::get_font_matrix(self : Context) -> Matrix raise CairoError {
  matrix_from_context_output((xx, yx, xy, yy, x0, y0) => {
    @context_impl.get_font_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
/// Set a uniform font size in user-space units.
///
/// This replaces the current font matrix with an X/Y scale by `size`; it does
/// not compose with a matrix installed earlier. Use `set_font_matrix()` for
/// non-uniform or sheared text. Raises the checked context status.
pub fn Context::set_font_size(
  self : Context,
  size : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_font_size_raw(self.to_raw(), size))
}

///|
/// Return metrics for the context's current realized font.
///
/// The result reports ascent, descent, line height, and maximum X/Y advances in
/// user-space units. It matches `get_scaled_font().extents()` for the same
/// graphics state and does not mutate the current point. Raises the checked
/// context status.
pub fn Context::font_extents(self : Context) -> FontExtents raise CairoError {
  font_extents_from_output((
    ascent,
    descent,
    height,
    max_x_advance,
    max_y_advance,
  ) => {
    context_status_from_raw(
      @context_impl.font_extents_raw(
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
/// Draw UTF-8 text with Cairo's toy-text shaping and advance the current point.
///
/// The first glyph starts at the current point; afterward that point moves to
/// where the next glyph would begin. The current path is otherwise unchanged.
/// Embedded NUL bytes raise `CairoInvalidArgument(InvalidString, _)` before the
/// FFI call. Raises other checked drawing statuses normally.
pub fn Context::show_text(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.show_text_raw(self.to_raw(), checked_c_string_bytes(text)),
  )
}

///|
/// Measure UTF-8 text using the current font state.
///
/// The returned `TextExtents` bounds the ink in user space and separately
/// reports the advance that `show_text()` would apply. Whitespace can affect
/// advances without contributing ink. This query does not move the current
/// point. Embedded NUL bytes raise `CairoInvalidArgument(InvalidString, _)`.
pub fn Context::text_extents(
  self : Context,
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
    context_status_from_raw(
      @context_impl.text_extents_raw(
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
/// Append closed outlines for UTF-8 toy-text glyphs to the current path.
///
/// Filling the resulting path approximates `show_text()` while allowing normal
/// path transforms and paint operations. The current point advances as it does
/// for `show_text()`. Embedded NUL bytes raise
/// `CairoInvalidArgument(InvalidString, _)`; other failures use the checked
/// context status.
pub fn Context::text_path(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.text_path_raw(self.to_raw(), checked_c_string_bytes(text)),
  )
}

///|
/// Measure explicitly positioned glyphs with the current font state.
///
/// The result bounds the ink in user space and reports glyph-run advances;
/// whitespace glyphs may advance without adding ink. An empty view returns
/// zero extents. cairoon copies the fields into temporary C storage for the
/// call and retains no array data. Raises the checked context status.
pub fn Context::glyph_extents(
  self : Context,
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
    context_status_from_raw(
      @context_impl.glyph_extents_raw(
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
/// Append closed outlines for explicitly positioned `glyphs` to the path.
///
/// Filling the outlines produces an effect similar to `show_glyphs()`. An
/// empty view is a no-op. Glyph fields are copied into temporary C storage and
/// are not retained after the call. Raises the checked context status.
pub fn Context::glyph_path(
  self : Context,
  glyphs : ArrayView[Glyph],
) -> Unit raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  check_context_status_raw(
    @context_impl.glyph_path_raw(self.to_raw(), indices, xs, ys),
  )
}

///|
/// Draw explicitly positioned glyphs using the current font and paint state.
///
/// Unlike the toy `show_text()` API, each `Glyph` supplies its own glyph index
/// and user-space position. The current path and current point are unaffected;
/// an empty view is accepted. Input fields are copied for the call and not
/// retained. Raises the checked context status.
pub fn Context::show_glyphs(
  self : Context,
  glyphs : ArrayView[Glyph],
) -> Unit raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  check_context_status_raw(
    @context_impl.show_glyphs_raw(self.to_raw(), indices, xs, ys),
  )
}

///|
/// Draw glyphs while associating them with their original UTF-8 text.
///
/// Rendering matches `show_glyphs()`. Targets with text-glyph support can also
/// embed selectable/searchable text using `clusters`; otherwise Cairo ignores
/// the metadata. Clusters must collectively cover every UTF-8 byte and glyph,
/// with `TextClusterBackward` mapping glyphs from end to start. Invalid coverage
/// raises `CairoError(InvalidClusters, _)`, and embedded NUL bytes raise
/// `CairoInvalidArgument(InvalidString, _)`. Input arrays are not retained.
pub fn Context::show_text_glyphs(
  self : Context,
  text : String,
  glyphs : ArrayView[Glyph],
  clusters : ArrayView[TextCluster],
  flags? : TextClusterFlags = TextClusterNone,
) -> Unit raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  let (cluster_num_bytes, cluster_num_glyphs) = text_cluster_field_arrays(
    clusters,
  )
  check_context_status_raw(
    @context_impl.show_text_glyphs_raw(
      self.to_raw(),
      checked_c_string_bytes(text),
      indices,
      xs,
      ys,
      cluster_num_bytes,
      cluster_num_glyphs,
      text_cluster_flags_to_raw(flags),
    ),
  )
}

///|
fn text_cluster_flags_to_raw(flags : TextClusterFlags) -> Int {
  match flags {
    TextClusterNone => 0
    TextClusterBackward => 1
  }
}

///|
/// Return an owning wrapper for the context's current realized scaled font.
///
/// The result captures the active font face, font matrix, CTM, and font options
/// used for rendering. cairoon acquires a Cairo reference so it remains valid
/// after the context leaves scope. Raises the checked context or scaled-font
/// status.
pub fn Context::get_scaled_font(self : Context) -> ScaledFont raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_scaled_font_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  ScaledFont::from_raw(raw)
}

///|
/// Install `scaled_font` as the complete current font state.
///
/// This replaces the context's font face, font matrix, and font options, and the
/// context retains its own Cairo reference. Except for translation, the
/// context CTM should match `scaled_font.get_ctm()` for consistent rendering.
/// Raises a checked status from either object.
pub fn Context::set_scaled_font(
  self : Context,
  scaled_font : ScaledFont,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_scaled_font_raw(self.to_raw(), scaled_font.to_raw()),
  )
}

///|
