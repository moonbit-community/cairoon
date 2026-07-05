///|
pub fn Surface::recording(
  content : Content,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = match extents {
    None =>
      recording_surface_create_ffi(content, false, 0.0, 0.0, 0.0, 0.0, status)
    Some(rect) =>
      recording_surface_create_ffi(
        content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::recording_raw(
  content : Int,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let checked_content = checked_content_raw(content)
  let surface = match extents {
    None =>
      recording_surface_create_raw_ffi(
        checked_content, false, 0.0, 0.0, 0.0, 0.0, status,
      )
    Some(rect) =>
      recording_surface_create_raw_ffi(
        checked_content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::recording_ink_extents(
  self : Surface,
) -> Rectangle raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_status(recording_surface_ink_extents_ffi(self, x0, y0, width, height))
  Rectangle::new(x0.val, y0.val, width.val, height.val)
}

///|
pub fn Surface::recording_get_extents(
  self : Surface,
) -> Rectangle? raise CairoError {
  let has_extents = Ref(0)
  let x = Ref(0.0)
  let y = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_status(
    recording_surface_get_extents_ffi(self, has_extents, x, y, width, height),
  )
  if has_extents.val == 0 {
    None
  } else {
    Some(Rectangle::new(x.val, y.val, width.val, height.val))
  }
}
