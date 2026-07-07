///|
fn raster_stress_paint_source(
  red : Double,
  green : Double,
  blue : Double,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let backing : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let surface = @cairoon.Surface::image_for_data(backing, @cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(red, green, blue, 1.0)
  ctx.paint()
  surface
}

///|
fn raster_stress_expect_blue(data : Bytes) -> Unit raise {
  if data.length() != 4 ||
    data[0] != b'\xff' ||
    data[1] != b'\x00' ||
    data[2] != b'\x00' ||
    data[3] != b'\xff' {
    @test.fail("expected blue ARGB32 pixel")
  }
}

///|
fn raster_stress_expect_green(data : Bytes) -> Unit raise {
  if data.length() != 4 ||
    data[0] != b'\x00' ||
    data[1] != b'\xff' ||
    data[2] != b'\x00' ||
    data[3] != b'\xff' {
    @test.fail("expected green ARGB32 pixel")
  }
}

///|
fn raster_stress_pattern_from_local_source(
  acquire_calls : Ref[Int],
  release_calls : Ref[Int],
) -> @cairoon.Pattern raise @cairoon.CairoError {
  let source = raster_stress_paint_source(0.0, 0.0, 1.0)
  let pattern = @cairoon.Pattern::raster_source(
    @cairoon.ContentColorAlpha,
    1,
    1,
  )
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      ignore(try! target.get_width())
      ignore(extents.components())
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      ignore(try! surface.get_height())
    }),
  )
  pattern
}

///|
fn raster_stress_render(
  pattern : @cairoon.Pattern,
) -> Bytes raise @cairoon.CairoError {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  target.copy_data()
}

///|
fn raster_stress_one_iteration(index : Int) -> Unit raise {
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let pattern = raster_stress_pattern_from_local_source(
    acquire_calls, release_calls,
  )
  let first = raster_stress_render(pattern)
  if acquire_calls.val <= 0 || release_calls.val != acquire_calls.val {
    @test.fail("raster-source acquire/release counts diverged")
  }
  if index % 250 == 0 {
    raster_stress_expect_blue(first)
  }

  match pattern.raster_get_acquire() {
    Some((acquire, Some(release))) => {
      let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
      let acquired = acquire(
        target,
        @cairoon.RectangleInt::new(width=1, height=1),
      )
      if acquired.get_width() != 1 {
        @test.fail("raster-source acquire callback returned invalid surface")
      }
      release(acquired)
    }
    _ => @test.fail("expected raster-source acquire and release callbacks")
  }
  if release_calls.val != acquire_calls.val {
    @test.fail("manual raster-source release did not balance acquire")
  }

  let replacement_calls = Ref(0)
  let replacement = raster_stress_paint_source(0.0, 1.0, 0.0)
  pattern.raster_set_acquire(fn(_, _) {
    replacement_calls.val += 1
    replacement
  })
  let second = raster_stress_render(pattern)
  if replacement_calls.val <= 0 {
    @test.fail("replacement raster-source callback was not invoked")
  }
  if index % 250 == 0 {
    raster_stress_expect_green(second)
    match pattern.raster_get_acquire() {
      Some((_, None)) => ()
      _ => @test.fail("expected raster-source acquire callback without release")
    }
  }

  pattern.raster_clear_acquire()
  if index % 250 == 0 {
    inspect(pattern.raster_get_acquire() is None, content="true")
  }
}

///|
test "raster source callback allocation stress" {
  for index in 0..<1000 {
    raster_stress_one_iteration(index)
  }
}
