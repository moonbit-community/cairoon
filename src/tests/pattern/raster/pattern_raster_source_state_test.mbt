///|
test "raster source get_acquire returns current callbacks" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let acquired_target_width = Ref(0)
  let acquired_extent_width = Ref(0)
  let released_height = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
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
      let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
      let acquired = acquire(
        target,
        @cairoon.RectangleInt::new(width=1, height=1),
      )
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
fn saved_raster_callbacks_from_local_pattern(
  acquire_calls : Ref[Int],
  release_calls : Ref[Int],
  replacement_calls : Ref[Int],
  target_width : Ref[Int],
  extent_x : Ref[Int],
  released_width : Ref[Int],
) -> (
  ((@cairoon.Surface, @cairoon.RectangleInt) -> @cairoon.Surface)?,
  ((@cairoon.Surface) -> Unit)?,
) raise @cairoon.CairoError {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 1)
  let replacement = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    2,
    1,
  )
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      target_width.val = try! target.get_width()
      extent_x.val = extents.x
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = try! surface.get_width()
    }),
  )
  let saved = pattern.raster_get_callbacks()
  pattern.raster_set_acquire(fn(_, _) {
    replacement_calls.val += 1
    replacement
  })
  pattern.raster_clear_callbacks()
  saved
}

///|
test "saved raster callbacks outlive replacement clear and local scopes" {
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let replacement_calls = Ref(0)
  let target_width = Ref(0)
  let extent_x = Ref(0)
  let released_width = Ref(0)
  let (saved_acquire, saved_release) = saved_raster_callbacks_from_local_pattern(
    acquire_calls, release_calls, replacement_calls, target_width, extent_x, released_width,
  )

  for index in 0..<64 {
    ignore(Bytes::make(32 + index, b'\x5a'))
  }
  match (saved_acquire, saved_release) {
    (Some(acquire), Some(release)) => {
      let target = @cairoon.Surface::image(@cairoon.Argb32, 3, 2)
      let acquired = acquire(
        target,
        @cairoon.RectangleInt::new(x=4, y=5, width=2, height=1),
      )
      inspect(acquired.get_width(), content="2")
      inspect(acquired.get_height(), content="1")
      release(acquired)
    }
    _ => @test.fail("expected saved acquire and release callbacks")
  }
  inspect(acquire_calls.val, content="1")
  inspect(release_calls.val, content="1")
  inspect(replacement_calls.val, content="0")
  inspect(target_width.val, content="3")
  inspect(extent_x.val, content="4")
  inspect(released_width.val, content="2")
}

///|
test "raster source get_acquire reports optional and cleared callbacks" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  inspect(pattern.raster_get_acquire() is None, content="true")

  pattern.raster_set_acquire(fn(_, _) { source })
  match pattern.raster_get_acquire() {
    Some((acquire, None)) => {
      let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
      let acquired = acquire(
        target,
        @cairoon.RectangleInt::new(width=1, height=1),
      )
      inspect(acquired.get_width(), content="1")
    }
    _ => @test.fail("expected acquire callback without release")
  }

  pattern.raster_clear_acquire()
  inspect(pattern.raster_get_acquire() is None, content="true")

  let solid = @cairoon.Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0)
  let result = @cairoon.run_cairo(() => solid.raster_get_acquire())
  match result {
    Err(@cairoon.CairoError(@cairoon.PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "raster source callbacks preserve release only state" {
  let release_calls = Ref(0)
  let release_width = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
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
      let surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 1)
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
