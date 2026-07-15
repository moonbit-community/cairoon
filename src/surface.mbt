///|
struct Surface(@surface_impl.RawSurface)

///|
fn Surface::from_raw(raw : @surface_impl.RawSurface) -> Surface {
  Surface(raw)
}

///|
fn Surface::to_raw(self : Surface) -> @surface_impl.RawSurface {
  self.0
}

///|
fn surface_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_surface_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn surface_type_from_raw(raw : Int) -> SurfaceType raise CairoError {
  match raw {
    0 => SurfaceTypeImage
    1 => SurfaceTypePdf
    2 => SurfaceTypePs
    3 => SurfaceTypeXlib
    4 => SurfaceTypeXcb
    5 => SurfaceTypeGlitz
    6 => SurfaceTypeQuartz
    7 => SurfaceTypeWin32
    8 => SurfaceTypeBeos
    9 => SurfaceTypeDirectfb
    10 => SurfaceTypeSvg
    11 => SurfaceTypeOs2
    12 => SurfaceTypeWin32Printing
    13 => SurfaceTypeQuartzImage
    14 => SurfaceTypeScript
    15 => SurfaceTypeQt
    16 => SurfaceTypeRecording
    17 => SurfaceTypeVg
    18 => SurfaceTypeGl
    19 => SurfaceTypeDrm
    20 => SurfaceTypeTee
    21 => SurfaceTypeXml
    22 => SurfaceTypeSkia
    23 => SurfaceTypeSubsurface
    24 => SurfaceTypeCogl
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo surface type: \{raw}",
      )
  }
}

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
  let status = Ref(0)
  let raw = @surface_impl.create_similar_raw(
    self.to_raw(),
    content.to_raw(),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::create_similar_raw(
  self : Surface,
  content : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_raw(
    self.to_raw(),
    checked_content_raw(content),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::create_similar_image(
  self : Surface,
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_image_raw(
    self.to_raw(),
    format.to_raw(),
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::create_similar_image_raw(
  self : Surface,
  format : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_similar_image_raw(
    self.to_raw(),
    format,
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::create_for_rectangle(
  self : Surface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.create_for_rectangle_raw(
    self.to_raw(),
    x,
    y,
    width,
    height,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::status(self : Surface) -> Status {
  surface_status_from_raw(@surface_impl.status_raw(self.to_raw()))
}

///|
pub fn Surface::equal(self : Surface, other : Surface) -> Bool {
  @surface_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub fn Surface::hash(self : Surface) -> UInt64 {
  @surface_impl.hash_raw(self.to_raw())
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
fn Content::to_raw(self : Content) -> Int {
  match self {
    ContentColor => 0x1000
    ContentAlpha => 0x2000
    ContentColorAlpha => 0x3000
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
  check_surface_status_raw(@surface_impl.status_raw(self.to_raw()))
  @surface_impl.get_content_raw(self.to_raw())
}

///|
pub fn Surface::get_type(self : Surface) -> SurfaceType raise CairoError {
  check_surface_status_raw(@surface_impl.status_raw(self.to_raw()))
  surface_type_from_raw(@surface_impl.get_type_raw(self.to_raw()))
}

///|
pub fn Surface::get_device(self : Surface) -> Device? raise CairoError {
  let has_device = Ref(0)
  let status = Ref(0)
  let device = @device_impl.surface_get_device_raw(
    self.to_raw(),
    has_device,
    status,
  )
  check_device_status_raw(status.val)
  if has_device.val == 0 {
    None
  } else {
    check_device_status_raw(@device_impl.status_raw(device))
    Some(Device::from_raw(device))
  }
}

///|
pub fn Surface::finish(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.finish_raw(self.to_raw()))
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
