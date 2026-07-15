///|
#borrow(device, surface)
extern "C" fn script_device_from_recording_surface_ffi(
  device : @device_impl.RawDevice,
  surface : Surface,
) -> Status = "cairoon_script_device_from_recording_surface"

///|
#borrow(device, status)
extern "C" fn script_surface_create_ffi(
  device : @device_impl.RawDevice,
  content : Content,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create"

///|
#borrow(device, status)
extern "C" fn script_surface_create_raw_ffi(
  device : @device_impl.RawDevice,
  content : Int,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create"

///|
#borrow(device, target, status)
extern "C" fn script_surface_create_for_target_ffi(
  device : @device_impl.RawDevice,
  target : Surface,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create_for_target"

///|
#borrow(surface, has_device, status)
extern "C" fn surface_get_device_ffi(
  surface : Surface,
  has_device : Ref[Int],
  status : Ref[Status],
) -> @device_impl.RawDevice = "cairoon_surface_get_device"
