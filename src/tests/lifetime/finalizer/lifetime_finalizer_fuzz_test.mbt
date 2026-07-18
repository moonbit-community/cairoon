///|
fn finalizer_fuzz_next(seed : Ref[Int]) -> Int {
  seed.val = (seed.val * 257 + 173) % 65521
  seed.val
}

///|
fn finalizer_fuzz_pressure(value : Int) -> Int {
  let bytes = Bytes::make(64 + value % 64, b'\x5a')
  let ints : FixedArray[Int] = FixedArray::make(16 + value % 16, value)
  bytes.length() + ints.length()
}

///|
fn finalizer_fuzz_error_status(
  result : Result[Unit, @cairoon.CairoError],
) -> @cairoon.Status? {
  match result {
    Err(CairoError(status, _)) => Some(status)
    Err(CairoMemoryError(status, _)) => Some(status)
    Err(CairoIOError(status, _)) => Some(status)
    Err(CairoInvalidArgument(status, _)) => Some(status)
    _ => None
  }
}

///|
fn finalizer_fuzz_expect_status(
  result : Result[Unit, @cairoon.CairoError],
  expected : @cairoon.Status,
) -> Unit raise {
  match finalizer_fuzz_error_status(result) {
    Some(actual) =>
      if actual != expected {
        @test.fail("unexpected Cairo status in finalizer fuzz path")
      }
    None => @test.fail("expected Cairo error in finalizer fuzz path")
  }
}

///|
fn finalizer_fuzz_expect_argb32(
  data : Bytes,
  expected : Array[Int],
) -> Unit raise {
  if data.length() < expected.length() {
    @test.fail("short ARGB32 data in finalizer fuzz path")
  }
  for index in 0..<expected.length() {
    if data[index].to_int() != expected[index] {
      @test.fail("unexpected ARGB32 pixel in finalizer fuzz path")
    }
  }
}

///|
fn finalizer_fuzz_surface_graph(value : Int) -> Unit raise {
  let backing : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  let source = @cairoon.Surface::image_for_data(backing, Argb32, 2, 2)
  let source_ctx = @cairoon.Context::new(source)
  if value % 2 == 0 {
    source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  } else {
    source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  }
  source_ctx.paint()

  let pattern = @cairoon.Pattern::for_surface(source)
  let returned = pattern.get_surface()
  let child = source.create_for_rectangle(0.0, 0.0, 1.0, 1.0)
  let target = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  target.flush()

  if value % 2 == 0 {
    finalizer_fuzz_expect_argb32(target.copy_data(), [0, 0, 255, 255])
  } else {
    finalizer_fuzz_expect_argb32(target.copy_data(), [255, 0, 0, 255])
  }
  inspect(returned.get_width(), content="2")
  if !child.status().is_success() {
    @test.fail("child surface is invalid in finalizer fuzz path")
  }

  source.finish()
  finalizer_fuzz_expect_status(
    @cairoon.run_cairo(() => {
      let _ = source.copy_data()
      ()
    }),
    SurfaceFinished,
  )
}

///|
fn finalizer_fuzz_mapped_edge(value : Int) -> Unit raise {
  let base = @cairoon.Surface::image(Rgb24, 2, 1)
  if value % 3 == 0 {
    let mapped = base.map_to_image(
      extents=Some(@cairoon.RectangleInt::new(x=0, y=0, width=1, height=1)),
    )
    let result = @cairoon.run_cairo(() => {
      mapped.with_unmapped(() => {
        let ctx = @cairoon.Context::new_for_mapped_image(mapped)
        ctx.set_source_rgb(1.0, 1.0, 1.0)
        ctx.paint()
        let _ = base.create_similar(ContentColor, -1, 1)
        ()
      })
    })
    finalizer_fuzz_expect_status(result, InvalidSize)
    base.flush()
    finalizer_fuzz_expect_argb32(base.copy_data(), [255, 255, 255, 255])
    finalizer_fuzz_expect_status(
      @cairoon.run_cairo(() => mapped.unmap()),
      SurfaceFinished,
    )
  } else {
    let mapped = base.map_to_image()
    let ctx = @cairoon.Context::new_for_mapped_image(mapped)
    ctx.set_source_rgb(0.0, 1.0, 0.0)
    ctx.paint()
    if value % 2 == 0 {
      mapped.unmap()
      base.flush()
      finalizer_fuzz_expect_argb32(base.copy_data(), [0, 255, 0, 255])
    }
  }
}

