///|
test "solid pattern exposes rgba" {
  let rgb_pattern = Pattern::solid_rgb(0.125, 0.25, 0.5)
  let (_, _, _, opaque_alpha) = rgb_pattern.get_rgba()
  inspect(opaque_alpha, content="1")

  let pattern = Pattern::solid_rgba(0.125, 0.25, 0.5, 0.75)
  let (red, green, blue, alpha) = pattern.get_rgba()
  inspect(red, content="0.125")
  inspect(green, content="0.25")
  inspect(blue, content="0.5")
  inspect(alpha, content="0.75")
}

///|
test "pattern equality and hash use cairo pointer identity" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  let pattern = ctx.get_source()
  let same = ctx.get_source()
  inspect(pattern.equal(same), content="true")
  inspect(pattern.hash() == same.hash(), content="true")

  let other = Pattern::solid_rgb(0.0, 0.0, 0.0)
  inspect(pattern.equal(other), content="false")
  inspect(other.hash() == 0UL, content="false")
}

///|
test "pattern extend filter and matrix mirror cairo state" {
  let pattern = Pattern::solid_rgb(1.0, 0.0, 0.0)
  debug_inspect(pattern.get_extend(), content="Pad")
  debug_inspect(pattern.get_filter(), content="Good")
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  pattern.set_dither(DitherBest)
  let matrix = Matrix::new(xx=0.5, yy=0.25, x0=3.0, y0=5.0)
  pattern.set_matrix(matrix)
  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  debug_inspect(pattern.get_dither(), content="DitherBest")
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 0.5, yx: 0, xy: 0, yy: 0.25, x0: 3, y0: 5 }",
  )
}

///|
test "context can paint from explicit solid pattern" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  let pattern = Pattern::solid_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn make_red_surface_pattern() -> Pattern raise CairoError {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  Pattern::for_surface(source)
}

///|
test "surface pattern paints after source scope exits" {
  let pattern = make_red_surface_pattern()
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "surface pattern get_surface returns referenced surface wrapper" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  let returned = pattern.get_surface()
  inspect(returned.get_width(), content="1")
  inspect(returned.get_height(), content="1")
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn make_returned_surface_from_pattern() -> Surface raise CairoError {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  pattern.get_surface()
}

///|
fn make_returned_data_surface_from_pattern() -> Surface raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  pattern.get_surface()
}

///|
test "surface pattern get_surface survives source and pattern scopes" {
  let returned = make_returned_surface_from_pattern()
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "surface pattern get_surface keeps data-backed surface alive" {
  let returned = make_returned_data_surface_from_pattern()
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "non-surface pattern get_surface maps type mismatch status" {
  let solid = Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let result = run_cairo(() => {
    let _ = solid.get_surface()
    ()
  })
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "surface pattern get_rgba maps type mismatch status" {
  let pattern = make_red_surface_pattern()
  let result = run_cairo(() => pattern.get_rgba())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "raster source pattern paints from acquire callback" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let target_width = Ref(0)
  let released_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
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

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
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
test "raster source acquire can draw into compatible extents surface" {
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let extent_height = Ref(0)
  let target_width = Ref(0)
  let released_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColor, 2, 2)
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      extent_width.val = extents.width
      extent_height.val = extents.height
      target_width.val = try! target.get_width()
      let source = try! target.create_similar_image(
        Argb32,
        extents.width,
        extents.height,
      )
      try! source.set_device_offset(
        extents.x.to_double(),
        extents.y.to_double(),
      )
      let source_ctx = try! Context::new(source)
      try! source_ctx.set_source_rgb(1.0, 0.0, 0.0)
      try! source_ctx.paint()
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = try! surface.get_width()
    }),
  )

  let target = Surface::image(Argb32, 10, 10)
  let ctx = Context::new(target)
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
  let source = Surface::image(Argb32, 1, 1)
  source.finish()
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(
    fn(_, _) {
      acquire_calls.val += 1
      source
    },
    release=Some(fn(_) { release_calls.val += 1 }),
  )

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  let result = run_cairo(() => ctx.paint())
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val, content="0")
  match result {
    Err(CairoMemoryError(NoMemory, _)) => ()
    _ => @test.fail("expected NoMemory when raster acquire returns no surface")
  }
}

