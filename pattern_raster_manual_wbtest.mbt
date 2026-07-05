///|
fn make_raster_manual_color_source(color : Int) -> Surface raise CairoError {
  let surface = Surface::image(Argb32, 3, 3)
  let ctx = Context::new(surface)
  paint_raster_manual_color(ctx, color)
  surface
}

///|
fn paint_raster_manual_color(
  ctx : Context,
  color : Int,
) -> Unit raise CairoError {
  match color {
    0 => ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    1 => ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
    _ => ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  }
  ctx.paint()
}

///|
fn expect_raster_manual_first_pixel(data : Bytes, color : Int) -> Unit raise {
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
fn expect_raster_manual_owner_counts_zero(
  sources : Array[Surface],
  failed_source : Surface,
) -> Unit raise {
  for source in sources {
    inspect(test_raster_surface_owner_count_ffi(source), content="0")
  }
  inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
}

///|
fn next_raster_manual_seed(seed : Ref[Int]) -> Int {
  seed.val = (seed.val * 109 + 37) % 1543
  seed.val
}

///|
test "raster source manual callback multi-seed fuzz keeps owners balanced" {
  let sources = [
    make_raster_manual_color_source(0),
    make_raster_manual_color_source(1),
    make_raster_manual_color_source(2),
  ]
  let failed_source = Surface::image(Argb32, 1, 1)
  failed_source.finish()
  expect_raster_manual_owner_counts_zero(sources, failed_source)

  let acquire_calls = Ref(0)
  let paint_failures = Ref(0)
  let paint_successes = Ref(0)
  let manual_acquires = Ref(0)
  let manual_releases = Ref(0)
  let acquire_only_manuals = Ref(0)
  let user_release_calls = Ref(0)
  let release_only_calls = Ref(0)
  let dynamic_acquires = Ref(0)

  for seed_start in [11, 137, 523] {
    let seed = Ref(seed_start)
    let pattern = Pattern::raster_source(ContentColorAlpha, 3, 3)

    for step in 0..<48 {
      let value = next_raster_manual_seed(seed)
      let mode = (value + step) % 8
      let color = (value / 7 + step) % 3
      let static_source = sources[color]

      if mode == 0 {
        pattern.raster_clear_callbacks()
        let (acquire, release) = pattern.raster_get_callbacks()
        guard acquire is None && release is None else {
          fail("expected clear to remove raster callbacks")
        }
      } else if mode == 1 {
        pattern.raster_set_callbacks(
          release=Some(fn(surface) {
            release_only_calls.val += 1
            ignore(try! surface.get_width())
          }),
        )
        let (acquire, release) = pattern.raster_get_callbacks()
        guard acquire is None && release is Some(_) else {
          fail("expected release-only raster callback state")
        }
        match release {
          Some(release) => release(static_source)
          None => fail("expected release callback")
        }
      } else {
        let should_fail = mode == 2
        let use_dynamic_source = mode == 3 || mode == 6
        let use_user_release = mode != 4
        let acquire : (Surface, RectangleInt) -> Surface = fn(
          target : Surface,
          extents : RectangleInt,
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
            try! paint_raster_manual_color(try! Context::new(source), color)
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
          fail("expected acquire callback after set")
        }
        inspect(current_release is Some(_), content="\{use_user_release}")

        if !should_fail && step % 3 == 0 {
          match current_acquire {
            Some(manual_acquire) => {
              let manual_target = Surface::image(
                Argb32,
                2 + value % 2,
                2 + step % 2,
              )
              let extents = RectangleInt::new(
                x=step % 2,
                y=value / 3 % 2,
                width=1 + value % 2,
                height=1 + value / 5 % 2,
              )
              let acquired = manual_acquire(manual_target, extents)
              manual_acquires.val += 1
              match current_release {
                Some(release) => {
                  release(acquired)
                  manual_releases.val += 1
                }
                None => acquire_only_manuals.val += 1
              }
            }
            None => fail("expected manual acquire callback")
          }
        }

        let target = Surface::image(Argb32, 1 + value % 3, 1 + value / 3 % 3)
        let ctx = Context::new(target)
        ctx.set_source(pattern)
        let result = run_cairo(() => ctx.paint())
        if should_fail {
          match result {
            Err(CairoMemoryError(NoMemory, _)) => paint_failures.val += 1
            _ => fail("expected NoMemory from finished acquire surface")
          }
        } else {
          match result {
            Ok(_) => ()
            _ => fail("expected raster paint after manual callback transition")
          }
          paint_successes.val += 1
          target.flush()
          expect_raster_manual_first_pixel(target.copy_data(), color)
        }
      }
      expect_raster_manual_owner_counts_zero(sources, failed_source)
    }

    pattern.raster_clear_callbacks()
    expect_raster_manual_owner_counts_zero(sources, failed_source)
  }

  inspect(paint_failures.val > 0, content="true")
  inspect(paint_successes.val > 0, content="true")
  inspect(manual_acquires.val > 0, content="true")
  inspect(manual_releases.val > 0, content="true")
  inspect(acquire_only_manuals.val > 0, content="true")
  inspect(acquire_calls.val > manual_acquires.val, content="true")
  inspect(user_release_calls.val > 0, content="true")
  inspect(release_only_calls.val > 0, content="true")
  inspect(dynamic_acquires.val > 0, content="true")
  expect_raster_manual_owner_counts_zero(sources, failed_source)
}
