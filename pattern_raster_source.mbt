///|
pub fn Pattern::raster_source(
  content : Content,
  width : Int,
  height : Int,
) -> Pattern raise CairoError {
  let pattern = pattern_create_raster_source_ffi(content, width, height)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::raster_set_acquire(
  self : Pattern,
  acquire : (Surface, RectangleInt) -> Surface,
  release? : ((Surface) -> Unit)? = None,
) -> Unit raise CairoError {
  self.raster_set_callbacks(acquire=Some(acquire), release~)
}

///|
pub fn Pattern::raster_set_callbacks(
  self : Pattern,
  acquire? : ((Surface, RectangleInt) -> Surface)? = None,
  release? : ((Surface) -> Unit)? = None,
) -> Unit raise CairoError {
  let call_acquire : FuncRef[
    (Surface, Int, Int, Int, Int, (Surface, RectangleInt) -> Surface) -> Surface,
  ] = fn(
    target : Surface,
    x : Int,
    y : Int,
    width : Int,
    height : Int,
    acquire : (Surface, RectangleInt) -> Surface,
  ) {
    acquire(target, RectangleInt::new(x~, y~, width~, height~))
  }
  match release {
    None =>
      match acquire {
        None => self.raster_clear_acquire()
        Some(acquire) =>
          check_status(
            raster_source_pattern_set_acquire_ffi(self, call_acquire, acquire),
          )
      }
    Some(release) => {
      let call_release : FuncRef[(Surface, (Surface) -> Unit) -> Unit] = fn(
        surface : Surface,
        release : (Surface) -> Unit,
      ) {
        release(surface)
      }
      match acquire {
        None =>
          check_status(
            raster_source_pattern_set_release_ffi(self, call_release, release),
          )
        Some(acquire) =>
          check_status(
            raster_source_pattern_set_acquire_with_release_ffi(
              self, call_acquire, acquire, call_release, release,
            ),
          )
      }
    }
  }
}

///|
pub fn Pattern::raster_get_callbacks(
  self : Pattern,
) -> (((Surface, RectangleInt) -> Surface)?, ((Surface) -> Unit)?) raise CairoError {
  let has_acquire = Ref(0)
  let has_release = Ref(0)
  let status = Ref(Success)
  let _ = raster_source_pattern_has_callbacks_ffi(
    self, has_acquire, has_release, status,
  )
  check_status(status.val)
  let acquire = if has_acquire.val == 0 {
    None
  } else {
    let acquire_status = Ref(Success)
    let acquire = raster_source_pattern_get_acquire_callback_ffi(
      self, acquire_status,
    )
    check_status(acquire_status.val)
    Some(acquire)
  }
  let release = if has_release.val == 0 {
    None
  } else {
    let release_status = Ref(Success)
    let release = raster_source_pattern_get_release_callback_ffi(
      self, release_status,
    )
    check_status(release_status.val)
    Some(release)
  }
  (acquire, release)
}

///|
pub fn Pattern::raster_clear_callbacks(self : Pattern) -> Unit raise CairoError {
  self.raster_clear_acquire()
}

///|
pub fn Pattern::raster_clear_acquire(self : Pattern) -> Unit raise CairoError {
  check_status(raster_source_pattern_clear_acquire_ffi(self))
}

///|
pub fn Pattern::raster_get_acquire(
  self : Pattern,
) -> ((Surface, RectangleInt) -> Surface, ((Surface) -> Unit)?)? raise CairoError {
  let (acquire, release) = self.raster_get_callbacks()
  match acquire {
    None => None
    Some(acquire) => Some((acquire, release))
  }
}
