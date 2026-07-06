///|
fn inspect_argb32_pixel(bytes : Bytes, expected : Array[Int]) -> Unit raise {
  inspect(bytes.length(), content="4")
  for index in 0..<expected.length() {
    inspect(bytes[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn expect_invalid_pop_group(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.InvalidPopGroup, _)) => ()
    _ => @test.fail("expected InvalidPopGroup")
  }
}

///|
fn expect_group_invalid_content(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
test "context pop_group returns a paintable surface pattern" {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  inspect(ctx.get_group_target().get_width(), content="1")

  ctx.push_group()
  let group_target = ctx.get_group_target()
  debug_inspect(group_target.get_content(), content="ContentColorAlpha")
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()

  let pattern = ctx.pop_group()
  inspect_argb32_pixel(group_target.copy_data(), [0, 0, 255, 255])
  inspect(pattern.get_surface().get_width(), content="1")

  ctx.set_source(pattern)
  ctx.paint()
  inspect_argb32_pixel(target.copy_data(), [0, 0, 255, 255])
}

///|
test "context pop_group_to_source installs the group pattern" {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.push_group_with_content(@cairoon.ContentColor)
  debug_inspect(ctx.get_group_target().get_content(), content="ContentColor")
  ctx.set_source_rgb(0.0, 1.0, 0.0)
  ctx.paint()
  ctx.pop_group_to_source()
  ctx.paint()
  inspect_argb32_pixel(target.copy_data(), [0, 255, 0, 255])
}

///|
test "context group content accepts pycairo raw ints" {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.push_group_with_content_raw(0x2000)
  inspect(ctx.get_group_target().get_content_raw(), content="8192")
  debug_inspect(ctx.get_group_target().get_content(), content="ContentAlpha")
  ctx.pop_group_to_source()

  expect_group_invalid_content(
    @cairoon.run_cairo(() => {
      let failing = @cairoon.Context::new(
        @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
      )
      failing.push_group_with_content_raw(0)
    }),
  )
}

///|
test "context group target stack restores original target" {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  inspect(ctx.get_group_target() == target, content="true")

  ctx.push_group()
  inspect(ctx.get_group_target() == target, content="false")
  let _ = ctx.pop_group()
  inspect(ctx.get_group_target() == target, content="true")

  ctx.push_group()
  inspect(ctx.get_group_target() == target, content="false")
  ctx.pop_group_to_source()
  inspect(ctx.get_group_target() == target, content="true")
}

///|
test "context group APIs report unmatched pop errors" {
  let pop = @cairoon.run_cairo(() => {
    let _ = @cairoon.Context::new(
      @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
    ).pop_group()
    ()
  })
  expect_invalid_pop_group(pop)

  let pop_to_source = @cairoon.run_cairo(() => {
    @cairoon.Context::new(@cairoon.Surface::image(@cairoon.Argb32, 1, 1)).pop_group_to_source()
  })
  expect_invalid_pop_group(pop_to_source)
}
