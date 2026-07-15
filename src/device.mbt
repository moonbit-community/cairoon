///|
struct Device(@device_impl.RawDevice)

///|
fn Device::from_raw(raw : @device_impl.RawDevice) -> Device {
  Device(raw)
}

///|
fn Device::to_raw(self : Device) -> @device_impl.RawDevice {
  self.0
}

///|
fn device_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_device_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn device_type_from_raw(raw : Int) -> DeviceType raise CairoError {
  match raw {
    0 => DeviceTypeDrm
    1 => DeviceTypeGl
    2 => DeviceTypeScript
    3 => DeviceTypeXcb
    4 => DeviceTypeXlib
    5 => DeviceTypeXml
    6 => DeviceTypeCogl
    7 => DeviceTypeWin32
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo device type: \{raw}",
      )
  }
}

///|
fn script_mode_to_raw(mode : ScriptMode) -> Int {
  match mode {
    ScriptModeAscii => 0
    ScriptModeBinary => 1
  }
}

///|
fn script_mode_from_raw(raw : Int) -> ScriptMode raise CairoError {
  match raw {
    0 => ScriptModeAscii
    1 => ScriptModeBinary
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo script mode: \{raw}",
      )
  }
}

///|
pub fn Device::script(path : String) -> Device raise CairoError {
  let status = Ref(0)
  let raw = @device_impl.script_create_path_raw(
    checked_path_bytes(path),
    status,
  )
  check_device_status_raw(status.val)
  check_device_status_raw(@device_impl.status_raw(raw))
  Device::from_raw(raw)
}

///|
pub fn Device::script_stream(
  writer : (Bytes) -> Status,
) -> Device raise CairoError {
  let status = Ref(0)
  let raw = @device_impl.script_create_stream_raw(
    fn(chunk) { writer(chunk).to_raw() },
    status,
  )
  check_device_status_raw(status.val)
  check_device_status_raw(@device_impl.status_raw(raw))
  Device::from_raw(raw)
}

///|
pub fn Device::status(self : Device) -> Status {
  device_status_from_raw(@device_impl.status_raw(self.to_raw()))
}

///|
pub fn Device::equal(self : Device, other : Device) -> Bool {
  @device_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub fn Device::hash(self : Device) -> UInt64 {
  @device_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for Device with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Device with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Device with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub fn Device::get_type(self : Device) -> DeviceType raise CairoError {
  let status = Ref(0)
  let type_ = @device_impl.get_type_raw(self.to_raw(), status)
  check_device_status_raw(status.val)
  device_type_from_raw(type_)
}

///|
pub fn Device::finish(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.finish_raw(self.to_raw()))
}

///|
pub fn[T] Device::with_finished(
  self : Device,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  try f() catch {
    err => {
      self.finish()
      raise err
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
}

///|
pub fn Device::flush(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.flush_raw(self.to_raw()))
}

///|
pub fn Device::acquire(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.acquire_raw(self.to_raw()))
}

///|
pub fn Device::release(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.release_raw(self.to_raw()))
}

///|
pub fn[T] Device::with_acquired(
  self : Device,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  self.acquire()
  try f() catch {
    err => {
      self.release()
      raise err
    }
  } noraise {
    value => {
      self.release()
      value
    }
  }
}

///|
pub fn Device::script_get_mode(self : Device) -> ScriptMode raise CairoError {
  let status = Ref(0)
  let mode = @device_impl.script_get_mode_raw(self.to_raw(), status)
  check_device_status_raw(status.val)
  script_mode_from_raw(mode)
}

///|
pub fn Device::script_set_mode(
  self : Device,
  mode : ScriptMode,
) -> Unit raise CairoError {
  check_device_status_raw(
    @device_impl.script_set_mode_raw(self.to_raw(), script_mode_to_raw(mode)),
  )
}

///|
pub fn Device::script_write_comment(
  self : Device,
  comment : String,
) -> Unit raise CairoError {
  check_device_status_raw(
    @device_impl.script_write_comment_raw(
      self.to_raw(),
      checked_c_string_bytes(comment),
    ),
  )
}

///|
pub fn Device::script_from_recording_surface(
  self : Device,
  surface : Surface,
) -> Unit raise CairoError {
  check_status(script_device_from_recording_surface_ffi(self.to_raw(), surface))
}

///|
pub fn Surface::script(
  device : Device,
  content : Content,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = script_surface_create_ffi(
    device.to_raw(),
    content,
    width,
    height,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::script_raw(
  device : Device,
  content : Int,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = script_surface_create_raw_ffi(
    device.to_raw(),
    checked_content_raw(content),
    width,
    height,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::script_for_target(
  device : Device,
  target : Surface,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = script_surface_create_for_target_ffi(
    device.to_raw(),
    target,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}
