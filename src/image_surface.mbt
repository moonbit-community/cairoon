///|
/// Create an in-memory image surface with zero-initialized pixel channels.
///
/// `width` and `height` are measured in pixels and may be zero but not
/// negative. Cairo chooses a correctly aligned stride for `format`. Invalid
/// dimensions, an unsupported format for the linked Cairo version, allocation
/// failure, and other native errors use the checked `CairoError` hierarchy.
pub fn Surface::image(
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let raw = @surface_impl.image_create_raw(format.to_raw(), width, height)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create an image surface from a pycairo-compatible raw C format integer.
///
/// Prefer `Surface::image()` for typed code. Known values have the same
/// zero-initialization and dimension rules; an unknown or unavailable value
/// raises `CairoInvalidArgument(InvalidFormat, _)`.
pub fn Surface::image_raw(
  format : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let raw = @surface_impl.image_create_raw(format, width, height)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a zero-copy image surface backed by `data`.
///
/// Cairo uses the array's existing bytes as the initial pixels and rendering
/// writes back into the same storage. Cairoon retains the array until the
/// surface is finished or finalized, so the caller does not need to extend its
/// lexical lifetime. If `stride` is omitted, `Format::stride_for_width()` is
/// used. The stride must satisfy Cairo's alignment rules and `data.length()`
/// must cover at least `height * stride`; extra bytes are not part of the
/// image. Negative dimensions, an invalid stride, or a short buffer raise the
/// corresponding `CairoInvalidArgument` suberror.
///
/// Direct writes through the original array bypass `ImageData::set()`; call
/// `mark_dirty()` before asking Cairo to read such external changes. Call
/// `flush()` before inspecting writes produced by Cairo.
pub fn Surface::image_for_data(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride? : Int = Format::stride_for_width(format, width),
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_create_for_data_raw(
    data,
    format.to_raw(),
    width,
    height,
    stride,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a zero-copy image surface from a raw C format integer.
///
/// This is the pycairo compatibility form of `image_for_data()`. If `stride`
/// is omitted, Cairo's raw format/width stride calculation is used; failure to
/// calculate one raises `CairoInvalidArgument(InvalidFormat, _)`. Buffer
/// retention, shared-storage behavior, size validation, dirty/flush rules, and
/// all other errors match the typed form.
pub fn Surface::image_for_data_raw(
  data : FixedArray[Byte],
  format : Int,
  width : Int,
  height : Int,
  stride? : Int,
) -> Surface raise CairoError {
  let actual_stride = match stride {
    Some(stride) => stride
    None => {
      let calculated = Format::stride_for_width_raw(format, width)
      if calculated < 0 {
        raise CairoInvalidArgument(InvalidFormat, InvalidFormat.message())
      }
      calculated
    }
  }
  let status = Ref(0)
  let raw = @surface_impl.image_create_for_data_raw(
    data, format, width, height, actual_stride, status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Return this image surface's width in pixels.
///
/// Calling the image-specific getter on another surface subtype raises
/// `CairoError(SurfaceTypeMismatch, _)`; a finished surface raises
/// `CairoError(SurfaceFinished, _)`.
pub fn Surface::get_width(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let width = @surface_impl.image_get_width_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  width
}

///|
/// Return this image surface's height in pixels.
///
/// Calling the image-specific getter on another surface subtype raises
/// `CairoError(SurfaceTypeMismatch, _)`; a finished surface raises
/// `CairoError(SurfaceFinished, _)`.
pub fn Surface::get_height(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let height = @surface_impl.image_get_height_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  height
}

///|
/// Return the distance in bytes between consecutive image rows.
///
/// The stride can exceed `width * bytes_per_pixel` because Cairo requires row
/// alignment. Non-image and finished surfaces raise `SurfaceTypeMismatch` and
/// `SurfaceFinished`, respectively, through `CairoError`.
pub fn Surface::get_stride(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let stride = @surface_impl.image_get_stride_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  stride
}

///|
/// Return this image surface's pixel format as a typed `Format`.
///
/// Prefer this method for exhaustive typed handling. A future native value not
/// known to this cairoon build raises `CairoInvalidArgument(InvalidStatus, _)`;
/// subtype and lifecycle errors are also checked.
pub fn Surface::get_format(self : Surface) -> Format raise CairoError {
  format_from_raw(self.get_format_raw())
}

///|
/// Return this image surface's pixel format as the underlying C integer.
///
/// This compatibility entry point preserves values that a future Cairo may
/// add. Calling it on a non-image or finished surface raises the corresponding
/// checked `CairoError`.
pub fn Surface::get_format_raw(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let format = @surface_impl.image_get_format_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  format
}

///|
/// Return an independent snapshot of all image bytes.
///
/// Cairo is flushed before copying. The result has `height * stride` bytes,
/// includes row padding, and no longer aliases the surface; an empty image
/// returns empty bytes. Non-image, finished, allocation, and oversized-image
/// failures use the checked `CairoError` hierarchy.
pub fn Surface::copy_data(self : Surface) -> Bytes raise CairoError {
  let status = Ref(0)
  let bytes = @surface_impl.image_copy_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  bytes
}
