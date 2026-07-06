///|
fn expect_argb32_red_pixel(data : Bytes, offset : Int) -> Unit raise {
  inspect(data[offset].to_int(), content="0")
  inspect(data[offset + 1].to_int(), content="0")
  inspect(data[offset + 2].to_int(), content="255")
  inspect(data[offset + 3].to_int(), content="255")
}

///|
fn expect_argb32_transparent_pixel(data : Bytes, offset : Int) -> Unit raise {
  inspect(data[offset].to_int(), content="0")
  inspect(data[offset + 1].to_int(), content="0")
  inspect(data[offset + 2].to_int(), content="0")
  inspect(data[offset + 3].to_int(), content="0")
}

///|
fn child_surface_from_local_parent() -> @cairoon.Surface raise @cairoon.CairoError {
  let parent = @cairoon.Surface::image(@cairoon.Argb32, 4, 4)
  parent.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
}

///|
fn expect_subsurface_invalid_size(
  result : Result[@cairoon.Surface, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }
}

///|
test "subsurface clips and translates drawing into parent surface" {
  let parent = @cairoon.Surface::image(@cairoon.Argb32, 4, 4)
  let child = parent.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
  inspect(child.status().is_success(), content="true")
  debug_inspect(child.get_content(), content="ContentColorAlpha")

  let ctx = @cairoon.Context::new(child)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  child.flush()

  let data = parent.copy_data()
  let stride = parent.get_stride()
  expect_argb32_red_pixel(data, stride + 4)
  expect_argb32_red_pixel(data, stride * 2 + 8)
  expect_argb32_transparent_pixel(data, stride)
  expect_argb32_transparent_pixel(data, stride * 3 + 12)
}

///|
test "subsurface keeps parent wrapper alive after local scope exits" {
  let child = child_surface_from_local_parent()
  let ctx = @cairoon.Context::new(child)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.paint()
  child.flush()
  inspect(child.status().is_success(), content="true")
}

///|
test "subsurface validates invalid rectangle dimensions" {
  let parent = @cairoon.Surface::image(@cairoon.Argb32, 4, 4)
  expect_subsurface_invalid_size(
    @cairoon.run_cairo(() => parent.create_for_rectangle(0.0, 0.0, -1.0, 1.0)),
  )
  expect_subsurface_invalid_size(
    @cairoon.run_cairo(() => parent.create_for_rectangle(0.0, 0.0, 1.0, -1.0)),
  )
}
