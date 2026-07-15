///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn surface_get_device_raw(
  surface : @surface_impl.RawSurface,
  has_device : Ref[Int],
  status : Ref[Int],
) -> RawDevice {
  ensure_native()
  surface_get_device_ffi(surface, has_device, status)
}

///|
pub fn script_from_recording_surface_raw(
  device : RawDevice,
  surface : @surface_impl.RawSurface,
) -> Int {
  ensure_native()
  script_device_from_recording_surface_ffi(device, surface)
}

///|
pub fn script_surface_create_raw(
  device : RawDevice,
  content : Int,
  width : Double,
  height : Double,
  status : Ref[Int],
) -> @surface_impl.RawSurface {
  ensure_native()
  script_surface_create_ffi(device, content, width, height, status)
}

///|
pub fn script_surface_create_for_target_raw(
  device : RawDevice,
  target : @surface_impl.RawSurface,
  status : Ref[Int],
) -> @surface_impl.RawSurface {
  ensure_native()
  script_surface_create_for_target_ffi(device, target, status)
}

///|
pub fn script_create_path_raw(filename : Bytes, status : Ref[Int]) -> RawDevice {
  ensure_native()
  script_device_create_ffi(filename, status)
}

///|
pub fn script_create_stream_raw(
  writer : (Bytes) -> Int,
  status : Ref[Int],
) -> RawDevice {
  ensure_native()
  script_device_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    status,
  )
}

///|
pub fn status_raw(device : RawDevice) -> Int {
  ensure_native()
  device_status_ffi(device)
}

///|
pub fn equal_raw(device : RawDevice, other : RawDevice) -> Bool {
  ensure_native()
  device_equal_ffi(device, other)
}

///|
pub fn hash_raw(device : RawDevice) -> UInt64 {
  ensure_native()
  device_hash_ffi(device)
}

///|
pub fn get_type_raw(device : RawDevice, status : Ref[Int]) -> Int {
  ensure_native()
  device_get_type_ffi(device, status)
}

///|
pub fn finish_raw(device : RawDevice) -> Int {
  ensure_native()
  device_finish_ffi(device)
}

///|
pub fn flush_raw(device : RawDevice) -> Int {
  ensure_native()
  device_flush_ffi(device)
}

///|
pub fn acquire_raw(device : RawDevice) -> Int {
  ensure_native()
  device_acquire_ffi(device)
}

///|
pub fn release_raw(device : RawDevice) -> Int {
  ensure_native()
  device_release_ffi(device)
}

///|
pub fn script_get_mode_raw(device : RawDevice, status : Ref[Int]) -> Int {
  ensure_native()
  script_device_get_mode_ffi(device, status)
}

///|
pub fn script_set_mode_raw(device : RawDevice, mode : Int) -> Int {
  ensure_native()
  script_device_set_mode_ffi(device, mode)
}

///|
pub fn script_write_comment_raw(device : RawDevice, comment : Bytes) -> Int {
  ensure_native()
  script_device_write_comment_ffi(device, comment)
}
