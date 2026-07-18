///|
/// Create a callback-backed pixel source with typed content.
///
/// Raster-source patterns require Cairo 1.12 or newer. `width` and `height`
/// are the non-negative maximum sample-area dimensions, not an allocated image.
/// Register an acquire callback before drawing. Raises `InvalidSize`,
/// `InvalidContent`, allocation failure, or another creation status.
pub fn Pattern::raster_source(
  content : Content,
  width : Int,
  height : Int,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_raster_source_raw(
    content.to_raw(),
    width,
    height,
  )
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Create a callback-backed pixel source from a Cairo content integer.
///
/// For pycairo compatibility, accepted values are exactly `0x1000` (color),
/// `0x2000` (alpha), and `0x3000` (color plus alpha). Other values raise
/// `CairoInvalidArgument(InvalidContent, _)` before C; dimensions and Cairo
/// 1.12 requirements match `raster_source()`.
pub fn Pattern::raster_source_raw(
  content : Int,
  width : Int,
  height : Int,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_raster_source_raw(
    checked_content_raw(content),
    width,
    height,
  )
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Install the mandatory raster acquire callback and optional release callback.
///
/// For each request, `acquire` receives the target and a pixel rectangle in
/// sample space. Return a compatible surface covering that rectangle; use
/// `target.create_similar_image()` and a device offset for a subregion. The
/// binding retains the returned surface until Cairo releases the acquisition.
/// Both closures are retained until replacement, clearing, or finalization.
pub fn Pattern::raster_set_acquire(
  self : Pattern,
  acquire : (Surface, RectangleInt) -> Surface,
  release? : ((Surface) -> Unit)? = None,
) -> Unit raise CairoError {
  self.raster_set_callbacks(acquire=Some(acquire), release~)
}

///|
/// Replace this raster pattern's callback registration.
///
/// Callback types are non-raising: recoverable MoonBit errors must be handled
/// inside the closure and must never unwind through Cairo. A finished or error
/// surface returned by `acquire` is rejected and the drawing operation reports
/// a Cairo error. `release`, when present, receives each successfully acquired
/// surface before the binding drops its retained owner; internal cleanup still
/// runs when no user release is registered.
///
/// Passing both options as `None` clears the registration. Release-only state
/// is queryable but cannot supply pixels. Replacement requested from inside a
/// callback is deferred until all acquisitions using the old pair are released,
/// preserving closure and surface lifetimes. Raises `PatternTypeMismatch` on a
/// non-raster pattern or another checked registration status.
pub fn Pattern::raster_set_callbacks(
  self : Pattern,
  acquire? : ((Surface, RectangleInt) -> Surface)? = None,
  release? : ((Surface) -> Unit)? = None,
) -> Unit raise CairoError {
  let raw_acquire = match acquire {
    None => None
    Some(acquire) =>
      Some(fn(target, x, y, width, height) {
        acquire(
          Surface::from_raw(target),
          RectangleInt::new(x~, y~, width~, height~),
        ).to_raw()
      })
  }
  let raw_release = match release {
    None => None
    Some(release) => Some(fn(surface) { release(Surface::from_raw(surface)) })
  }
  check_pattern_status_raw(
    @pattern_impl.raster_set_callbacks_raw(
      self.to_raw(),
      acquire=raw_acquire,
      release=raw_release,
    ),
  )
}

///|
/// Return the currently effective acquire and release closures.
///
/// Returned closures are strong MoonBit references and may outlive a later
/// replacement. During a callback-triggered deferred replacement, this reports
/// the pair still serving outstanding acquisitions. Raises
/// `PatternTypeMismatch` on a non-raster pattern or a sticky pattern error.
pub fn Pattern::raster_get_callbacks(
  self : Pattern,
) -> (((Surface, RectangleInt) -> Surface)?, ((Surface) -> Unit)?) raise CairoError {
  let has_acquire = Ref(0)
  let has_release = Ref(0)
  let status = Ref(0)
  let _ = @pattern_impl.raster_has_callbacks_raw(
    self.to_raw(),
    has_acquire,
    has_release,
    status,
  )
  check_pattern_status_raw(status.val)
  let acquire = if has_acquire.val == 0 {
    None
  } else {
    let acquire_status = Ref(0)
    let raw_acquire = @pattern_impl.raster_get_acquire_raw(
      self.to_raw(),
      acquire_status,
    )
    check_pattern_status_raw(acquire_status.val)
    Some(fn(target : Surface, extents : RectangleInt) {
      Surface::from_raw(
        raw_acquire(
          target.to_raw(),
          extents.x,
          extents.y,
          extents.width,
          extents.height,
        ),
      )
    })
  }
  let release = if has_release.val == 0 {
    None
  } else {
    let release_status = Ref(0)
    let raw_release = @pattern_impl.raster_get_release_raw(
      self.to_raw(),
      release_status,
    )
    check_pattern_status_raw(release_status.val)
    Some(fn(surface : Surface) { raw_release(surface.to_raw()) })
  }
  (acquire, release)
}

///|
/// Clear both raster callbacks and release their retained closures.
///
/// If called from acquire or release, clearing takes effect after every
/// outstanding acquisition using the current pair has run internal cleanup.
/// Raises `PatternTypeMismatch` on a non-raster pattern or a sticky error.
pub fn Pattern::raster_clear_callbacks(self : Pattern) -> Unit raise CairoError {
  self.raster_clear_acquire()
}

///|
/// Clear the raster acquire/release pair.
///
/// This is the pycairo-compatible name for `raster_clear_callbacks()`. It uses
/// the same deferred, reentrant-safe cleanup and raises the same checked errors.
pub fn Pattern::raster_clear_acquire(self : Pattern) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.raster_clear_callbacks_raw(self.to_raw()),
  )
}

///|
/// Return the acquire callback paired with its optional release callback.
///
/// Returns `None` when no acquire callback is effective, including release-only
/// registration. The returned closures are strong references. Raises
/// `PatternTypeMismatch` on a non-raster pattern or a sticky pattern error.
pub fn Pattern::raster_get_acquire(
  self : Pattern,
) -> ((Surface, RectangleInt) -> Surface, ((Surface) -> Unit)?)? raise CairoError {
  let (acquire, release) = self.raster_get_callbacks()
  match acquire {
    None => None
    Some(acquire) => Some((acquire, release))
  }
}
