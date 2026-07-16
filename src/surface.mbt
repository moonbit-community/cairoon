///|
/// An owning handle to a Cairo drawing destination or source.
///
/// Every backend uses this same opaque wrapper. It holds one internal
/// `cairo_surface_t` owner, releases it through the raw object's finalizer, and
/// may retain a parent surface or caller pixel buffer when Cairo depends on it.
/// Identity equality and hashing compare the underlying Cairo pointer.
struct Surface(@surface_impl.RawSurface)

///|
fn Surface::from_raw(raw : @surface_impl.RawSurface) -> Surface {
  Surface(raw)
}

///|
fn Surface::to_raw(self : Surface) -> @surface_impl.RawSurface {
  self.0
}

///|
fn surface_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_surface_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn surface_type_from_raw(raw : Int) -> SurfaceType raise CairoError {
  match raw {
    0 => SurfaceTypeImage
    1 => SurfaceTypePdf
    2 => SurfaceTypePs
    3 => SurfaceTypeXlib
    4 => SurfaceTypeXcb
    5 => SurfaceTypeGlitz
    6 => SurfaceTypeQuartz
    7 => SurfaceTypeWin32
    8 => SurfaceTypeBeos
    9 => SurfaceTypeDirectfb
    10 => SurfaceTypeSvg
    11 => SurfaceTypeOs2
    12 => SurfaceTypeWin32Printing
    13 => SurfaceTypeQuartzImage
    14 => SurfaceTypeScript
    15 => SurfaceTypeQt
    16 => SurfaceTypeRecording
    17 => SurfaceTypeVg
    18 => SurfaceTypeGl
    19 => SurfaceTypeDrm
    20 => SurfaceTypeTee
    21 => SurfaceTypeXml
    22 => SurfaceTypeSkia
    23 => SurfaceTypeSubsurface
    24 => SurfaceTypeCogl
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo surface type: \{raw}",
      )
  }
}

///|
fn checked_c_string_bytes(value : String) -> Bytes raise CairoError {
  let bytes = @utf8.encode(value)
  check_no_embedded_nul(bytes)
  bytes
}

///|
fn checked_path_bytes(path : String) -> Bytes raise CairoError {
  checked_c_string_bytes(path)
}