///|
fn finalizer_fuzz_font_path_region(value : Int) -> Unit raise {
  let surface = @cairoon.Surface::image(Argb32, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif", weight=FontWeightBold)
  ctx.set_font_size(8.0 + (value % 5).to_double())
  let face = ctx.get_font_face()
  let options = ctx.get_font_options()
  options.set_antialias(AntialiasGray)
  let scaled = @cairoon.ScaledFont::new(
    face,
    @cairoon.Matrix::new(xx=10.0, yy=10.0),
    @cairoon.Matrix::new(xx=1.0, yy=1.0),
    options,
  )
  let returned_face = scaled.get_font_face()
  let returned_options = scaled.get_font_options()
  inspect(returned_face.get_family().length() > 0, content="true")
  debug_inspect(returned_options.get_antialias(), content="AntialiasGray")
  ignore(scaled.extents())
  ignore(scaled.text_extents("finalizer"))

  ctx.rectangle(0.0, 0.0, 2.0, 2.0)
  let path = ctx.copy_path()
  let flat = ctx.copy_path_flat()
  let target = @cairoon.Context::new(@cairoon.Surface::image(Argb32, 4, 4))
  target.append_path(path)
  target.append_path(flat)
  inspect(path.length() >= 5, content="true")

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=2 + value % 2, height=2),
  )
  let copy = region.copy()
  ignore(
    copy.union_rectangle(
      @cairoon.RectangleInt::new(x=2, y=0, width=1, height=2),
    ),
  )
  finalizer_fuzz_expect_status(
    @cairoon.run_cairo(() => {
      let _ = copy.get_rectangle(99)
      ()
    }),
    InvalidIndex,
  )
}

///|
fn finalizer_fuzz_raster_edge(value : Int) -> Unit raise {
  let source = @cairoon.Surface::image(Argb32, 2, 2)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let failed_source = @cairoon.Surface::image(Argb32, 1, 1)
  failed_source.finish()
  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let pattern = @cairoon.Pattern::raster_source(ContentColorAlpha, 2, 2)
  let should_fail = value % 4 == 0
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
      ignore(try! surface.get_width())
    }),
  )

  let target = @cairoon.Surface::image(Argb32, 2, 2)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  let result = @cairoon.run_cairo(() => ctx.paint())
  if should_fail {
    finalizer_fuzz_expect_status(result, NoMemory)
  } else {
    match result {
      Ok(_) => ()
      _ => @test.fail("expected successful raster finalizer fuzz paint")
    }
    target.flush()
    finalizer_fuzz_expect_argb32(target.copy_data(), [255, 0, 0, 255])
    inspect(release_calls.val >= 1, content="true")
  }
  inspect(acquire_calls.val >= 1, content="true")
  pattern.raster_clear_callbacks()
}

///|
fn finalizer_fuzz_stream_device_edge(
  value : Int,
  stream_successes : Ref[Int],
  stream_failures : Ref[Int],
) -> Unit raise {
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let device = @cairoon.Device::script_stream(fn(chunk) {
    chunk_count.val += 1
    byte_count.val += chunk.length()
    if value % 5 == 0 {
      WriteError
    } else {
      Success
    }
  })
  let result = @cairoon.run_cairo(() => {
    let surface = @cairoon.Surface::script(device, ContentColorAlpha, 3.0, 3.0)
    let ctx = @cairoon.Context::new(surface)
    ctx.set_source_rgb(0.2, 0.4, 0.6)
    ctx.paint()
    surface.finish()
    device.finish()
  })
  if value % 5 == 0 {
    stream_failures.val += 1
    finalizer_fuzz_expect_status(result, WriteError)
  } else {
    stream_successes.val += 1
    match result {
      Ok(_) => ()
      _ => @test.fail("expected successful script finalizer fuzz path")
    }
    inspect(byte_count.val > 0, content="true")
  }
  inspect(chunk_count.val > 0, content="true")
}

///|
fn finalizer_fuzz_step(
  value : Int,
  stream_successes : Ref[Int],
  stream_failures : Ref[Int],
) -> Unit raise {
  match value % 5 {
    0 => finalizer_fuzz_surface_graph(value)
    1 => finalizer_fuzz_mapped_edge(value)
    2 => finalizer_fuzz_font_path_region(value)
    3 => finalizer_fuzz_raster_edge(value)
    _ =>
      finalizer_fuzz_stream_device_edge(
        value / 5,
        stream_successes,
        stream_failures,
      )
  }
}

///|
test "finalizer graph multi-seed fuzz covers error exits and retained owners" {
  let pressure_total = Ref(0)
  let stream_successes = Ref(0)
  let stream_failures = Ref(0)
  for seed_start in [19, 97, 701, 4099] {
    let seed = Ref(seed_start)
    for _ in 0..<40 {
      let value = finalizer_fuzz_next(seed)
      finalizer_fuzz_step(value, stream_successes, stream_failures)
      pressure_total.val += finalizer_fuzz_pressure(value)
    }
  }
  inspect(pressure_total.val > 0, content="true")
  inspect(stream_successes.val, content="19")
  inspect(stream_failures.val, content="9")
}
