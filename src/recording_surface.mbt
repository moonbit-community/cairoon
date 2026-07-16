///|
/// Create an owning recording surface for replayable drawing operations.
///
/// Cairo snapshots the paths, patterns, and other native state needed by each
/// recorded operation, so temporary drawing arguments need not outlive the
/// call that records them. `None` creates an unbounded surface; `Some(rect)`
/// supplies finite extents in Cairo recording-surface pixels. This requires
/// Cairo recording-surface support (Cairo 1.10 or newer); an unavailable
/// backend raises `CairoError(InvalidStatus, _)`, while allocation and native
/// failures raise their checked `CairoError` values.
pub fn Surface::recording(
  content : Content,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw_content = content.to_raw()
  let raw = match extents {
    None =>
      @surface_impl.recording_create_raw(
        raw_content, false, 0.0, 0.0, 0.0, 0.0, status,
      )
    Some(rect) =>
      @surface_impl.recording_create_raw(
        raw_content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a recording surface from a pycairo-compatible `cairo_content_t` int.
///
/// This has the same ownership, snapshot, and optional pixel-extents contract
/// as `Surface::recording`. Known Cairo values such as `0x1000`, `0x2000`, and
/// `0x3000` are accepted; any other value raises
/// `CairoInvalidArgument(InvalidContent, _)` before entering Cairo.
pub fn Surface::recording_raw(
  content : Int,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let checked_content = checked_content_raw(content)
  let raw = match extents {
    None =>
      @surface_impl.recording_create_raw(
        checked_content, false, 0.0, 0.0, 0.0, 0.0, status,
      )
    Some(rect) =>
      @surface_impl.recording_create_raw(
        checked_content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Measure the bounding box of ink produced by the recorded operations.
///
/// The returned rectangle is `(x0, y0, width, height)` in recording-surface
/// coordinates and can size a replay target. A non-recording receiver raises
/// `CairoError(SurfaceTypeMismatch, _)`; an explicitly finished receiver raises
/// `CairoError(SurfaceFinished, _)` under cairoon's terminal-surface policy.
pub fn Surface::recording_ink_extents(
  self : Surface,
) -> Rectangle raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.recording_ink_extents_raw(
      self.to_raw(),
      x0,
      y0,
      width,
      height,
    ),
  )
  Rectangle::new(x0.val, y0.val, width.val, height.val)
}

///|
/// Return the finite extents supplied at construction, or `None` if unbounded.
///
/// A bounded result preserves the original floating-point rectangle rather
/// than Cairo's internal integer analysis bounds. Matching pycairo, this
/// read-only query remains available after `finish`; a different surface type
/// or a sticky native error raises the corresponding checked `CairoError`.
pub fn Surface::recording_get_extents(
  self : Surface,
) -> Rectangle? raise CairoError {
  let has_extents = Ref(0)
  let x = Ref(0.0)
  let y = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.recording_get_extents_raw(
      self.to_raw(),
      has_extents,
      x,
      y,
      width,
      height,
    ),
  )
  if has_extents.val == 0 {
    None
  } else {
    Some(Rectangle::new(x.val, y.val, width.val, height.val))
  }
}
