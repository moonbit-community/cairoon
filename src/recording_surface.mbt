///|
pub fn Surface::recording(
  content : Content,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw_content = content.to_raw()
  let raw = match extents {
    None =>
      @surface_impl.recording_create_raw(
        raw_content, false, 0.0, 0.0, 0.0, 0.0, status,
      )
    Some(rect) =>
      @surface_impl.recording_create_raw(
        raw_content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::recording_raw(
  content : Int,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let checked_content = checked_content_raw(content)
  let raw = match extents {
    None =>
      @surface_impl.recording_create_raw(
        checked_content, false, 0.0, 0.0, 0.0, 0.0, status,
      )
    Some(rect) =>
      @surface_impl.recording_create_raw(
        checked_content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::recording_ink_extents(
  self : Surface,
) -> Rectangle raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.recording_ink_extents_raw(
      self.to_raw(),
      x0,
      y0,
      width,
      height,
    ),
  )
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
  check_surface_status_raw(
    @surface_impl.recording_get_extents_raw(
      self.to_raw(),
      has_extents,
      x,
      y,
      width,
      height,
    ),
  )
  if has_extents.val == 0 {
    None
  } else {
    Some(Rectangle::new(x.val, y.val, width.val, height.val))
  }
}
