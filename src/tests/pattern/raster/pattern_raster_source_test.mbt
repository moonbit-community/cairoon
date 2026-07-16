///|
fn[T] expect_raster_source_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
test "raster source pattern accepts pycairo raw content ints" {
  let pattern = @cairoon.Pattern::raster_source_raw(0x3000, 1, 1)
  debug_inspect(pattern.status(), content="Success")

  expect_raster_source_invalid_content(
    @cairoon.run_cairo(() => @cairoon.Pattern::raster_source_raw(0, 1, 1)),
  )
}

///|
test "raster source pattern paints from acquire callback" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let target_width = Ref(0)
  let released_width = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      extent_width.val = extents.width
      target_width.val = try! target.get_width()
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = try! surface.get_width()
    }),
  )

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  target.flush()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val == acquire_calls.val, content="true")
  inspect(extent_width.val > 0, content="true")
  inspect(target_width.val, content="1")
  inspect(released_width.val, content="1")
}

///|
test "raster source release callback can clear its registration" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  pattern.raster_set_acquire(
    fn(_, _) {
      acquire_calls.val += 1
      source
    },
    release=Some(fn(_) {
      release_calls.val += 1
      try! pattern.raster_clear_callbacks()
    }),
  )

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()

  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val, content="1")
  let (acquire, release) = pattern.raster_get_callbacks()
  inspect(acquire is None, content="true")
  inspect(release is None, content="true")
}

///|
test "raster source acquire can draw into compatible extents surface" {
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let extent_height = Ref(0)
  let target_width = Ref(0)
  let released_width = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(@cairoon.ContentColor, 2, 2)
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      extent_width.val = extents.width
      extent_height.val = extents.height
      target_width.val = try! target.get_width()
      let source = try! target.create_similar_image(
        @cairoon.Argb32,
        extents.width,
        extents.height,
      )
      try! source.set_device_offset(
        extents.x.to_double(),
        extents.y.to_double(),
      )
      let source_ctx = try! @cairoon.Context::new(source)
      try! source_ctx.set_source_rgb(1.0, 0.0, 0.0)
      try! source_ctx.paint()
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = try! surface.get_width()
    }),
  )

  let target = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  target.flush()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val == acquire_calls.val, content="true")
  inspect(extent_width.val > 0, content="true")
  inspect(extent_height.val > 0, content="true")
  inspect(target_width.val, content="10")
  inspect(released_width.val > 0, content="true")
}

///|
test "raster source acquire rejects finished surfaces" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  source.finish()
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  pattern.raster_set_acquire(
    fn(_, _) {
      acquire_calls.val += 1
      source
    },
    release=Some(fn(_) { release_calls.val += 1 }),
  )

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  let result = @cairoon.run_cairo(() => ctx.paint())
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val, content="0")
  match result {
    Err(@cairoon.CairoMemoryError(@cairoon.NoMemory, _)) => ()
    _ => @test.fail("expected NoMemory when raster acquire returns no surface")
  }
}

///|
test "raster source acquire replacement recovers after failed surface" {
  let failed_source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  failed_source.finish()

  let recovered_source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let recovered_ctx = @cairoon.Context::new(recovered_source)
  recovered_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  recovered_ctx.paint()

  let failed_acquire_calls = Ref(0)
  let recovered_acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let released_width = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  pattern.raster_set_acquire(
    fn(_, _) {
      failed_acquire_calls.val += 1
      failed_source
    },
    release=Some(fn(_) { release_calls.val += 1 }),
  )

  let failed_target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let failed_ctx = @cairoon.Context::new(failed_target)
  failed_ctx.set_source(pattern)
  let failed_result = @cairoon.run_cairo(() => failed_ctx.paint())
  inspect(failed_acquire_calls.val > 0, content="true")
  inspect(release_calls.val, content="0")
  match failed_result {
    Err(@cairoon.CairoMemoryError(@cairoon.NoMemory, _)) => ()
    _ => @test.fail("expected NoMemory before acquire replacement")
  }

  pattern.raster_set_acquire(
    fn(_, _) {
      recovered_acquire_calls.val += 1
      recovered_source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = try! surface.get_width()
    }),
  )

  let recovered_target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(recovered_target)
  ctx.set_source(pattern)
  ctx.paint()
  recovered_target.flush()

  let data = recovered_target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
  inspect(recovered_acquire_calls.val > 0, content="true")
  inspect(release_calls.val == recovered_acquire_calls.val, content="true")
  inspect(released_width.val, content="1")
}

///|
fn make_data_backed_raster_source_pattern() -> @cairoon.Pattern raise @cairoon.CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = @cairoon.Surface::image_for_data(data, @cairoon.Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  pattern.raster_set_acquire(fn(_, _) { source })
  pattern
}

///|
test "raster source pattern retains data backed acquire surface" {
  let pattern = make_data_backed_raster_source_pattern()
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "raster source acquire validates pattern subtype" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let solid = @cairoon.Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let set_result = @cairoon.run_cairo(() => {
    solid.raster_set_acquire(fn(_, _) { source })
  })
  match set_result {
    Err(@cairoon.CairoError(@cairoon.PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let clear_result = @cairoon.run_cairo(() => solid.raster_clear_acquire())
  match clear_result {
    Err(@cairoon.CairoError(@cairoon.PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let release_only_result = @cairoon.run_cairo(() => {
    solid.raster_set_callbacks(release=Some(fn(_) { () }))
  })
  match release_only_result {
    Err(@cairoon.CairoError(@cairoon.PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let callbacks_result = @cairoon.run_cairo(() => {
    let _ = solid.raster_get_callbacks()
    ()
  })
  match callbacks_result {
    Err(@cairoon.CairoError(@cairoon.PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}
