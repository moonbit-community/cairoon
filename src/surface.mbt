///|
fn checked_c_string_bytes(value : String) -> Bytes raise CairoError {
  let bytes = @utf8.encode(value)
  check_no_embedded_nul(bytes)
  bytes
}

///|
fn checked_path_bytes(path : String) -> Bytes raise CairoError {
  checked_c_string_bytes(path)
}

///|
pub fn Surface::create_similar(
  self : Surface,
  content : Content,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_ffi(self, content, width, height, status)
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::create_similar_raw(
  self : Surface,
  content : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_raw_ffi(
    self,
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
pub fn Surface::create_similar_image(
  self : Surface,
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_image_ffi(
    self, format, width, height, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::create_similar_image_raw(
  self : Surface,
  format : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_image_raw_ffi(
    self, format, width, height, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::create_for_rectangle(
  self : Surface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_for_rectangle_ffi(
    self, x, y, width, height, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::status(self : Surface) -> Status {
  surface_status_ffi(self)
}

///|
pub fn Surface::equal(self : Surface, other : Surface) -> Bool {
  surface_equal_ffi(self, other)
}

///|
pub fn Surface::hash(self : Surface) -> UInt64 {
  surface_hash_ffi(self)
}

///|
pub impl Eq for Surface with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Surface with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Surface with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
fn content_from_raw(raw : Int) -> Content raise CairoError {
  match raw {
    0x1000 => ContentColor
    0x2000 => ContentAlpha
    0x3000 => ContentColorAlpha
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo content: \{raw}")
  }
}

///|
fn checked_content_raw(raw : Int) -> Int raise CairoError {
  match raw {
    0x1000 | 0x2000 | 0x3000 => raw
    _ => raise CairoInvalidArgument(InvalidContent, InvalidContent.message())
  }
}

///|
pub fn Surface::get_content(self : Surface) -> Content raise CairoError {
  content_from_raw(self.get_content_raw())
}

///|
pub fn Surface::get_content_raw(self : Surface) -> Int raise CairoError {
  check_status(surface_status_ffi(self))
  surface_get_content_raw_ffi(self)
}

///|
pub fn Surface::get_type(self : Surface) -> SurfaceType raise CairoError {
  check_status(surface_status_ffi(self))
  surface_get_type_ffi(self)
}

///|
pub fn Surface::get_device(self : Surface) -> Device? raise CairoError {
  let has_device = Ref(0)
  let status = Ref(Success)
  let device = surface_get_device_ffi(self, has_device, status)
  check_status(status.val)
  if has_device.val == 0 {
    None
  } else {
    check_status(device_status_ffi(device))
    Some(device)
  }
}

///|
pub fn Surface::finish(self : Surface) -> Unit raise CairoError {
  check_status(surface_finish_ffi(self))
}

///|
pub fn[T] Surface::with_finished(
  self : Surface,
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
