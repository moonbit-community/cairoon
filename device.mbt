///|
pub fn Device::script(path : String) -> Device raise CairoError {
  let status = Ref(Success)
  let device = script_device_create_ffi(checked_path_bytes(path), status)
  check_status(status.val)
  check_status(device_status_ffi(device))
  device
}

///|
pub fn Device::script_stream(
  writer : (Bytes) -> Status,
) -> Device raise CairoError {
  let status = Ref(Success)
  let device = script_device_create_for_stream_ffi(
    fn(chunk, writer) { writer(copy_stream_chunk(chunk)) },
    writer,
    status,
  )
  check_status(status.val)
  check_status(device_status_ffi(device))
  device
}

///|
pub fn Device::status(self : Device) -> Status {
  device_status_ffi(self)
}

///|
pub fn Device::equal(self : Device, other : Device) -> Bool {
  device_equal_ffi(self, other)
}

///|
pub fn Device::hash(self : Device) -> UInt64 {
  device_hash_ffi(self)
}

///|
pub fn Device::get_type(self : Device) -> DeviceType raise CairoError {
  let status = Ref(Success)
  let type_ = device_get_type_ffi(self, status)
  check_status(status.val)
  type_
}

///|
pub fn Device::finish(self : Device) -> Unit raise CairoError {
  check_status(device_finish_ffi(self))
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
  check_status(device_flush_ffi(self))
}

///|
pub fn Device::acquire(self : Device) -> Unit raise CairoError {
  check_status(device_acquire_ffi(self))
}

///|
pub fn Device::release(self : Device) -> Unit raise CairoError {
  check_status(device_release_ffi(self))
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
  let status = Ref(Success)
  let mode = script_device_get_mode_ffi(self, status)
  check_status(status.val)
  mode
}

///|
pub fn Device::script_set_mode(
  self : Device,
  mode : ScriptMode,
) -> Unit raise CairoError {
  check_status(script_device_set_mode_ffi(self, mode))
}

///|
pub fn Device::script_write_comment(
  self : Device,
  comment : String,
) -> Unit raise CairoError {
  check_status(
    script_device_write_comment_ffi(self, checked_c_string_bytes(comment)),
  )
}

///|
pub fn Device::script_from_recording_surface(
  self : Device,
  surface : Surface,
) -> Unit raise CairoError {
  check_status(script_device_from_recording_surface_ffi(self, surface))
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
    device, content, width, height, status,
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
  let surface = script_surface_create_for_target_ffi(device, target, status)
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}
