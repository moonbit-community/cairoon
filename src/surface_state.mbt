///|
/// Complete pending Cairo drawing before direct backend or memory access.
///
/// Call this before reading or modifying image bytes outside Cairo. After a
/// direct modification, call `mark_dirty()` or `mark_dirty_rectangle()` before
/// drawing through Cairo again. Backends without direct access may treat this
/// as a no-op. Sticky and finished statuses raise `CairoError`.
pub fn Surface::flush(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.flush_raw(self.to_raw()))
}

///|
/// Notify Cairo that external code modified this surface's entire contents.
///
/// Direct access must be bracketed by `flush()` before the modification and
/// this call afterward; concurrent Cairo and external drawing is unsupported.
/// The mutation invalidates cached snapshots and raises the checked surface
/// status, including `SurfaceFinished`.
pub fn Surface::mark_dirty(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mark_dirty_raw(self.to_raw()))
}

///|
/// Notify Cairo that external code modified one device-space rectangle.
///
/// `x` and `y` locate the dirty region and `width`/`height` give its size in
/// integer surface device units. Call `flush()` before the external write.
/// Cairo may retain caches outside this rectangle and resets cached clipping;
/// finished or failed surfaces raise `CairoError`.
pub fn Surface::mark_dirty_rectangle(
  self : Surface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.mark_dirty_rectangle_raw(self.to_raw(), x, y, width, height),
  )
}

///|
/// Set a hidden device-coordinate translation for this surface.
///
/// Offsets are measured in device units and affect both drawing to the surface
/// and using it as a source pattern, without appearing as a Context CTM
/// transform. The operation mutates surface state and raises checked errors for
/// failed or finished surfaces.
pub fn Surface::set_device_offset(
  self : Surface,
  x_offset : Double,
  y_offset : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_device_offset_raw(self.to_raw(), x_offset, y_offset),
  )
}

///|
/// Return the hidden device-coordinate translation as `(x, y)`.
///
/// Values are in device units and reflect the last `set_device_offset()` call
/// or Cairo's default zero offset. Failed or finished surfaces raise their
/// checked `CairoError` status.
pub fn Surface::get_device_offset(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_offset = Ref(0.0)
  let y_offset = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_device_offset_raw(self.to_raw(), x_offset, y_offset),
  )
  (x_offset.val, y_offset.val)
}

///|
/// Set the hidden X and Y device scale applied after the Context CTM.
///
/// The scale affects both rendering targets and source-pattern sampling.
/// Neither factor may be zero because Cairo requires an invertible transform;
/// singular values raise `CairoInvalidArgument(InvalidMatrix, _)`. Other
/// surface failures are mapped through `CairoError`.
pub fn Surface::set_device_scale(
  self : Surface,
  x_scale : Double,
  y_scale : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_device_scale_raw(self.to_raw(), x_scale, y_scale),
  )
}

///|
/// Return the current hidden device scale as `(x_scale, y_scale)`.
///
/// A newly created surface normally reports `(1.0, 1.0)`. The query is checked,
/// so finished or otherwise failed surfaces raise `CairoError`.
pub fn Surface::get_device_scale(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_scale = Ref(0.0)
  let y_scale = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_device_scale_raw(self.to_raw(), x_scale, y_scale),
  )
  (x_scale.val, y_scale.val)
}

///|
/// Set horizontal and vertical resolution for raster fallbacks.
///
/// Values are pixels per inch and must be positive. They affect unsupported
/// operations emitted by vector backends at `copy_page()` or `show_page()`;
/// raster backends use native resolution. Non-positive values raise
/// `CairoInvalidArgument(InvalidMatrix, _)` and other failures raise
/// `CairoError`.
pub fn Surface::set_fallback_resolution(
  self : Surface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_fallback_resolution_raw(
      self.to_raw(),
      x_pixels_per_inch,
      y_pixels_per_inch,
    ),
  )
}

///|
/// Return raster-fallback resolution as horizontal and vertical pixels/inch.
///
/// Cairo defaults both dimensions to 300 PPI until changed. The setting mainly
/// matters for PDF, PS, SVG, and other vector output. Failed or finished
/// surfaces raise checked `CairoError`.
pub fn Surface::get_fallback_resolution(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_pixels_per_inch = Ref(0.0)
  let y_pixels_per_inch = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_fallback_resolution_raw(
      self.to_raw(),
      x_pixels_per_inch,
      y_pixels_per_inch,
    ),
  )
  (x_pixels_per_inch.val, y_pixels_per_inch.val)
}

///|
/// Report whether this backend consumes text and cluster metadata.
///
/// `false` does not mean `Context::show_text_glyphs()` will fail; Cairo can
/// still render glyphs while ignoring the UTF-8/cluster mapping. Use this to
/// avoid computing metadata for a backend that cannot preserve it. Surface
/// errors, including `SurfaceFinished`, are raised.
pub fn Surface::has_show_text_glyphs(self : Surface) -> Bool raise CairoError {
  let status = Ref(0)
  let has = @surface_impl.has_show_text_glyphs_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  has
}

///|
/// Emit the current page while retaining its contents for the next page.
///
/// This matters for multi-page PDF and PS output; unsupported single-page
/// backends may do nothing. Output and finished-surface failures raise checked
/// `CairoError`. Use `show_page()` when the next page should start empty.
pub fn Surface::copy_page(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.copy_page_raw(self.to_raw()))
}

///|
/// Emit the current page and clear it before the next page.
///
/// Multi-page backends finalize one page; unsupported backends may treat the
/// call as a no-op. Stream/write and finished-surface failures raise checked
/// `CairoError`. Use `copy_page()` to preserve current page contents.
pub fn Surface::show_page(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.show_page_raw(self.to_raw()))
}
