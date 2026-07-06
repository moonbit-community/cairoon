///|
pub fn Surface::ps(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let surface = ps_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::ps_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = ps_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn PSLevel::supported() -> Array[PSLevel] raise CairoError {
  let status = Ref(0)
  let count = @ps_impl.get_level_count_raw(status)
  check_status(status_from_raw(status.val))
  let levels : Array[PSLevel] = Array::new(capacity=count)
  for index in 0..<count {
    let level = ps_level_from_raw(@ps_impl.get_level_raw(index, status))
    check_status(status_from_raw(status.val))
    levels.push(level)
  }
  levels
}

///|
pub fn PSLevel::to_string(self : PSLevel) -> String raise CairoError {
  let status = Ref(0)
  let text = @ps_impl.level_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
pub fn PSLevel::to_string_raw(level : Int) -> String raise CairoError {
  let status = Ref(0)
  let text = @ps_impl.level_to_string_raw(level, status)
  check_status(status_from_raw(status.val))
  text
}

///|
fn PSLevel::to_raw(self : PSLevel) -> Int {
  match self {
    PsLevel2 => 0
    PsLevel3 => 1
  }
}

///|
fn ps_level_from_raw(raw : Int) -> PSLevel raise CairoError {
  match raw {
    0 => PsLevel2
    1 => PsLevel3
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo ps level: \{raw}",
      )
  }
}

///|
pub fn Surface::ps_restrict_to_level(
  self : Surface,
  level : PSLevel,
) -> Unit raise CairoError {
  check_status(ps_surface_restrict_to_level_ffi(self, level))
}

///|
pub fn Surface::ps_restrict_to_level_raw(
  self : Surface,
  level : Int,
) -> Unit raise CairoError {
  check_status(ps_surface_restrict_to_level_raw_ffi(self, level))
}

///|
pub fn Surface::ps_get_eps(self : Surface) -> Bool raise CairoError {
  let status = Ref(Success)
  let eps = ps_surface_get_eps_ffi(self, status)
  check_status(status.val)
  eps
}

///|
pub fn Surface::ps_set_eps(self : Surface, eps : Bool) -> Unit raise CairoError {
  check_status(ps_surface_set_eps_ffi(self, eps))
}

///|
pub fn Surface::ps_set_size(
  self : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Unit raise CairoError {
  check_status(ps_surface_set_size_ffi(self, width_in_points, height_in_points))
}

///|
pub fn Surface::ps_dsc_begin_setup(self : Surface) -> Unit raise CairoError {
  check_status(ps_surface_dsc_begin_setup_ffi(self))
}

///|
pub fn Surface::ps_dsc_begin_page_setup(
  self : Surface,
) -> Unit raise CairoError {
  check_status(ps_surface_dsc_begin_page_setup_ffi(self))
}

///|
pub fn Surface::ps_dsc_comment(
  self : Surface,
  comment : String,
) -> Unit raise CairoError {
  check_status(
    ps_surface_dsc_comment_ffi(self, checked_c_string_bytes(comment)),
  )
}
