///|
pub fn Context::get_font_options(
  self : Context,
) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let raw = context_get_font_options_ffi(self, status)
  check_status(status.val)
  FontOptions::from_raw(raw)
}

///|
pub fn Context::set_font_options(
  self : Context,
  options : FontOptions,
) -> Unit raise CairoError {
  check_status(context_set_font_options_ffi(self, options.to_raw()))
}

///|
pub fn Context::get_font_face(self : Context) -> FontFace raise CairoError {
  let status = Ref(Success)
  let font_face = context_get_font_face_ffi(self, status)
  check_status(status.val)
  font_face
}

///|
pub fn Context::set_font_face(
  self : Context,
  font_face : FontFace?,
) -> Unit raise CairoError {
  match font_face {
    None => check_status(context_set_font_face_default_ffi(self))
    Some(face) => check_status(context_set_font_face_ffi(self, face))
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
  check_status(context_select_font_face_ffi(self, bytes, slant, weight))
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
  check_status(context_select_font_face_raw_ffi(self, bytes, slant, weight))
}

///|
pub fn Context::set_font_matrix(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_status(
    context_set_font_matrix_ffi(
      self,
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
    context_get_font_matrix_ffi(self, xx, yx, xy, yy, x0, y0)
  })
}

///|
pub fn Context::set_font_size(
  self : Context,
  size : Double,
) -> Unit raise CairoError {
  check_status(context_set_font_size_ffi(self, size))
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
    context_font_extents_ffi(
      self, ascent, descent, height, max_x_advance, max_y_advance,
    )
  })
}

///|
pub fn Context::show_text(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_status(context_show_text_ffi(self, checked_c_string_bytes(text)))
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
    context_text_extents_ffi(
      self, bytes, x_bearing, y_bearing, width, height, x_advance, y_advance,
    )
  })
}

///|
pub fn Context::text_path(
  self : Context,
  text : String,
) -> Unit raise CairoError {
  check_status(context_text_path_ffi(self, checked_c_string_bytes(text)))
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
    context_glyph_extents_ffi(
      self, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance,
    )
  })
}

///|
pub fn Context::glyph_path(
  self : Context,
  glyphs : ArrayView[Glyph],
) -> Unit raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  check_status(context_glyph_path_ffi(self, indices, xs, ys))
}

///|
pub fn Context::show_glyphs(
  self : Context,
  glyphs : ArrayView[Glyph],
) -> Unit raise CairoError {
  let (indices, xs, ys) = @glyph.field_arrays(glyphs)
  check_status(context_show_glyphs_ffi(self, indices, xs, ys))
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
  check_status(
    context_show_text_glyphs_ffi(
      self,
      checked_c_string_bytes(text),
      indices,
      xs,
      ys,
      cluster_num_bytes,
      cluster_num_glyphs,
      flags,
    ),
  )
}

///|
pub fn Context::get_scaled_font(self : Context) -> ScaledFont raise CairoError {
  let status = Ref(Success)
  let scaled_font = context_get_scaled_font_ffi(self, status)
  check_status(status.val)
  scaled_font
}

///|
pub fn Context::set_scaled_font(
  self : Context,
  scaled_font : ScaledFont,
) -> Unit raise CairoError {
  check_status(context_set_scaled_font_ffi(self, scaled_font))
}

///|
