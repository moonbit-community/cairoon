///|
test "raster source get_acquire returns current callbacks" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let acquired_target_width = Ref(0)
  let acquired_extent_width = Ref(0)
  let released_height = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      acquired_target_width.val = try! target.get_width()
      acquired_extent_width.val = extents.width
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_height.val = try! surface.get_height()
    }),
  )

  match pattern.raster_get_acquire() {
    Some((acquire, Some(release))) => {
      let target = Surface::image(Argb32, 1, 1)
      let acquired = acquire(target, RectangleInt::new(width=1, height=1))
      release(acquired)
      inspect(acquire_calls.val, content="1")
      inspect(release_calls.val, content="1")
      inspect(acquired_target_width.val, content="1")
      inspect(acquired_extent_width.val, content="1")
      inspect(released_height.val, content="1")
    }
    _ => @test.fail("expected acquire and release callbacks")
  }
}

///|
test "raster source get_acquire reports optional and cleared callbacks" {
  let source = Surface::image(Argb32, 1, 1)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  inspect(pattern.raster_get_acquire() is None, content="true")

  pattern.raster_set_acquire(fn(_, _) { source })
  match pattern.raster_get_acquire() {
    Some((acquire, None)) => {
      let target = Surface::image(Argb32, 1, 1)
      let acquired = acquire(target, RectangleInt::new(width=1, height=1))
      inspect(acquired.get_width(), content="1")
    }
    _ => @test.fail("expected acquire callback without release")
  }

  pattern.raster_clear_acquire()
  inspect(pattern.raster_get_acquire() is None, content="true")

  let solid = Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0)
  let result = run_cairo(() => solid.raster_get_acquire())
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "raster source callbacks preserve release only state" {
  let release_calls = Ref(0)
  let release_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_callbacks(
    release=Some(fn(surface) {
      release_calls.val += 1
      release_width.val = try! surface.get_width()
    }),
  )

  let (acquire, release) = pattern.raster_get_callbacks()
  inspect(acquire is None, content="true")
  inspect(pattern.raster_get_acquire() is None, content="true")
  match release {
    Some(release) => {
      let surface = Surface::image(Argb32, 2, 1)
      release(surface)
      inspect(release_calls.val, content="1")
      inspect(release_width.val, content="2")
    }
    None => @test.fail("expected release callback")
  }

  pattern.raster_clear_callbacks()
  let (cleared_acquire, cleared_release) = pattern.raster_get_callbacks()
  inspect(cleared_acquire is None, content="true")
  inspect(cleared_release is None, content="true")
}
