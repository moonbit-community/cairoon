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
