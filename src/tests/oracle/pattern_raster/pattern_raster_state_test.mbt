///|
fn make_raster_state_color_source(
  color : Int,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(Argb32, 3, 3)
  let ctx = @cairoon.Context::new(surface)
  match color {
    0 => ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    1 => ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
    _ => ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  }
  ctx.paint()
  surface
}

///|
fn expect_raster_state_first_pixel(data : Bytes, color : Int) -> Unit raise {
  let expected = match color {
    0 => [0, 0, 255, 255]
    1 => [0, 255, 0, 255]
    _ => [255, 0, 0, 255]
  }
  for index in 0..<expected.length() {
    inspect(data[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn expect_raster_state_distribution(
  actual : FixedArray[Int],
  expected : Array[Int],
) -> Unit raise {
  inspect(actual.length(), content="\{expected.length()}")
  for index in 0..<expected.length() {
    inspect(actual[index], content="\{expected[index]}")
  }
}

///|
fn expect_raster_state_owner_counts_zero(
  sources : Array[@cairoon.Surface],
  failed_source : @cairoon.Surface,
) -> Unit raise {
  for source in sources {
    inspect(test_raster_surface_owner_count_ffi(source), content="0")
  }
  inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
}

///|
fn next_raster_state_seed(seed : Ref[Int]) -> Int {
  seed.val = (seed.val * 73 + 41) % 997
  seed.val
}

///|
test "raster source callback state machine multi-seed fuzz keeps owners balanced" {
  let sources = [
    make_raster_state_color_source(0),
    make_raster_state_color_source(1),
    make_raster_state_color_source(2),
  ]
  let failed_source = @cairoon.Surface::image(Argb32, 1, 1)
  failed_source.finish()
  expect_raster_state_owner_counts_zero(sources, failed_source)

  let acquire_calls = Ref(0)
  let user_release_calls = Ref(0)
  let release_only_calls = Ref(0)
  let failed_paints = Ref(0)
  let successful_paints = Ref(0)
  let dynamic_acquires = Ref(0)
  let operation_counts = FixedArray::make(7, 0)
  let operation_color_counts = FixedArray::make(21, 0)

  for seed_start in [17, 313, 701, 887] {
    let seed = Ref(seed_start)
    let pattern = @cairoon.Pattern::raster_source(ContentColorAlpha, 3, 3)

    for step in 0..<72 {
      let value = next_raster_state_seed(seed)
      let op = value % 7
      let color = (value + step) % 3
      operation_counts[op] = operation_counts[op] + 1
      let operation_color_index = op * 3 + color
      operation_color_counts[operation_color_index] = operation_color_counts[operation_color_index] +
        1
      if op == 0 {
        pattern.raster_clear_callbacks()
        let (acquire, release) = pattern.raster_get_callbacks()
        guard acquire is None && release is None else {
          @test.fail("expected clear to remove raster callbacks")
        }
      } else if op == 1 {
        pattern.raster_set_callbacks(
          release=Some(fn(surface) {
            release_only_calls.val += 1
            ignore(try! surface.get_width())
          }),
        )
        let (acquire, release) = pattern.raster_get_callbacks()
        guard acquire is None && release is Some(_) else {
          @test.fail("expected release-only raster callback state")
        }
        match release {
          Some(release) => release(sources[color])
          None => @test.fail("expected release callback")
        }
      } else {
        let should_fail = op == 2
        let use_dynamic_source = op == 3 || op == 6
        let use_user_release = op != 4
        let static_source = sources[color]
        let acquire : (@cairoon.Surface, @cairoon.RectangleInt) -> @cairoon.Surface = fn(
          target : @cairoon.Surface,
          extents : @cairoon.RectangleInt,
        ) {
          acquire_calls.val += 1
          ignore(try! target.get_content())
          ignore(extents.components())
          if should_fail {
            failed_source
          } else if use_dynamic_source {
            dynamic_acquires.val += 1
            let source = try! target.create_similar_image(
              Argb32,
              extents.width,
              extents.height,
            )
            try! source.set_device_offset(
              extents.x.to_double(),
              extents.y.to_double(),
            )
            let ctx = try! @cairoon.Context::new(source)
            match color {
              0 => try! ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
              1 => try! ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
              _ => try! ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
            }
            try! ctx.paint()
            source
          } else {
            static_source
          }
        }
        if use_user_release {
          pattern.raster_set_acquire(
            acquire,
            release=Some(fn(surface) {
              user_release_calls.val += 1
              ignore(try! surface.get_height())
            }),
          )
        } else {
          pattern.raster_set_acquire(acquire)
        }
        let (current_acquire, current_release) = pattern.raster_get_callbacks()
        guard current_acquire is Some(_) else {
          @test.fail("expected acquire callback after set")
        }
        inspect(current_release is Some(_), content="\{use_user_release}")

        let target = @cairoon.Surface::image(
          Argb32,
          1 + value % 3,
          1 + value / 3 % 3,
        )
        let ctx = @cairoon.Context::new(target)
        ctx.set_source(pattern)
        let result = @cairoon.run_cairo(() => ctx.paint())
        if should_fail {
          match result {
            Err(CairoMemoryError(NoMemory, _)) => failed_paints.val += 1
            _ => @test.fail("expected NoMemory from finished acquire surface")
          }
        } else {
          match result {
            Ok(_) => ()
            _ => @test.fail("expected raster paint after callback transition")
          }
          successful_paints.val += 1
          target.flush()
          expect_raster_state_first_pixel(target.copy_data(), color)
        }
      }
      expect_raster_state_owner_counts_zero(sources, failed_source)
    }

    pattern.raster_clear_callbacks()
    expect_raster_state_owner_counts_zero(sources, failed_source)
  }

  inspect(failed_paints.val > 0, content="true")
  inspect(successful_paints.val > 0, content="true")
  inspect(acquire_calls.val > 0, content="true")
  inspect(user_release_calls.val > 0, content="true")
  inspect(release_only_calls.val > 0, content="true")
  inspect(dynamic_acquires.val > 0, content="true")
  expect_raster_state_distribution(operation_counts, [
    45, 41, 36, 33, 54, 34, 45,
  ])
  expect_raster_state_distribution(operation_color_counts, [
    13, 15, 17, 21, 11, 9, 13, 11, 12, 14, 13, 6, 24, 12, 18, 9, 9, 16, 17, 14, 14,
  ])
  expect_raster_state_owner_counts_zero(sources, failed_source)
}