///|
test "raster source acquire replacement recovers after failed surface" {
  let failed_source = Surface::image(Argb32, 1, 1)
  failed_source.finish()

  let recovered_source = Surface::image(Argb32, 1, 1)
  let recovered_ctx = Context::new(recovered_source)
  recovered_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  recovered_ctx.paint()

  let failed_acquire_calls = Ref(0)
  let recovered_acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let released_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(
    fn(_, _) {
      failed_acquire_calls.val += 1
      failed_source
    },
    release=Some(fn(_) { release_calls.val += 1 }),
  )

  let failed_target = Surface::image(Argb32, 1, 1)
  let failed_ctx = Context::new(failed_target)
  failed_ctx.set_source(pattern)
  let failed_result = run_cairo(() => failed_ctx.paint())
  inspect(failed_acquire_calls.val > 0, content="true")
  inspect(release_calls.val, content="0")
  match failed_result {
    Err(CairoMemoryError(NoMemory, _)) => ()
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

  let recovered_target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(recovered_target)
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
fn paint_pattern_color(ctx : Context, color : Int) -> Unit raise CairoError {
  match color {
    0 => ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    1 => ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
    _ => ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  }
  ctx.paint()
}

///|
fn make_pattern_color_surface(
  color : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let surface = Surface::image(Argb32, width, height)
  paint_pattern_color(Context::new(surface), color)
  surface
}

///|
fn expect_pattern_first_pixel(bytes : Bytes, color : Int) -> Unit raise {
  let expected = match color {
    0 => [0, 0, 255, 255]
    1 => [0, 255, 0, 255]
    _ => [255, 0, 0, 255]
  }
  for index in 0..<expected.length() {
    inspect(bytes[index].to_int(), content="\{expected[index]}")
  }
}

///|
test "raster source deterministic callback fuzz recovers after replacements" {
  let static_red = make_pattern_color_surface(0, 3, 3)
  let static_green = make_pattern_color_surface(1, 3, 3)
  let static_blue = make_pattern_color_surface(2, 3, 3)
  let failed_source = Surface::image(Argb32, 1, 1)
  failed_source.finish()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let failed_paints = Ref(0)
  let manual_acquires = Ref(0)
  let release_only_installs = Ref(0)
  let last_extent_width = Ref(0)
  let last_target_width = Ref(0)
  let last_release_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 3, 3)

  for step in 0..<25 {
    if step % 6 == 0 {
      pattern.raster_set_callbacks(
        release=Some(fn(surface) {
          last_release_width.val = try! surface.get_width()
        }),
      )
      let (release_only_acquire, release_only_release) = pattern.raster_get_callbacks()
      guard release_only_acquire is None && release_only_release is Some(_) else {
        @test.fail("expected temporary release-only raster callbacks")
      }
      release_only_installs.val += 1
    }

    if step % 8 == 0 {
      pattern.raster_clear_callbacks()
      guard pattern.raster_get_acquire() is None else {
        @test.fail("expected raster callbacks to be cleared")
      }
    }

    let should_fail = step % 5 == 0
    let color = step % 3
    let static_source = match color {
      0 => static_red
      1 => static_green
      _ => static_blue
    }
    pattern.raster_set_acquire(
      fn(target, extents) {
        acquire_calls.val += 1
        last_extent_width.val = extents.width
        last_target_width.val = try! target.get_width()
        if should_fail {
          failed_source
        } else if step % 4 == 2 {
          let source = try! target.create_similar_image(
            Argb32,
            extents.width,
            extents.height,
          )
          try! source.set_device_offset(
            extents.x.to_double(),
            extents.y.to_double(),
          )
          try! paint_pattern_color(Context::new(source), color)
          source
        } else {
          static_source
        }
      },
      release=Some(fn(surface) {
        release_calls.val += 1
        last_release_width.val = try! surface.get_width()
      }),
    )

    if !should_fail && step % 4 == 1 {
      match pattern.raster_get_acquire() {
        Some((acquire, Some(release))) => {
          let target = Surface::image(Argb32, 2, 2)
          let acquired = acquire(target, RectangleInt::new(width=2, height=2))
          release(acquired)
          manual_acquires.val += 1
        }
        _ => @test.fail("expected acquire and release callbacks after set")
      }
    }

    let target_width = 1 + step % 3
    let target_height = 1 + step / 3 % 3
    let target = Surface::image(Argb32, target_width, target_height)
    let ctx = Context::new(target)
    let result = run_cairo(() => {
      ctx.set_source(pattern)
      ctx.paint()
    })
    if should_fail {
      match result {
        Err(CairoMemoryError(NoMemory, _)) => failed_paints.val += 1
        _ =>
          @test.fail("expected NoMemory from finished raster acquire surface")
      }
    } else {
      match result {
        Ok(_) => ()
        _ =>
          @test.fail(
            "expected raster paint recovery after callback replacement",
          )
      }
      target.flush()
      expect_pattern_first_pixel(target.copy_data(), color)
    }
  }

  inspect(failed_paints.val, content="5")
  inspect(release_only_installs.val, content="5")
  inspect(manual_acquires.val > 0, content="true")
  inspect(acquire_calls.val > release_calls.val, content="true")
  inspect(last_extent_width.val > 0, content="true")
  inspect(last_target_width.val > 0, content="true")
  inspect(last_release_width.val > 0, content="true")

  pattern.raster_clear_callbacks()
  let (cleared_acquire, cleared_release) = pattern.raster_get_callbacks()
  guard cleared_acquire is None && cleared_release is None else {
    @test.fail("expected clear after fuzz to remove both raster callbacks")
  }

  pattern.raster_set_acquire(fn(_, _) { static_red })
  let recovered_target = Surface::image(Argb32, 1, 1)
  let recovered_ctx = Context::new(recovered_target)
  recovered_ctx.set_source(pattern)
  recovered_ctx.paint()
  recovered_target.flush()
  expect_pattern_first_pixel(recovered_target.copy_data(), 0)
}

///|
fn make_data_backed_raster_source_pattern() -> Pattern raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) { source })
  pattern
}

///|
test "raster source pattern retains data backed acquire surface" {
  let pattern = make_data_backed_raster_source_pattern()
  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
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
  let source = Surface::image(Argb32, 1, 1)
  let solid = Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let set_result = run_cairo(() => solid.raster_set_acquire(fn(_, _) { source }))
  match set_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let clear_result = run_cairo(() => solid.raster_clear_acquire())
  match clear_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let release_only_result = run_cairo(() => {
    solid.raster_set_callbacks(release=Some(fn(_) { () }))
  })
  match release_only_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let callbacks_result = run_cairo(() => {
    let _ = solid.raster_get_callbacks()
    ()
  })
  match callbacks_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

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
