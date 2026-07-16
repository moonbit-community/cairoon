///|
/// Set the current source to the opaque color `(red, green, blue)`.
///
/// Each component is clamped to the inclusive range from `0.0` to `1.0`.
/// The resulting solid pattern remains the source for later drawing operations
/// until another source is installed. Raises the checked context status.
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
/// Set the current source to the color `(red, green, blue, alpha)`.
///
/// All four components are clamped to the inclusive range from `0.0` to `1.0`.
/// The resulting solid pattern remains the source for later drawing operations
/// until another source is installed. Raises the checked context status.
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
/// Install `pattern` as the source for subsequent drawing operations.
///
/// The context retains its own Cairo reference to the pattern. Its
/// transformation is locked to the user space in effect at this call, so later
/// CTM changes do not move the source. Raises a checked status from either the
/// context or `pattern`.
pub fn Context::set_source(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_source_raw(self.to_raw(), pattern.to_raw()),
  )
}

///|
/// Use `surface` as a source whose origin appears at user-space `(x, y)`.
///
/// Both coordinates default to `0.0`. This creates and installs a surface
/// pattern with Cairo's default pattern attributes; retrieve it with
/// `get_source()` to adjust those attributes. The context keeps the source
/// surface alive and locks it to the current user space. Raises a checked
/// status from either object.
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
/// Paint the current source everywhere inside the current clip.
///
/// Compositing uses the current operator and source attributes. This operation
/// does not consume the current path. Raises the checked context status.
pub fn Context::paint(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.paint_raw(self.to_raw()))
}

///|
/// Paint the current source inside the clip through a constant-alpha mask.
///
/// `alpha` ranges from `0.0` for fully transparent to `1.0` for fully opaque;
/// the effect otherwise matches `paint()`. The source and current path remain
/// installed. Raises the checked context status.
pub fn Context::paint_with_alpha(
  self : Context,
  alpha : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.paint_with_alpha_raw(self.to_raw(), alpha),
  )
}

///|
/// Paint the current source through the alpha channel of `pattern`.
///
/// Opaque mask locations receive the source and transparent locations do not;
/// the mask's color channels are ignored. The current path is unaffected.
/// Raises a checked status from either the context or mask pattern.
pub fn Context::mask(
  self : Context,
  pattern : Pattern,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.mask_raw(self.to_raw(), pattern.to_raw()),
  )
}

///|
/// Paint the current source through `surface` as an alpha mask.
///
/// The mask surface origin appears at user-space `(x, y)`, with both
/// coordinates defaulting to `0.0`. This is the immediate drawing equivalent
/// of masking with a temporary surface pattern and does not consume the current
/// path. Raises a checked status from either object.
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
/// Fill the current path using the current fill rule and source.
///
/// Cairo implicitly closes each subpath for filling, applies the current clip
/// and compositing operator, then clears the path and current point. Use
/// `fill_preserve()` when the path is needed afterward. Raises the checked
/// context status.
pub fn Context::fill(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.fill_raw(self.to_raw()))
}

///|
/// Fill the current path without clearing it.
///
/// Rendering is identical to `fill()`, including implicit subpath closure and
/// the current fill rule, clip, source, and operator. The path and current point
/// remain available for later operations. Raises the checked context status.
pub fn Context::fill_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.fill_preserve_raw(self.to_raw()))
}

///|
/// Stroke the current path using the active stroke and source state.
///
/// Line width, joins, caps, dashes, clip, and compositing operator all
/// participate. After rendering, Cairo clears the path and current point. Use
/// `stroke_preserve()` to keep them. Raises the checked context status.
pub fn Context::stroke(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.stroke_raw(self.to_raw()))
}

///|
/// Stroke the current path without clearing it.
///
/// Rendering is identical to `stroke()`, using the active line, source, clip,
/// and compositing state, while preserving the path and current point for later
/// operations. Raises the checked context status.
pub fn Context::stroke_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.stroke_preserve_raw(self.to_raw()))
}

///|
/// Emit the current page while retaining its contents for the next page.
///
/// This is the context convenience form of `Surface::copy_page()` on the
/// target and has visible effect on backends that support multiple pages. Use
/// `show_page()` to begin the next page empty. Raises the checked target/context
/// status.
pub fn Context::copy_page(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.copy_page_raw(self.to_raw()))
}

///|
/// Emit the current page and clear it before the next page begins.
///
/// This is the context convenience form of `Surface::show_page()` on the
/// target and has visible effect on backends that support multiple pages. Use
/// `copy_page()` when page contents should carry forward. Raises the checked
/// target/context status.
pub fn Context::show_page(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.show_page_raw(self.to_raw()))
}
