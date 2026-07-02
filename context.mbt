///|
pub fn Context::new(target : Surface) -> Context raise CairoError {
  let ctx = context_create_ffi(target)
  check_status(context_status_ffi(ctx))
  ctx
}

///|
pub fn Context::status(self : Context) -> Status {
  context_status_ffi(self)
}

///|
pub fn Context::save(self : Context) -> Unit raise CairoError {
  check_status(context_save_ffi(self))
}

///|
pub fn Context::restore(self : Context) -> Unit raise CairoError {
  check_status(context_restore_ffi(self))
}

///|
pub fn Context::get_target(self : Context) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = context_get_target_ffi(self, status)
  check_status(status.val)
  surface
}

///|
pub fn Context::get_source(self : Context) -> Pattern raise CairoError {
  let status = Ref(Success)
  let pattern = context_get_source_ffi(self, status)
  check_status(status.val)
  pattern
}

///|
pub fn Context::get_font_options(
  self : Context,
) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let options = context_get_font_options_ffi(self, status)
  check_status(status.val)
  options
}

///|
pub fn Context::set_font_options(
  self : Context,
  options : FontOptions,
) -> Unit raise CairoError {
  check_status(context_set_font_options_ffi(self, options))
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
pub fn Context::scale(
  self : Context,
  sx : Double,
  sy : Double,
) -> Unit raise CairoError {
  check_status(context_scale_ffi(self, sx, sy))
}

///|
pub fn Context::translate(
  self : Context,
  tx : Double,
  ty : Double,
) -> Unit raise CairoError {
  check_status(context_translate_ffi(self, tx, ty))
}

///|
pub fn Context::rotate(
  self : Context,
  radians : Double,
) -> Unit raise CairoError {
  check_status(context_rotate_ffi(self, radians))
}

///|
pub fn Context::transform(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_status(
    context_transform_ffi(
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
pub fn Context::set_matrix(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_status(
    context_set_matrix_ffi(
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
fn matrix_from_context_output(
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
pub fn Context::get_matrix(self : Context) -> Matrix raise CairoError {
  matrix_from_context_output((xx, yx, xy, yy, x0, y0) => {
    context_get_matrix_ffi(self, xx, yx, xy, yy, x0, y0)
  })
}

///|
pub fn Context::identity_matrix(self : Context) -> Unit raise CairoError {
  check_status(context_identity_matrix_ffi(self))
}

///|
fn point_from_context_output(
  f : (Ref[Double], Ref[Double]) -> Status,
) -> (Double, Double) raise CairoError {
  let x = Ref(0.0)
  let y = Ref(0.0)
  check_status(f(x, y))
  (x.val, y.val)
}

///|
pub fn Context::user_to_device(
  self : Context,
  x : Double,
  y : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_x, out_y) => {
    context_user_to_device_ffi(self, x, y, out_x, out_y)
  })
}

///|
pub fn Context::user_to_device_distance(
  self : Context,
  dx : Double,
  dy : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_dx, out_dy) => {
    context_user_to_device_distance_ffi(self, dx, dy, out_dx, out_dy)
  })
}

///|
pub fn Context::device_to_user(
  self : Context,
  x : Double,
  y : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_x, out_y) => {
    context_device_to_user_ffi(self, x, y, out_x, out_y)
  })
}

///|
pub fn Context::device_to_user_distance(
  self : Context,
  dx : Double,
  dy : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_dx, out_dy) => {
    context_device_to_user_distance_ffi(self, dx, dy, out_dx, out_dy)
  })
}

///|
pub fn Context::set_line_width(
  self : Context,
  width : Double,
) -> Unit raise CairoError {
  check_status(context_set_line_width_ffi(self, width))
}

///|
pub fn Context::get_line_width(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_width_ffi(self)
}

///|
pub fn Context::set_line_cap(
  self : Context,
  cap : LineCap,
) -> Unit raise CairoError {
  check_status(context_set_line_cap_ffi(self, cap))
}

///|
pub fn Context::get_line_cap(self : Context) -> LineCap raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_cap_ffi(self)
}

///|
pub fn Context::set_line_join(
  self : Context,
  join : LineJoin,
) -> Unit raise CairoError {
  check_status(context_set_line_join_ffi(self, join))
}

///|
pub fn Context::get_line_join(self : Context) -> LineJoin raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_join_ffi(self)
}

