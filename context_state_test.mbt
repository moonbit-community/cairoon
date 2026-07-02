///|
fn context_state_surface() -> Surface raise CairoError {
  Surface::image(Argb32, 16, 16)
}

///|
fn assert_state_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
test "context default drawing state mirrors cairo" {
  let ctx = Context::new(context_state_surface())
  debug_inspect(ctx.get_antialias(), content="AntialiasDefault")
  debug_inspect(ctx.get_fill_rule(), content="FillWinding")
  debug_inspect(ctx.get_line_cap(), content="LineCapButt")
  debug_inspect(ctx.get_line_join(), content="LineJoinMiter")
  debug_inspect(ctx.get_operator(), content="OperatorOver")
  inspect(ctx.get_hairline(), content="false")
  assert_state_close(ctx.get_line_width(), 2.0)
  assert_state_close(ctx.get_tolerance(), 0.1)
  assert_state_close(ctx.get_miter_limit(), 10.0)
}

///|
test "context drawing state setters round trip" {
  let ctx = Context::new(context_state_surface())
  ctx.set_antialias(AntialiasSubpixel)
  ctx.set_fill_rule(FillEvenOdd)
  ctx.set_line_cap(LineCapSquare)
  ctx.set_line_join(LineJoinBevel)
  ctx.set_operator(OperatorSource)
  ctx.set_line_width(4.5)
  ctx.set_tolerance(0.25)
  ctx.set_miter_limit(2.5)
  ctx.set_hairline(true)
  debug_inspect(ctx.get_antialias(), content="AntialiasSubpixel")
  debug_inspect(ctx.get_fill_rule(), content="FillEvenOdd")
  debug_inspect(ctx.get_line_cap(), content="LineCapSquare")
  debug_inspect(ctx.get_line_join(), content="LineJoinBevel")
  debug_inspect(ctx.get_operator(), content="OperatorSource")
  inspect(ctx.get_hairline(), content="true")
  assert_state_close(ctx.get_line_width(), 0.0)
  ctx.set_hairline(false)
  inspect(ctx.get_hairline(), content="false")
  assert_state_close(ctx.get_line_width(), 4.5)
  assert_state_close(ctx.get_tolerance(), 0.25)
  assert_state_close(ctx.get_miter_limit(), 2.5)
}

///|
test "context save restore preserves drawing state" {
  let ctx = Context::new(context_state_surface())
  ctx.set_line_width(3.0)
  ctx.set_operator(OperatorOver)
  ctx.set_hairline(true)
  ctx.save()
  ctx.set_hairline(false)
  ctx.set_line_width(7.0)
  ctx.set_operator(OperatorClear)
  assert_state_close(ctx.get_line_width(), 7.0)
  debug_inspect(ctx.get_operator(), content="OperatorClear")
  inspect(ctx.get_hairline(), content="false")
  ctx.restore()
  debug_inspect(ctx.get_operator(), content="OperatorOver")
  inspect(ctx.get_hairline(), content="true")
  assert_state_close(ctx.get_line_width(), 0.0)
  ctx.set_hairline(false)
  assert_state_close(ctx.get_line_width(), 3.0)
}

///|
test "context dash state round trips and clears" {
  let ctx = Context::new(context_state_surface())
  inspect(ctx.get_dash_count(), content="0")
  let (empty_dashes, empty_offset) = ctx.get_dash()
  inspect(empty_dashes.length(), content="0")
  inspect(empty_offset, content="0")

  ctx.set_dash([0.0, 1.0, 2.0, 3.0], offset=10.0)
  inspect(ctx.get_dash_count(), content="4")
  let (dashes, offset) = ctx.get_dash()
  inspect(dashes.length(), content="4")
  inspect(dashes[0], content="0")
  inspect(dashes[1], content="1")
  inspect(dashes[2], content="2")
  inspect(dashes[3], content="3")
  inspect(offset, content="4")

  ctx.set_dash([1.0], offset=1.25)
  let (single_dash, single_offset) = ctx.get_dash()
  inspect(single_dash.length(), content="1")
  inspect(single_dash[0], content="1")
  inspect(single_offset, content="1.25")

  ctx.set_dash([])
  inspect(ctx.get_dash_count(), content="0")
}

///|
test "context invalid dash maps to cairo invalid argument" {
  let ctx = Context::new(context_state_surface())
  let negative_result = run_cairo(() => ctx.set_dash([-1.0], offset=0.0))
  inspect(negative_result is Err(_), content="true")
  match negative_result {
    Err(CairoInvalidArgument(InvalidDash, _)) => ()
    _ => @test.fail("expected InvalidDash")
  }

  let zero_result = run_cairo(() => ctx.set_dash([0.0, 0.0], offset=0.0))
  inspect(zero_result is Err(_), content="true")
  match zero_result {
    Err(CairoInvalidArgument(InvalidDash, _)) => ()
    _ => @test.fail("expected InvalidDash")
  }
}

///|
test "context drawing state getters propagate cairo error" {
  let ctx = Context::new(context_state_surface())
  let set_result = run_cairo(() => ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0)))
  inspect(set_result is Err(_), content="true")
  let get_result = run_cairo(() => ctx.get_line_width())
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
  let get_hairline_result = run_cairo(() => ctx.get_hairline())
  inspect(get_hairline_result is Err(_), content="true")
  match get_hairline_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
  let set_hairline_result = run_cairo(() => ctx.set_hairline(true))
  inspect(set_hairline_result is Err(_), content="true")
  match set_hairline_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
