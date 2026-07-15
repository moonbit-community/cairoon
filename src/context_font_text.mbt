///|
pub fn Context::get_font_options(
  self : Context,
) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_font_options_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  FontOptions::from_raw(raw)
}

///|
pub fn Context::set_font_options(
  self : Context,
  options : FontOptions,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_font_options_raw(self.to_raw(), options.to_raw()),
  )
}

///|
pub fn Context::get_font_face(self : Context) -> FontFace raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_font_face_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  FontFace::from_raw(raw)
}

///|
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
pub fn Context::get_font_matrix(self : Context) -> Matrix raise CairoError {
  matrix_from_context_output((xx, yx, xy, yy, x0, y0) => {
    @context_impl.get_font_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
pub fn Context::set_font_size(
  self : Context,
  size : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_font_size_raw(self.to_raw(), size))
}

///|
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
pub fn Context::show_text(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.show_text_raw(self.to_raw(), checked_c_string_bytes(text)),
  )
}

///|
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
pub fn Context::text_path(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.text_path_raw(self.to_raw(), checked_c_string_bytes(text)),
  )
}

///|
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
pub fn Context::get_scaled_font(self : Context) -> ScaledFont raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_scaled_font_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  ScaledFont::from_raw(raw)
}

///|
pub fn Context::set_scaled_font(
  self : Context,
  scaled_font : ScaledFont,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_scaled_font_raw(self.to_raw(), scaled_font.to_raw()),
  )
}

///|
