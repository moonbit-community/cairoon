///|
type RawDevice

///|
#borrow(device, surface)
extern "C" fn script_device_from_recording_surface_ffi(
  device : RawDevice,
  surface : @surface_impl.RawSurface,
) -> Int = "cairoon_script_device_from_recording_surface"

///|
#borrow(device, status)
extern "C" fn script_surface_create_ffi(
  device : RawDevice,
  content : Int,
  width : Double,
  height : Double,
  status : Ref[Int],
) -> @surface_impl.RawSurface = "cairoon_script_surface_create"

///|
#borrow(device, target, status)
extern "C" fn script_surface_create_for_target_ffi(
  device : RawDevice,
  target : @surface_impl.RawSurface,
  status : Ref[Int],
) -> @surface_impl.RawSurface = "cairoon_script_surface_create_for_target"

///|
#borrow(filename, status)
extern "C" fn script_device_create_ffi(
  filename : Bytes,
  status : Ref[Int],
) -> RawDevice = "cairoon_script_device_create"

///|
#owned(writer)
#borrow(call_writer, status)
extern "C" fn script_device_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
  status : Ref[Int],
) -> RawDevice = "cairoon_script_device_create_for_stream"

///|
#borrow(device)
extern "C" fn device_status_ffi(device : RawDevice) -> Int = "cairoon_device_status"

///|
#borrow(device, other)
extern "C" fn device_equal_ffi(device : RawDevice, other : RawDevice) -> Bool = "cairoon_device_equal"

///|
#borrow(device)
extern "C" fn device_hash_ffi(device : RawDevice) -> UInt64 = "cairoon_device_hash"

///|
#borrow(device, status)
extern "C" fn device_get_type_ffi(device : RawDevice, status : Ref[Int]) -> Int = "cairoon_device_get_type"

///|
#borrow(device)
extern "C" fn device_finish_ffi(device : RawDevice) -> Int = "cairoon_device_finish"

///|
#borrow(device)
extern "C" fn device_flush_ffi(device : RawDevice) -> Int = "cairoon_device_flush"

///|
#borrow(device)
extern "C" fn device_acquire_ffi(device : RawDevice) -> Int = "cairoon_device_acquire"

///|
#borrow(device)
extern "C" fn device_release_ffi(device : RawDevice) -> Int = "cairoon_device_release"

///|
#borrow(device, status)
extern "C" fn script_device_get_mode_ffi(
  device : RawDevice,
  status : Ref[Int],
) -> Int = "cairoon_script_device_get_mode"

///|
#borrow(device)
extern "C" fn script_device_set_mode_ffi(device : RawDevice, mode : Int) -> Int = "cairoon_script_device_set_mode"

///|
#borrow(device, comment)
extern "C" fn script_device_write_comment_ffi(
  device : RawDevice,
  comment : Bytes,
) -> Int = "cairoon_script_device_write_comment"