///|
/// Create a surface compatible with this surface's backend.
///
/// `content` selects color and alpha channels; dimensions are backend device
/// units and must be non-negative. The returned surface is an independent
/// owner, although Cairo may choose a different backend internally. Invalid
/// sizes and source-surface failures raise the corresponding `CairoError`.
pub fn Surface::create_similar(
  self : Surface,
  content : Content,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_raw(
    self.to_raw(),
    content.to_raw(),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a compatible surface from a pycairo-style raw `cairo_content_t`.
///
/// Accepted values are `0x1000`, `0x2000`, and `0x3000`, matching Cairo's
/// color, alpha, and color-alpha constants. Unknown integers raise
/// `CairoInvalidArgument(InvalidContent, _)`; dimensions and source errors use
/// the same checked behavior as `create_similar()`.
pub fn Surface::create_similar_raw(
  self : Surface,
  content : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_raw(
    self.to_raw(),
    checked_content_raw(content),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a compatible image surface with an explicit pixel format.
///
/// Unlike `create_similar()`, a successful result is always an image surface
/// and owns storage independent of `self`. `width` and `height` are pixels and
/// must be non-negative. Invalid formats, sizes, or source state raise their
/// checked `CairoError` status.
pub fn Surface::create_similar_image(
  self : Surface,
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_image_raw(
    self.to_raw(),
    format.to_raw(),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a compatible image surface from a raw `cairo_format_t` integer.
///
/// This entry point preserves pycairo C-int compatibility, including formats
/// supported by the linked Cairo version. The result is still checked and
/// owned exactly like `create_similar_image()`; unknown values raise
/// `CairoInvalidArgument(InvalidFormat, _)`.
pub fn Surface::create_similar_image_raw(
  self : Surface,
  format : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_image_raw(
    self.to_raw(),
    format,
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a rectangular subsurface that redirects drawing into `self`.
///
/// The rectangle is expressed in this surface's device-space units. Drawing to
/// the child is translated and clipped to that rectangle; drawing outside it
/// is discarded. Cairoon retains the parent wrapper for the child's lifetime.
/// Negative dimensions or an unusable parent raise checked `CairoError`.
pub fn Surface::create_for_rectangle(
  self : Surface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_for_rectangle_raw(
    self.to_raw(),
    x,
    y,
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Return this surface's current Cairo status without raising.
///
/// This diagnostic also reports `SurfaceFinished` after cairoon has explicitly
/// finished a successful surface. Safe operations check and raise statuses
/// themselves, so callers do not need to poll this method after each call.
pub fn Surface::status(self : Surface) -> Status {
  surface_status_from_raw(@surface_impl.status_raw(self.to_raw()))
}

///|
/// Return whether two wrappers refer to the same `cairo_surface_t`.
///
/// This is pointer identity, not pixel or document-content equality. Borrowed
/// surfaces returned by Context or Pattern bridges compare equal to the owner
/// they reference.
pub fn Surface::equal(self : Surface, other : Surface) -> Bool {
  @surface_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return a process-local hash of the underlying Cairo surface pointer.
///
/// Equal live surfaces have equal hashes. The value is meaningful only for
/// identity-based collections in the current process and is not stable across
/// runs.
pub fn Surface::hash(self : Surface) -> UInt64 {
  @surface_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for Surface with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Surface with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Surface with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
fn content_from_raw(raw : Int) -> Content raise CairoError {
  match raw {
    0x1000 => ContentColor
    0x2000 => ContentAlpha
    0x3000 => ContentColorAlpha
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo content: \{raw}")
  }
}

///|
fn Content::to_raw(self : Content) -> Int {
  match self {
    ContentColor => 0x1000
    ContentAlpha => 0x2000
    ContentColorAlpha => 0x3000
  }
}

///|
fn checked_content_raw(raw : Int) -> Int raise CairoError {
  match raw {
    0x1000 | 0x2000 | 0x3000 => raw
    _ => raise CairoInvalidArgument(InvalidContent, InvalidContent.message())
  }
}

///|
/// Return the typed color/alpha content carried by this surface.
///
/// The value describes channels, not a concrete pixel layout. Finished or
/// otherwise failed surfaces raise their checked `CairoError` status.
pub fn Surface::get_content(self : Surface) -> Content raise CairoError {
  content_from_raw(self.get_content_raw())
}

///|
/// Return the raw `cairo_content_t` integer for pycairo-compatible code.
///
/// Successful values are the exact Cairo ABI constants `0x1000`, `0x2000`, or
/// `0x3000`. Surface failures are checked before the integer is returned.
pub fn Surface::get_content_raw(self : Surface) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.status_raw(self.to_raw()))
  @surface_impl.get_content_raw(self.to_raw())
}

///|
/// Return the Cairo backend type of this surface.
///
/// This identifies image, PDF, PS, SVG, recording, tee, subsurface, and other
/// Cairo backends; it does not transfer ownership. A failed or finished surface
/// raises its current `CairoError` status.
pub fn Surface::get_type(self : Surface) -> SurfaceType raise CairoError {
  check_surface_status_raw(@surface_impl.status_raw(self.to_raw()))
  surface_type_from_raw(@surface_impl.get_type_raw(self.to_raw()))
}

///|
/// Return this surface's backend device, when it has one.
///
/// Cairo returns a borrowed device; cairoon takes a native reference and wraps
/// it as an independently owned `Device`, so the result remains valid after the
/// surface wrapper leaves scope. Image and other device-less surfaces return
/// `None`. Surface or device errors raise checked `CairoError`.
pub fn Surface::get_device(self : Surface) -> Device? raise CairoError {
  let has_device = Ref(0)
  let status = Ref(0)
  let device = @device_impl.surface_get_device_raw(
    self.to_raw(),
    has_device,
    status,
  )
  check_device_status_raw(status.val)
  if has_device.val == 0 {
    None
  } else {
    check_device_status_raw(@device_impl.status_raw(device))
    Some(Device::from_raw(device))
  }
}

///|
/// Finish the surface and release backend resources deterministically.
///
/// Finishing is idempotent for a successful surface and leaves the wrapper
/// available for status, identity, and final destruction only. Buffer-backed
/// image storage retained by cairoon is released here. Even with a pre-existing
/// sticky Cairo error, native cleanup still runs and that original error is
/// then raised.
pub fn Surface::finish(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.finish_raw(self.to_raw()))
}

///|
/// Run `f`, then finish this surface on both success and error paths.
///
/// On success, a finish failure is raised and otherwise the closure value is
/// returned. If `f` raises, cairoon performs best-effort raw cleanup and
/// re-raises the original closure error even when finishing also reports a
/// sticky status. This is the MoonBit counterpart to pycairo's surface context
/// manager.
pub fn[T] Surface::with_finished(
  self : Surface,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  try f() catch {
    err => {
      let _ = @surface_impl.finish_raw(self.to_raw())
      raise err
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
}