///|
pub fn Context::set_fill_rule(
  self : Context,
  fill_rule : FillRule,
) -> Unit raise CairoError {
  check_status(context_set_fill_rule_ffi(self, fill_rule))
}

///|
pub fn Context::get_fill_rule(self : Context) -> FillRule raise CairoError {
  check_status(context_status_ffi(self))
  context_get_fill_rule_ffi(self)
}

///|
pub fn Context::set_operator(
  self : Context,
  operator : Operator,
) -> Unit raise CairoError {
  check_status(context_set_operator_ffi(self, operator))
}

///|
pub fn Context::get_operator(self : Context) -> Operator raise CairoError {
  check_status(context_status_ffi(self))
  context_get_operator_ffi(self)
}

///|
pub fn Context::set_antialias(
  self : Context,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_status(context_set_antialias_ffi(self, antialias))
}

///|
pub fn Context::get_antialias(self : Context) -> Antialias raise CairoError {
  check_status(context_status_ffi(self))
  context_get_antialias_ffi(self)
}

///|
pub fn Context::set_tolerance(
  self : Context,
  tolerance : Double,
) -> Unit raise CairoError {
  check_status(context_set_tolerance_ffi(self, tolerance))
}

///|
pub fn Context::get_tolerance(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_tolerance_ffi(self)
}

///|
pub fn Context::set_miter_limit(
  self : Context,
  limit : Double,
) -> Unit raise CairoError {
  check_status(context_set_miter_limit_ffi(self, limit))
}

///|
pub fn Context::get_miter_limit(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_miter_limit_ffi(self)
}

///|
pub fn Context::set_dash(
  self : Context,
  dashes : ArrayView[Double],
  offset? : Double = 0.0,
) -> Unit raise CairoError {
  check_status(
    context_set_dash_ffi(self, FixedArray::from_array(dashes), offset),
  )
}

///|
pub fn Context::get_dash_count(self : Context) -> Int raise CairoError {
  check_status(context_status_ffi(self))
  context_get_dash_count_ffi(self)
}

///|
pub fn Context::get_dash(
  self : Context,
) -> (Array[Double], Double) raise CairoError {
  check_status(context_status_ffi(self))
  let offset = Ref(0.0)
  let dashes = context_get_dash_ffi(self, offset)
  check_status(context_status_ffi(self))
  (dashes.iter().collect(), offset.val)
}

///|
pub fn Context::move_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(context_move_to_ffi(self, x, y))
}

///|
pub fn Context::rel_move_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_status(context_rel_move_to_ffi(self, dx, dy))
}

///|
pub fn Context::line_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(context_line_to_ffi(self, x, y))
}

///|
pub fn Context::rel_line_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_status(context_rel_line_to_ffi(self, dx, dy))
}

///|
pub fn Context::curve_to(
  self : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Unit raise CairoError {
  check_status(context_curve_to_ffi(self, x1, y1, x2, y2, x3, y3))
}

///|
pub fn Context::rel_curve_to(
  self : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Unit raise CairoError {
  check_status(context_rel_curve_to_ffi(self, dx1, dy1, dx2, dy2, dx3, dy3))
}

///|
pub fn Context::rectangle(
  self : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit raise CairoError {
  check_status(context_rectangle_ffi(self, x, y, width, height))
}

///|
pub fn Context::arc(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_status(context_arc_ffi(self, xc, yc, radius, angle1, angle2))
}

///|
pub fn Context::arc_negative(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_status(context_arc_negative_ffi(self, xc, yc, radius, angle1, angle2))
}

///|
pub fn Context::close_path(self : Context) -> Unit raise CairoError {
  check_status(context_close_path_ffi(self))
}

///|
pub fn Context::new_path(self : Context) -> Unit raise CairoError {
  check_status(context_new_path_ffi(self))
}

///|
pub fn Context::new_sub_path(self : Context) -> Unit raise CairoError {
  check_status(context_new_sub_path_ffi(self))
}

///|
pub fn Context::get_current_point(
  self : Context,
) -> (Double, Double) raise CairoError {
  point_from_context_output((x, y) => context_get_current_point_ffi(self, x, y))
}

///|
pub fn Context::has_current_point(self : Context) -> Bool raise CairoError {
  let result = Ref(0)
  check_status(context_has_current_point_ffi(self, result))
  result.val != 0
}

///|
pub fn Context::copy_path(self : Context) -> Path raise CairoError {
  let status = Ref(Success)
  let path = context_copy_path_ffi(self, status)
  check_status(status.val)
  path
}

///|
pub fn Context::copy_path_flat(self : Context) -> Path raise CairoError {
  let status = Ref(Success)
  let path = context_copy_path_flat_ffi(self, status)
  check_status(status.val)
  path
}

///|
pub fn Context::append_path(
  self : Context,
  path : Path,
) -> Unit raise CairoError {
  check_status(context_append_path_ffi(self, path))
}

///|
pub fn Context::clip(self : Context) -> Unit raise CairoError {
  check_status(context_clip_ffi(self))
}

///|
pub fn Context::clip_preserve(self : Context) -> Unit raise CairoError {
  check_status(context_clip_preserve_ffi(self))
}

///|
pub fn Context::reset_clip(self : Context) -> Unit raise CairoError {
  check_status(context_reset_clip_ffi(self))
}

///|
pub fn Context::clip_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    context_clip_extents_ffi(self, x1, y1, x2, y2)
  })
}

