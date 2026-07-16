///|
/// A mutable byte view into an image surface's live pixel storage.
///
/// `ImageData` does not allocate or own a second pixel buffer. Its raw view
/// retains either the source `Surface` or the active `MappedImageSurface`, so
/// the storage remains alive while the view is valid. Finishing the source or
/// unmapping the mapped image invalidates all derived views; every operation
/// rechecks that owner before touching memory. Indices address bytes, including
/// row padding, rather than logical pixels.
struct ImageData(@surface_impl.RawImageData)

///|
fn ImageData::from_raw(raw : @surface_impl.RawImageData) -> ImageData {
  ImageData(raw)
}

///|
fn ImageData::to_raw(self : ImageData) -> @surface_impl.RawImageData {
  self.0
}

///|
/// Return a mutable view of this image surface's pixel bytes.
///
/// Pending Cairo drawing is flushed before the view is created. The view
/// retains `self` and remains usable if the original MoonBit variable leaves
/// scope, but `Surface::finish()` invalidates it. Calling this on a non-image
/// surface raises `CairoError(SurfaceTypeMismatch, _)`; a finished or errored
/// surface raises its checked status.
pub fn Surface::get_data(self : Surface) -> ImageData raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_get_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.data_status_raw(raw))
  ImageData::from_raw(raw)
}

///|
/// Return a mutable byte view of an active mapped image.
///
/// Pending drawing to the mapped image is flushed first. The returned view
/// retains the mapped handle, but it becomes invalid as soon as either
/// `unmap()` or `Surface::unmap_image()` completes. Access after unmapping
/// raises `CairoError(SurfaceFinished, _)`.
pub fn MappedImageSurface::get_data(
  self : MappedImageSurface,
) -> ImageData raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.mapped_get_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.data_status_raw(raw))
  ImageData::from_raw(raw)
}

///|
/// Return the view's current owner status without raising.
///
/// `Success` means the source surface or mapping is still live. A finished
/// surface or consumed mapping reports `SurfaceFinished`; an unknown native
/// status is represented as `InvalidStatus`.
pub fn ImageData::status(self : ImageData) -> Status {
  surface_status_from_raw(@surface_impl.data_status_raw(self.to_raw()))
}

///|
/// Return the byte length of this live view.
///
/// The length is `height * stride`, so it includes row padding and can be zero
/// for an empty image. The owner is checked before the stored length is
/// returned; a finished surface or consumed mapping raises `SurfaceFinished`.
pub fn ImageData::length(self : ImageData) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.data_status_raw(self.to_raw()))
  @surface_impl.data_length_raw(self.to_raw())
}

///|
/// Read one byte from the live image storage.
///
/// Valid indices are `0 <= index < length()`. A negative or out-of-range index
/// raises `CairoInvalidArgument(InvalidIndex, _)`; an invalidated owner raises
/// its checked surface error first.
pub fn ImageData::get(self : ImageData, index : Int) -> Byte raise CairoError {
  let status = Ref(0)
  let value = @surface_impl.data_get_raw(self.to_raw(), index, status)
  check_surface_status_raw(status.val)
  value
}

///|
/// Replace one byte in the live image storage and mark the image dirty.
///
/// The write is immediately visible through other views of the same storage.
/// Cairoon's native layer calls `cairo_surface_mark_dirty()` after the write so
/// later Cairo drawing observes it. Invalid indices raise
/// `CairoInvalidArgument(InvalidIndex, _)`, and an invalidated owner raises its
/// checked surface error without writing.
pub fn ImageData::set(
  self : ImageData,
  index : Int,
  value : Byte,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.data_set_raw(self.to_raw(), index, value),
  )
}

///|
/// Copy the current view into independent MoonBit-owned bytes.
///
/// The result includes row padding and remains valid after the surface is
/// finished or the mapped image is unmapped. This method does not create a
/// second mutable view; later changes to either side are not shared. Owner
/// errors are checked before copying.
pub fn ImageData::copy(self : ImageData) -> Bytes raise CairoError {
  let status = Ref(0)
  let bytes = @surface_impl.data_copy_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  bytes
}
