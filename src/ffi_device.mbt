///|
#borrow(surface, has_device, status)
extern "C" fn surface_get_device_ffi(
  surface : @surface_impl.RawSurface,
  has_device : Ref[Int],
  status : Ref[Status],
) -> @device_impl.RawDevice = "cairoon_surface_get_device"
