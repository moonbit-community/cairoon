///|
fn paint_pattern_color(
  ctx : @cairoon.Context,
  color : Int,
) -> Unit raise @cairoon.CairoError {
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
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, width, height)
  paint_pattern_color(@cairoon.Context::new(surface), color)
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
  let failed_source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  failed_source.finish()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let failed_paints = Ref(0)
  let manual_acquires = Ref(0)
  let release_only_installs = Ref(0)
  let last_extent_width = Ref(0)
  let last_target_width = Ref(0)
  let last_release_width = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    3,
    3,
  )

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
            @cairoon.Argb32,
            extents.width,
            extents.height,
          )
          try! source.set_device_offset(
            extents.x.to_double(),
            extents.y.to_double(),
          )
          try! paint_pattern_color(@cairoon.Context::new(source), color)
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
          let target = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
          let acquired = acquire(
            target,
            @cairoon.RectangleInt::new(width=2, height=2),
          )
          release(acquired)
          manual_acquires.val += 1
        }
        _ => @test.fail("expected acquire and release callbacks after set")
      }
    }

    let target_width = 1 + step % 3
    let target_height = 1 + step / 3 % 3
    let target = @cairoon.Surface::image(
      @cairoon.Argb32,
      target_width,
      target_height,
    )
    let ctx = @cairoon.Context::new(target)
    let result = @cairoon.run_cairo(() => {
      ctx.set_source(pattern)
      ctx.paint()
    })
    if should_fail {
      match result {
        Err(@cairoon.CairoMemoryError(@cairoon.NoMemory, _)) =>
          failed_paints.val += 1
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
  let recovered_target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let recovered_ctx = @cairoon.Context::new(recovered_target)
  recovered_ctx.set_source(pattern)
  recovered_ctx.paint()
  recovered_target.flush()
  expect_pattern_first_pixel(recovered_target.copy_data(), 0)
}
