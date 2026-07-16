///|
/// An owning, single-use image mapping of a `Surface` backing store.
///
/// The raw mapping retains its originating surface and is the only owner that
/// may call `cairo_surface_unmap_image`. Explicit unmap consumes the mapping;
/// the native finalizer also unmaps an abandoned live handle. Derived contexts
/// and `ImageData` views retain this owner but become invalid after unmap.
/// Prefer deterministic `with_unmapped()` scope for normal use.
struct MappedImageSurface(@surface_impl.RawMappedImageSurface)

///|
fn MappedImageSurface::from_raw(
  raw : @surface_impl.RawMappedImageSurface,
) -> MappedImageSurface {
  MappedImageSurface(raw)
}

///|
fn MappedImageSurface::to_raw(
  self : MappedImageSurface,
) -> @surface_impl.RawMappedImageSurface {
  self.0
}

///|
/// Map all or part of this surface to an efficiently writable image.
///
/// `None` maps the whole backing store; `Some(rect)` limits the mapping to that
/// device-space rectangle. The returned handle retains `self` and must be
/// unmapped exactly once. While it is active, using the original surface as a
/// drawing source or target, mapping it again, or changing either device
/// transform is undefined by Cairo. Mapping and source-surface errors are
/// raised through `CairoError`.
pub fn Surface::map_to_image(
  self : Surface,
  extents? : RectangleInt? = None,
) -> MappedImageSurface raise CairoError {
  let status = Ref(0)
  let raw = match extents {
    None =>
      @surface_impl.map_to_image_raw(self.to_raw(), false, 0, 0, 0, 0, status)
    Some(rect) =>
      @surface_impl.map_to_image_raw(
        self.to_raw(),
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.mapped_status_raw(raw))
  MappedImageSurface::from_raw(raw)
}

///|
/// Upload and consume a mapping created from this exact surface.
///
/// A mapping from another surface raises
/// `CairoError(SurfaceTypeMismatch, _)` and remains active. A matching active
/// mapping is always passed to Cairo for cleanup, even when the base or mapped
/// image already has a sticky error; that earlier error is raised after
/// cleanup. On completion the mapped handle and all derived data views are
/// invalid, and a second unmap raises `CairoError(SurfaceFinished, _)`.
pub fn Surface::unmap_image(
  self : Surface,
  mapped : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.unmap_image_raw(self.to_raw(), mapped.to_raw()),
  )
}

///|
/// Return the mapping's current sticky status without raising.
///
/// `Success` means the mapping is active and its image is usable.
/// `SurfaceFinished` means it has already been consumed. An unknown native
/// status is represented as `InvalidStatus`.
pub fn MappedImageSurface::status(self : MappedImageSurface) -> Status {
  surface_status_from_raw(@surface_impl.mapped_status_raw(self.to_raw()))
}

///|
/// Upload and consume this mapping through its retained base surface.
///
/// This is the owner-independent counterpart to `Surface::unmap_image()`.
/// Native cleanup still runs if the base or mapped image has a sticky error,
/// after which that status is raised. The operation is exact-once; later use
/// raises `CairoError(SurfaceFinished, _)`.
pub fn MappedImageSurface::unmap(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_unmap_raw(self.to_raw()))
}

///|
/// Run `f` and deterministically unmap this image on every exit path.
///
/// On normal return, a checked unmap is performed and any cleanup error is
/// raised. If `f` raises, cairoon attempts raw unmap but preserves and re-raises
/// the original closure error even if cleanup also reports an error. Therefore
/// `f` must not retain the mapping, a derived context, or an `ImageData` view
/// for later use.
pub fn[T] MappedImageSurface::with_unmapped(
  self : MappedImageSurface,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  try f() catch {
    err => {
      let _ = @surface_impl.mapped_unmap_raw(self.to_raw())
      raise err
    }
  } noraise {
    value => {
      self.unmap()
      value
    }
  }
}

///|
/// Complete pending drawing to the mapped image without unmapping it.
///
/// The mapping remains active and changes are not uploaded as an unmap side
/// effect. A consumed or errored mapping raises its checked `CairoError`.
pub fn MappedImageSurface::flush(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_flush_raw(self.to_raw()))
}

///|
/// Return the active mapped image's width in pixels.
///
/// For an extent-limited map this is the mapped region's width. A consumed or
/// errored mapping raises its checked `CairoError`.
pub fn MappedImageSurface::get_width(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_width_raw(self.to_raw())
}

///|
/// Return the active mapped image's height in pixels.
///
/// For an extent-limited map this is the mapped region's height. A consumed or
/// errored mapping raises its checked `CairoError`.
pub fn MappedImageSurface::get_height(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_height_raw(self.to_raw())
}

///|
/// Return the active mapped image's row stride in bytes.
///
/// The stride includes any Cairo-required row padding and can exceed the
/// logical pixel width. A consumed or errored mapping raises its checked
/// `CairoError`.
pub fn MappedImageSurface::get_stride(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_stride_raw(self.to_raw())
}

///|
/// Return the active mapped image's pixel format as a typed `Format`.
///
/// Cairo guarantees a successful map has an image format other than
/// `FormatInvalid`. A future value unknown to this build raises
/// `CairoInvalidArgument(InvalidStatus, _)`; mapping errors are also checked.
pub fn MappedImageSurface::get_format(
  self : MappedImageSurface,
) -> Format raise CairoError {
  format_from_raw(self.get_format_raw())
}

///|
/// Return the active mapped image's format as the underlying C integer.
///
/// This pycairo compatibility form preserves future raw values. A consumed or
/// errored mapping raises its checked `CairoError`.
pub fn MappedImageSurface::get_format_raw(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_format_raw(self.to_raw())
}

///|
/// Return an independent snapshot of the active mapped image bytes.
///
/// Pending mapped-image drawing is flushed first. The result contains
/// `height * stride` bytes including row padding and remains valid after
/// unmap; it does not itself upload or consume the mapping. Lifecycle,
/// allocation, and native image errors use the checked `CairoError` hierarchy.
pub fn MappedImageSurface::copy_data(
  self : MappedImageSurface,
) -> Bytes raise CairoError {
  self.flush()
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_copy_data_raw(self.to_raw())
}
