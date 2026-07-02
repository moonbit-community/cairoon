///|
pub fn ScaledFont::new(
  font_face : FontFace,
  font_matrix : Matrix,
  ctm : Matrix,
  options : FontOptions,
) -> ScaledFont raise CairoError {
  check_status(font_face.status())
  check_status(options.status())
  let scaled_font = scaled_font_create_ffi(
    font_face,
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
    options,
  )
  check_status(scaled_font_status_ffi(scaled_font))
  scaled_font
}

///|
pub fn ScaledFont::status(self : ScaledFont) -> Status {
  scaled_font_status_ffi(self)
}

///|
pub fn ScaledFont::equal(self : ScaledFont, other : ScaledFont) -> Bool {
  scaled_font_equal_ffi(self, other)
}

///|
pub fn ScaledFont::hash(self : ScaledFont) -> UInt64 {
  scaled_font_hash_ffi(self)
}

///|
pub fn ScaledFont::get_font_face(
  self : ScaledFont,
) -> FontFace raise CairoError {
  let status = Ref(Success)
  let font_face = scaled_font_get_font_face_ffi(self, status)
  check_status(status.val)
  font_face
}

///|
pub fn ScaledFont::get_font_options(
  self : ScaledFont,
) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let options = scaled_font_get_font_options_ffi(self, status)
  check_status(status.val)
  options
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
  ) -> Status,
) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_status(f(xx, yx, xy, yy, x0, y0))
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
pub fn ScaledFont::get_font_matrix(
  self : ScaledFont,
) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    scaled_font_get_font_matrix_ffi(self, xx, yx, xy, yy, x0, y0)
  })
}

///|
pub fn ScaledFont::get_ctm(self : ScaledFont) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    scaled_font_get_ctm_ffi(self, xx, yx, xy, yy, x0, y0)
  })
}

///|
pub fn ScaledFont::get_scale_matrix(
  self : ScaledFont,
) -> Matrix raise CairoError {
  matrix_from_scaled_font_output((xx, yx, xy, yy, x0, y0) => {
    scaled_font_get_scale_matrix_ffi(self, xx, yx, xy, yy, x0, y0)
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
pub fn ScaledFont::extents(self : ScaledFont) -> FontExtents raise CairoError {
  font_extents_from_output((
    ascent,
    descent,
    height,
    max_x_advance,
    max_y_advance,
  ) => {
    scaled_font_extents_ffi(
      self, ascent, descent, height, max_x_advance, max_y_advance,
    )
  })
}

///|
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
    scaled_font_text_extents_ffi(
      self, bytes, x_bearing, y_bearing, width, height, x_advance, y_advance,
    )
  })
}