///|
fn context_extents_from_output(
  f : (Ref[Double], Ref[Double], Ref[Double], Ref[Double]) -> Status,
) -> (Double, Double, Double, Double) raise CairoError {
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  let x2 = Ref(0.0)
  let y2 = Ref(0.0)
  check_status(f(x1, y1, x2, y2))
  (x1.val, y1.val, x2.val, y2.val)
}

///|
pub fn Context::in_clip(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => context_in_clip_ffi(self, x, y, result))
}

///|
pub fn Context::copy_clip_rectangle_list(
  self : Context,
) -> Array[Rectangle] raise CairoError {
  let status = Ref(Success)
  let values = context_copy_clip_rectangle_list_ffi(self, status)
  check_status(status.val)
  Array::makei(values.length() / 4, index => {
    let offset = index * 4
    Rectangle::new(
      values[offset],
      values[offset + 1],
      values[offset + 2],
      values[offset + 3],
    )
  })
}

///|
pub fn Context::fill_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    context_fill_extents_ffi(self, x1, y1, x2, y2)
  })
}

///|
pub fn Context::stroke_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    context_stroke_extents_ffi(self, x1, y1, x2, y2)
  })
}

///|
pub fn Context::path_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    context_path_extents_ffi(self, x1, y1, x2, y2)
  })
}

///|
fn context_hit_test_from_output(
  f : (Ref[Int]) -> Status,
) -> Bool raise CairoError {
  let result = Ref(0)
  check_status(f(result))
  result.val != 0
}

///|
pub fn Context::in_fill(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => context_in_fill_ffi(self, x, y, result))
}

///|
pub fn Context::in_stroke(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    context_in_stroke_ffi(self, x, y, result)
  })
}

///|
pub fn Context::set_source_rgb(
  self : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_status(context_set_source_rgb_ffi(self, red, green, blue))
}

///|
pub fn Context::set_source_rgba(
  self : Context,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_status(context_set_source_rgba_ffi(self, red, green, blue, alpha))
}

///|
pub fn Context::set_source(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_status(context_set_source_ffi(self, pattern))
}

///|
pub fn Context::paint(self : Context) -> Unit raise CairoError {
  check_status(context_paint_ffi(self))
}

///|
pub fn Context::paint_with_alpha(
  self : Context,
  alpha : Double,
) -> Unit raise CairoError {
  check_status(context_paint_with_alpha_ffi(self, alpha))
}

///|
pub fn Context::mask(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_status(context_mask_ffi(self, pattern))
}

///|
pub fn Context::mask_surface(
  self : Context,
  surface : Surface,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Unit raise CairoError {
  check_status(context_mask_surface_ffi(self, surface, x, y))
}

///|
pub fn Context::fill(self : Context) -> Unit raise CairoError {
  check_status(context_fill_ffi(self))
}

///|
pub fn Context::fill_preserve(self : Context) -> Unit raise CairoError {
  check_status(context_fill_preserve_ffi(self))
}

///|
pub fn Context::stroke(self : Context) -> Unit raise CairoError {
  check_status(context_stroke_ffi(self))
}

///|
pub fn Context::stroke_preserve(self : Context) -> Unit raise CairoError {
  check_status(context_stroke_preserve_ffi(self))
}

///|
pub fn Context::copy_page(self : Context) -> Unit raise CairoError {
  check_status(context_copy_page_ffi(self))
}

///|
pub fn Context::show_page(self : Context) -> Unit raise CairoError {
  check_status(context_show_page_ffi(self))
}
