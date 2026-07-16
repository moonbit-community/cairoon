///|
/// An owning facade for a Cairo rendering device.
///
/// A `Device` has pointer identity and holds one internal `RawDevice` owner.
/// The raw owner's finalizer calls `cairo_device_destroy`; this facade adds no
/// second finalizer. Devices obtained independently for the same native object
/// compare equal and may outlive the surface from which they were obtained.
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
/// Create a script device that writes Cairo's replayable script to `path`.
///
/// The returned device owns the native handle. Call `finish()` to complete the
/// output deterministically; eventual finalization also destroys the handle.
/// `path` is UTF-8 and an embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. A missing script backend or file
/// creation failure raises the corresponding checked Cairo status.
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
/// Create a script device that sends output chunks to `writer`.
///
/// Cairoon retains the closure until the native device is destroyed. Each
/// callback receives a fresh MoonBit-owned `Bytes` copy, so it may safely keep
/// the chunk after returning. The writer must return `Success`; a valid error
/// status is reported by the Cairo operation that emits it, while `LastStatus`
/// or any out-of-range callback result is normalized to `WriteError`. Call
/// `finish()` to force all buffered output through the callback.
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
/// Return the device's current sticky Cairo status without raising.
///
/// `Success` means no device error has been recorded. Once Cairo records an
/// error, later status queries normally return the same value. An unknown raw
/// status from the native boundary is represented as `InvalidStatus`.
pub fn Device::status(self : Device) -> Status {
  device_status_from_raw(@device_impl.status_raw(self.to_raw()))
}

///|
/// Test whether two wrappers refer to the same native Cairo device.
///
/// This is pointer identity, not structural or output-content equality. It is
/// consistent with the `Eq` implementation and with `hash()`.
pub fn Device::equal(self : Device, other : Device) -> Bool {
  @device_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return a stable identity hash for this native device.
///
/// Wrappers that compare equal produce the same hash. The value identifies the
/// native pointer only for its lifetime and must not be persisted as a resource
/// identifier.
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
/// Return the backend type of this device.
///
/// Script constructors return `DeviceTypeScript`; devices obtained from other
/// surfaces may report another supported backend. A device error is raised
/// through `CairoError`, and an unknown future raw type raises
/// `CairoInvalidArgument(InvalidStatus, _)` rather than being guessed.
pub fn Device::get_type(self : Device) -> DeviceType raise CairoError {
  let status = Ref(0)
  let type_ = @device_impl.get_type_raw(self.to_raw(), status)
  check_device_status_raw(status.val)
  device_type_from_raw(type_)
}

///|
/// Finish the device and release all external resources it controls.
///
/// Cairo also finishes surfaces, fonts, and other objects created for this
/// device. Later operations have no effect and can report `DeviceFinished`.
/// The wrapper remains owned and its finalizer will still destroy the native
/// reference. Cairoon always attempts the native finish even after a sticky
/// device error, then raises the resulting checked status. This call may
/// acquire the device and must not be made while it is manually acquired.
pub fn Device::finish(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.finish_raw(self.to_raw()))
}

