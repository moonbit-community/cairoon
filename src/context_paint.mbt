///|
pub fn Context::set_source_rgb(
  self : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_source_rgb_raw(self.to_raw(), red, green, blue),
  )
}

///|
pub fn Context::set_source_rgba(
  self : Context,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_source_rgba_raw(self.to_raw(), red, green, blue, alpha),
  )
}

///|
pub fn Context::set_source(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_source_raw(self.to_raw(), pattern.to_raw()),
  )
}

///|
pub fn Context::set_source_surface(
  self : Context,
  surface : Surface,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_source_surface_raw(self.to_raw(), surface.to_raw(), x, y),
  )
}

///|
pub fn Context::paint(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.paint_raw(self.to_raw()))
}

///|
pub fn Context::paint_with_alpha(
  self : Context,
  alpha : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.paint_with_alpha_raw(self.to_raw(), alpha),
  )
}

///|
pub fn Context::mask(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.mask_raw(self.to_raw(), pattern.to_raw()),
  )
}

///|
pub fn Context::mask_surface(
  self : Context,
  surface : Surface,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.mask_surface_raw(self.to_raw(), surface.to_raw(), x, y),
  )
}

///|
pub fn Context::fill(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.fill_raw(self.to_raw()))
}

///|
pub fn Context::fill_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.fill_preserve_raw(self.to_raw()))
}

///|
pub fn Context::stroke(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.stroke_raw(self.to_raw()))
}

///|
pub fn Context::stroke_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.stroke_preserve_raw(self.to_raw()))
}

///|
pub fn Context::copy_page(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.copy_page_raw(self.to_raw()))
}

///|
pub fn Context::show_page(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.show_page_raw(self.to_raw()))
}
