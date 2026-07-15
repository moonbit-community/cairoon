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
  check_status(context_set_source_ffi(self, pattern.to_raw()))
}

///|
pub fn Context::set_source_surface(
  self : Context,
  surface : Surface,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Unit raise CairoError {
  check_status(context_set_source_surface_ffi(self, surface, x, y))
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
  check_status(context_mask_ffi(self, pattern.to_raw()))
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