///|
/// Run `f`, then finish this device on both success and error paths.
///
/// If `f` succeeds, a finish failure is raised and otherwise its value is
/// returned. If `f` raises, cairoon still attempts the native finish but
/// preserves and re-raises the original closure error even when cleanup also
/// reports a sticky status. This is the deterministic-output counterpart to a
/// pycairo device context manager.
pub fn[T] Device::with_finished(
  self : Device,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  try f() catch {
    err => {
      let _ = @device_impl.finish_raw(self.to_raw())
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
/// Complete pending Cairo work and restore the underlying device state.
///
/// Call this before switching from Cairo rendering to direct backend-native
/// access; it is a no-op for devices without such access. Failures raise the
/// checked device status. Cairo may acquire the device internally, so do not
/// call this while holding a manual acquisition.
pub fn Device::flush(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.flush_raw(self.to_raw()))
}

///|
/// Acquire exclusive access to the device for the current thread.
///
/// The call blocks while another thread owns the device. Recursive acquisition
/// by the same thread is allowed, but every successful call requires exactly
/// one matching `release()`. Do not hold two different devices unless their
/// backends explicitly permit it, and do not call Cairo operations that may
/// acquire a device while this lock is held. Acquisition failures raise their
/// checked Cairo status.
pub fn Device::acquire(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.acquire_raw(self.to_raw()))
}

///|
/// Release one successful acquisition made by the current thread.
///
/// Calling this without a matching `acquire()` violates Cairo's contract.
/// Cairoon invokes the native release even when the device has a sticky error,
/// so lock cleanup cannot be skipped, and then raises that current status if it
/// is not `Success`.
pub fn Device::release(self : Device) -> Unit raise CairoError {
  check_device_status_raw(@device_impl.release_raw(self.to_raw()))
}

///|
/// Run `f` while this thread owns the device, then release it exactly once.
///
/// Acquisition failure prevents `f` from running. On success, a release error
/// is reported normally. If `f` raises, cairoon still performs a best-effort
/// raw release and re-raises the original closure error, even if the device is
/// already in a sticky error state. The closure must obey `acquire()`'s
/// deadlock restrictions and avoid Cairo calls that may acquire devices.
pub fn[T] Device::with_acquired(
  self : Device,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  self.acquire()
  try f() catch {
    err => {
      let _ = @device_impl.release_raw(self.to_raw())
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
/// Return the current output mode of a script device.
///
/// Newly created script devices default to `ScriptModeAscii`. Calling this on
/// another backend raises `CairoError(DeviceTypeMismatch, _)`; other device
/// failures are mapped through the checked status hierarchy.
pub fn Device::script_get_mode(self : Device) -> ScriptMode raise CairoError {
  let status = Ref(0)
  let mode = @device_impl.script_get_mode_raw(self.to_raw(), status)
  check_device_status_raw(status.val)
  script_mode_from_raw(mode)
}

///|
/// Select readable ASCII or byte-coded binary output for a script device.
///
/// The mode affects subsequently emitted script data. A non-script device
/// raises `CairoError(DeviceTypeMismatch, _)`, and output failures raise their
/// checked device status.
pub fn Device::script_set_mode(
  self : Device,
  mode : ScriptMode,
) -> Unit raise CairoError {
  check_device_status_raw(
    @device_impl.script_set_mode_raw(self.to_raw(), script_mode_to_raw(mode)),
  )
}

///|
/// Emit `comment` verbatim into a script device's output.
///
/// The MoonBit string is encoded as UTF-8. Embedded NUL bytes raise
/// `CairoInvalidArgument(InvalidString, _)` before the FFI call. Use `flush()`
/// or `finish()` when the comment must already be visible to a file or stream.
/// A non-script device raises `CairoError(DeviceTypeMismatch, _)`.
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
/// Convert all recorded operations in `surface` into this device's script.
///
/// `surface` must have `SurfaceTypeRecording`; another valid surface raises
/// `CairoError(SurfaceTypeMismatch, _)`. Both arguments are borrowed only for
/// this synchronous replay. Device, surface, stream, and allocation failures
/// use the normal checked `CairoError` mapping.
pub fn Device::script_from_recording_surface(
  self : Device,
  surface : Surface,
) -> Unit raise CairoError {
  check_device_status_raw(
    @device_impl.script_from_recording_surface_raw(
      self.to_raw(),
      surface.to_raw(),
    ),
  )
}

///|
/// Create a surface whose rendering commands are emitted through `device`.
///
/// `device` must be a script device. `content` selects the typed color/alpha
/// channels and `width`/`height` are measured in pixels. The returned `Surface`
/// owns its native reference; Cairo retains the native device relationship it
/// needs, so the MoonBit `Device` wrapper may leave scope independently.
/// Constructor and object-status failures are raised as `CairoError`.
pub fn Surface::script(
  device : Device,
  content : Content,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @device_impl.script_surface_create_raw(
    device.to_raw(),
    content.to_raw(),
    width,
    height,
    status,
  )
  check_device_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a script surface from a pycairo-compatible raw content integer.
///
/// Prefer `Surface::script()` for typed code. Only Cairo's color, alpha, and
/// color-alpha content values are accepted; another integer raises
/// `CairoInvalidArgument(InvalidContent, _)` before native construction.
/// Ownership, dimensions, backend checks, and error behavior otherwise match
/// `Surface::script()`.
pub fn Surface::script_raw(
  device : Device,
  content : Int,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @device_impl.script_surface_create_raw(
    device.to_raw(),
    checked_content_raw(content),
    width,
    height,
    status,
  )
  check_device_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create a proxy that renders to `target` and records the same operations.
///
/// Drawing through the returned surface is forwarded to `target` while the
/// script device records it for replay. Cairo retains the native target and
/// device references needed by the proxy; the MoonBit wrappers may therefore
/// leave scope independently. A non-script device, an errored target, or a
/// constructor failure raises the corresponding checked `CairoError`.
pub fn Surface::script_for_target(
  device : Device,
  target : Surface,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @device_impl.script_surface_create_for_target_raw(
    device.to_raw(),
    target.to_raw(),
    status,
  )
  check_device_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}
