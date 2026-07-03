///|
fn lifetime_child_from_local_parent() -> Surface raise CairoError {
  let parent = Surface::image(Argb32, 4, 4)
  parent.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
}

///|
fn lifetime_pattern_from_data_surface() -> Pattern raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  Pattern::for_surface(source)
}

///|
fn lifetime_mapped_from_local_base() -> MappedImageSurface raise CairoError {
  let base = Surface::image(Rgb24, 1, 1)
  base.map_to_image()
}

///|
fn lifetime_context_from_local_mapping() -> Context raise CairoError {
  let mapped = lifetime_mapped_from_local_base()
  Context::new_for_mapped_image(mapped)
}

///|
fn expect_lifetime_argb32_blue(data : Bytes) -> Unit raise {
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn expect_lifetime_rgb24_white(data : Bytes) -> Unit raise {
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
fn expect_lifetime_mapped_finished(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "mapped image keeps base wrapper alive after local scope exits" {
  let mapped = lifetime_mapped_from_local_base()
  let ctx = Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  expect_lifetime_rgb24_white(mapped.copy_data())
  mapped.unmap()
  expect_lifetime_mapped_finished(
    run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    }),
  )
}

///|
test "context remains usable after mapped image wrapper scope exits" {
  let ctx = lifetime_context_from_local_mapping()
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  debug_inspect(ctx.status(), content="Success")
  let target = ctx.get_target()
  debug_inspect(target.status(), content="Success")
  debug_inspect(target.get_format(), content="Rgb24")
  inspect(target.get_width(), content="1")
  inspect(target.get_height(), content="1")
  inspect(target.copy_data().length(), content="4")
}

///|
test "retained cairo owner graph allocation stress" {
  for index in 0..<1000 {
    let child = lifetime_child_from_local_parent()
    let child_ctx = Context::new(child)
    child_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    child_ctx.paint()
    child.flush()
    if !child.status().is_success() {
      @test.fail("subsurface became invalid during stress")
    }

    let pattern = lifetime_pattern_from_data_surface()
    let target = Surface::image(Argb32, 1, 1)
    let target_ctx = Context::new(target)
    target_ctx.set_source(pattern)
    target_ctx.paint()
    if index % 250 == 0 {
      expect_lifetime_argb32_blue(target.copy_data())
    }

    let mapped = lifetime_mapped_from_local_base()
    let mapped_ctx = Context::new_for_mapped_image(mapped)
    mapped_ctx.set_source_rgb(1.0, 1.0, 1.0)
    mapped_ctx.paint()
    if index % 250 == 0 {
      expect_lifetime_rgb24_white(mapped.copy_data())
    }
    mapped.unmap()
  }
}
