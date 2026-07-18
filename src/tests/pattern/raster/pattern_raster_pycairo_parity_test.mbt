///|
fn expect_pycairo_raster_red_pixel(surface : @cairoon.Surface) -> Unit raise {
  surface.flush()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "pycairo raster source callback state fixture" {
  let pattern = @cairoon.Pattern::raster_source(ContentColor, 2, 2)
  inspect(pattern.status().is_success(), content="true")
  inspect(pattern.raster_get_acquire() is None, content="true")

  let release_probe = Ref(0)
  pattern.raster_set_callbacks(
    release=Some(fn(surface) { release_probe.val = try! surface.get_width() }),
  )
  let (release_only_acquire, release_only_release) = pattern.raster_get_callbacks()
  inspect(release_only_acquire is None, content="true")
  inspect(pattern.raster_get_acquire() is None, content="true")
  match release_only_release {
    Some(release) => {
      release(@cairoon.Surface::image(Argb32, 3, 1))
      inspect(release_probe.val, content="3")
    }
    None => @test.fail("expected release callback")
  }

  let source = @cairoon.Surface::image(Argb32, 1, 1)
  let acquire_probe = Ref(0)
  pattern.raster_set_acquire(fn(_, extents) {
    acquire_probe.val = extents.width
    source
  })
  match pattern.raster_get_acquire() {
    Some((acquire, None)) => {
      let acquired = acquire(
        @cairoon.Surface::image(Argb32, 1, 1),
        @cairoon.RectangleInt::new(width=2, height=2),
      )
      inspect(acquired.get_width(), content="1")
      inspect(acquire_probe.val, content="2")
    }
    _ => @test.fail("expected acquire-only callback")
  }

  pattern.raster_clear_callbacks()
  let (cleared_acquire, cleared_release) = pattern.raster_get_callbacks()
  inspect(cleared_acquire is None, content="true")
  inspect(cleared_release is None, content="true")
}

///|
test "pycairo raster source acquire release paint fixture" {
  let events : Array[String] = []
  let pattern = @cairoon.Pattern::raster_source(ContentColor, 2, 2)
  pattern.raster_set_acquire(
    fn(target, extents) {
      events.push("acquire")
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
      try! ctx.set_source_rgb(1.0, 0.0, 0.0)
      try! ctx.paint()
      source
    },
    release=Some(fn(surface) {
      events.push("release")
      ignore(try! surface.get_width())
    }),
  )

  let surface = @cairoon.Surface::image(Argb32, 10, 10)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source(pattern)
  ctx.paint()

  inspect(events.length(), content="2")
  inspect(events[0], content="acquire")
  inspect(events[1], content="release")
  expect_pycairo_raster_red_pixel(surface)
}
