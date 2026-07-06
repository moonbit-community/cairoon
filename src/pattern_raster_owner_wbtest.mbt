///|
test "raster source acquire-only releases retained owner after paint" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  inspect(test_raster_surface_owner_count_ffi(source), content="0")

  let acquire_calls = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) {
    acquire_calls.val += 1
    source
  })

  for _ in 0..<3 {
    let target = Surface::image(Argb32, 1, 1)
    let ctx = Context::new(target)
    ctx.set_source(pattern)
    ctx.paint()
    target.flush()
    let data = target.copy_data()
    inspect(data[0].to_int(), content="255")
    inspect(data[1].to_int(), content="0")
    inspect(data[2].to_int(), content="0")
    inspect(data[3].to_int(), content="255")
    inspect(test_raster_surface_owner_count_ffi(source), content="0")
  }

  inspect(acquire_calls.val > 0, content="true")
}

///|
fn make_raster_owner_color_source(color : Int) -> Surface raise CairoError {
  let surface = Surface::image(Argb32, 3, 3)
  let ctx = Context::new(surface)
  match color {
    0 => ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    1 => ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
    _ => ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  }
  ctx.paint()
  surface
}

///|
fn expect_raster_owner_first_pixel(bytes : Bytes, color : Int) -> Unit raise {
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
fn expect_raster_owner_counts_zero(surfaces : Array[Surface]) -> Unit raise {
  for surface in surfaces {
    inspect(test_raster_surface_owner_count_ffi(surface), content="0")
  }
}

///|
test "raster source acquire-only owner count balances across replacement fuzz" {
  let sources = [
    make_raster_owner_color_source(0),
    make_raster_owner_color_source(1),
    make_raster_owner_color_source(2),
  ]
  expect_raster_owner_counts_zero(sources)

  let acquire_calls = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 3, 3)
  for step in 0..<64 {
    if step % 11 == 0 {
      pattern.raster_clear_callbacks()
      expect_raster_owner_counts_zero(sources)
    }

    let color = (step * 7 + 3) % 3
    let source = sources[color]
    pattern.raster_set_acquire(fn(target, extents) {
      acquire_calls.val += 1
      ignore(try! target.get_content())
      ignore(extents.components())
      source
    })

    let target = Surface::image(Argb32, 1 + step % 4, 1 + step / 4 % 4)
    let ctx = Context::new(target)
    ctx.set_source(pattern)
    ctx.paint()
    target.flush()
    expect_raster_owner_first_pixel(target.copy_data(), color)
    expect_raster_owner_counts_zero(sources)
  }

  inspect(acquire_calls.val > 0, content="true")
  pattern.raster_clear_callbacks()
  expect_raster_owner_counts_zero(sources)
}

///|
test "raster source failed acquire replacement keeps owner counts balanced" {
  let sources = [
    make_raster_owner_color_source(0),
    make_raster_owner_color_source(1),
    make_raster_owner_color_source(2),
  ]
  let failed_source = Surface::image(Argb32, 1, 1)
  failed_source.finish()
  expect_raster_owner_counts_zero(sources)
  inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let failed_paints = Ref(0)
  let successful_paints = Ref(0)
  let last_release_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 3, 3)
  for step in 0..<36 {
    if step % 7 == 0 {
      pattern.raster_clear_callbacks()
      expect_raster_owner_counts_zero(sources)
      inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
    }

    let should_fail = step % 5 == 0
    let color = (step * 5 + 1) % 3
    let source = sources[color]
    pattern.raster_set_acquire(
      fn(target, extents) {
        acquire_calls.val += 1
        ignore(try! target.get_content())
        ignore(extents.components())
        if should_fail {
          failed_source
        } else {
          source
        }
      },
      release=Some(fn(surface) {
        release_calls.val += 1
        last_release_width.val = try! surface.get_width()
      }),
    )

    let target = Surface::image(Argb32, 2 + step % 2, 2 + step / 2 % 2)
    let ctx = Context::new(target)
    ctx.set_source(pattern)
    let result = run_cairo(() => ctx.paint())
    if should_fail {
      match result {
        Err(CairoMemoryError(NoMemory, _)) => failed_paints.val += 1
        _ => fail("expected NoMemory from finished acquire surface")
      }
    } else {
      match result {
        Ok(_) => ()
        _ => fail("expected paint to recover after failed acquire")
      }
      successful_paints.val += 1
      target.flush()
      expect_raster_owner_first_pixel(target.copy_data(), color)
    }
    expect_raster_owner_counts_zero(sources)
    inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
  }

  inspect(failed_paints.val, content="8")
  inspect(successful_paints.val, content="28")
  inspect(acquire_calls.val > release_calls.val, content="true")
  inspect(release_calls.val >= successful_paints.val, content="true")
  inspect(last_release_width.val > 0, content="true")
  pattern.raster_clear_callbacks()
  expect_raster_owner_counts_zero(sources)
  inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
}

///|
test "raster source acquire-only replacement drops stale release callback" {
  let source = make_raster_owner_color_source(1)
  inspect(test_raster_surface_owner_count_ffi(source), content="0")

  let stale_release_calls = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 3, 3)
  pattern.raster_set_callbacks(
    release=Some(fn(_) { stale_release_calls.val += 1 }),
  )
  let (release_only_acquire, release_only_release) = pattern.raster_get_callbacks()
  guard release_only_acquire is None && release_only_release is Some(_) else {
    fail("expected release-only raster callback state")
  }

  let acquire_calls = Ref(0)
  pattern.raster_set_acquire(fn(target, extents) {
    acquire_calls.val += 1
    ignore(try! target.get_content())
    ignore(extents.components())
    source
  })
  let (acquire_only_acquire, acquire_only_release) = pattern.raster_get_callbacks()
  guard acquire_only_acquire is Some(_) && acquire_only_release is None else {
    fail("expected acquire-only replacement to drop stale release")
  }

  for _ in 0..<4 {
    let target = Surface::image(Argb32, 2, 2)
    let ctx = Context::new(target)
    ctx.set_source(pattern)
    ctx.paint()
    target.flush()
    expect_raster_owner_first_pixel(target.copy_data(), 1)
    inspect(test_raster_surface_owner_count_ffi(source), content="0")
    inspect(stale_release_calls.val, content="0")
  }

  inspect(acquire_calls.val > 0, content="true")
  pattern.raster_clear_callbacks()
  inspect(test_raster_surface_owner_count_ffi(source), content="0")
}
