///|
#borrow(filename, status)
extern "C" fn script_device_create_ffi(
  filename : Bytes,
  status : Ref[Status],
) -> Device = "cairoon_script_device_create"

///|
#owned(writer)
#borrow(call_writer, status)
extern "C" fn script_device_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
  status : Ref[Status],
) -> Device = "cairoon_script_device_create_for_stream"

///|
#borrow(device)
extern "C" fn device_status_ffi(device : Device) -> Status = "cairoon_device_status"

///|
#borrow(device, other)
extern "C" fn device_equal_ffi(device : Device, other : Device) -> Bool = "cairoon_device_equal"

///|
#borrow(device)
extern "C" fn device_hash_ffi(device : Device) -> UInt64 = "cairoon_device_hash"

///|
#borrow(device, status)
extern "C" fn device_get_type_ffi(
  device : Device,
  status : Ref[Status],
) -> DeviceType = "cairoon_device_get_type"

///|
#borrow(device)
extern "C" fn device_finish_ffi(device : Device) -> Status = "cairoon_device_finish"

///|
#borrow(device)
extern "C" fn device_flush_ffi(device : Device) -> Status = "cairoon_device_flush"

///|
#borrow(device)
extern "C" fn device_acquire_ffi(device : Device) -> Status = "cairoon_device_acquire"

///|
#borrow(device)
extern "C" fn device_release_ffi(device : Device) -> Status = "cairoon_device_release"

///|
#borrow(device, status)
extern "C" fn script_device_get_mode_ffi(
  device : Device,
  status : Ref[Status],
) -> ScriptMode = "cairoon_script_device_get_mode"

///|
#borrow(device)
extern "C" fn script_device_set_mode_ffi(
  device : Device,
  mode : ScriptMode,
) -> Status = "cairoon_script_device_set_mode"

///|
#borrow(device, comment)
extern "C" fn script_device_write_comment_ffi(
  device : Device,
  comment : Bytes,
) -> Status = "cairoon_script_device_write_comment"

///|
#borrow(device, surface)
extern "C" fn script_device_from_recording_surface_ffi(
  device : Device,
  surface : Surface,
) -> Status = "cairoon_script_device_from_recording_surface"

///|
#borrow(device, status)
extern "C" fn script_surface_create_ffi(
  device : Device,
  content : Content,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create"

///|
#borrow(device, target, status)
extern "C" fn script_surface_create_for_target_ffi(
  device : Device,
  target : Surface,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create_for_target"

///|
#borrow(surface, has_device, status)
extern "C" fn surface_get_device_ffi(
  surface : Surface,
  has_device : Ref[Int],
  status : Ref[Status],
) -> Device = "cairoon_surface_get_device"
