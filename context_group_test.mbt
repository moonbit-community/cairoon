///|
fn inspect_argb32_pixel(bytes : Bytes, expected : Array[Int]) -> Unit raise {
  inspect(bytes.length(), content="4")
  for index in 0..<expected.length() {
    inspect(bytes[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn expect_invalid_pop_group(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(InvalidPopGroup, _)) => ()
    _ => @test.fail("expected InvalidPopGroup")
  }
}

///|
test "context pop_group returns a paintable surface pattern" {
  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
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
  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.push_group_with_content(ContentColor)
  debug_inspect(ctx.get_group_target().get_content(), content="ContentColor")
  ctx.set_source_rgb(0.0, 1.0, 0.0)
  ctx.paint()
  ctx.pop_group_to_source()
  ctx.paint()
  inspect_argb32_pixel(target.copy_data(), [0, 255, 0, 255])
}

///|
test "context group APIs report unmatched pop errors" {
  let pop = run_cairo(() => {
    let _ = Context::new(Surface::image(Argb32, 1, 1)).pop_group()
    ()
  })
  expect_invalid_pop_group(pop)

  let pop_to_source = run_cairo(() => {
    Context::new(Surface::image(Argb32, 1, 1)).pop_group_to_source()
  })
  expect_invalid_pop_group(pop_to_source)
}
