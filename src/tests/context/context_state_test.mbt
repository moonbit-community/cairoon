///|
fn context_state_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(@cairoon.Argb32, 16, 16)
}

///|
fn assert_state_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
test "context default drawing state mirrors cairo" {
  let ctx = @cairoon.Context::new(context_state_surface())
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
  let ctx = @cairoon.Context::new(context_state_surface())
  ctx.set_antialias(@cairoon.AntialiasSubpixel)
  ctx.set_fill_rule(@cairoon.FillEvenOdd)
  ctx.set_line_cap(@cairoon.LineCapSquare)
  ctx.set_line_join(@cairoon.LineJoinBevel)
  ctx.set_operator(@cairoon.OperatorSource)
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
test "context drawing state enum setters cover all cairo values" {
  let ctx = @cairoon.Context::new(context_state_surface())

  let antialiases : Array[@cairoon.Antialias] = [
    @cairoon.AntialiasDefault,
    @cairoon.AntialiasNone,
    @cairoon.AntialiasGray,
    @cairoon.AntialiasSubpixel,
    @cairoon.AntialiasFast,
    @cairoon.AntialiasGood,
    @cairoon.AntialiasBest,
  ]
  for antialias in antialiases {
    ctx.set_antialias(antialias)
    guard ctx.get_antialias() == antialias else {
      @test.fail("antialias did not round trip")
    }
  }

  let fill_rules : Array[@cairoon.FillRule] = [
    @cairoon.FillWinding,
    @cairoon.FillEvenOdd,
  ]
  for fill_rule in fill_rules {
    ctx.set_fill_rule(fill_rule)
    guard ctx.get_fill_rule() == fill_rule else {
      @test.fail("fill rule did not round trip")
    }
  }

  let caps : Array[@cairoon.LineCap] = [
    @cairoon.LineCapButt,
    @cairoon.LineCapRound,
    @cairoon.LineCapSquare,
  ]
  for cap in caps {
    ctx.set_line_cap(cap)
    guard ctx.get_line_cap() == cap else {
      @test.fail("line cap did not round trip")
    }
  }

  let joins : Array[@cairoon.LineJoin] = [
    @cairoon.LineJoinMiter,
    @cairoon.LineJoinRound,
    @cairoon.LineJoinBevel,
  ]
  for join in joins {
    ctx.set_line_join(join)
    guard ctx.get_line_join() == join else {
      @test.fail("line join did not round trip")
    }
  }

  let operators : Array[@cairoon.Operator] = [
    @cairoon.OperatorClear,
    @cairoon.OperatorSource,
    @cairoon.OperatorOver,
    @cairoon.OperatorIn,
    @cairoon.OperatorOut,
    @cairoon.OperatorAtop,
    @cairoon.OperatorDest,
    @cairoon.OperatorDestOver,
    @cairoon.OperatorDestIn,
    @cairoon.OperatorDestOut,
    @cairoon.OperatorDestAtop,
    @cairoon.OperatorXor,
    @cairoon.OperatorAdd,
    @cairoon.OperatorSaturate,
    @cairoon.OperatorMultiply,
    @cairoon.OperatorScreen,
    @cairoon.OperatorOverlay,
    @cairoon.OperatorDarken,
    @cairoon.OperatorLighten,
    @cairoon.OperatorColorDodge,
    @cairoon.OperatorColorBurn,
    @cairoon.OperatorHardLight,
    @cairoon.OperatorSoftLight,
    @cairoon.OperatorDifference,
    @cairoon.OperatorExclusion,
    @cairoon.OperatorHslHue,
    @cairoon.OperatorHslSaturation,
    @cairoon.OperatorHslColor,
    @cairoon.OperatorHslLuminosity,
  ]
  for operator in operators {
    ctx.set_operator(operator)
    guard ctx.get_operator() == operator else {
      @test.fail("operator did not round trip")
    }
  }
}

///|
test "context raw operator mirrors pycairo c int passthrough" {
  let ctx = @cairoon.Context::new(context_state_surface())
  ctx.set_operator(@cairoon.OperatorOver)
  inspect(ctx.get_operator_raw(), content="2")

  let min_c_int = -2147483647 - 1
  let values = [-1, 0, 2147483647, min_c_int]
  for value in values {
    ctx.set_operator_raw(value)
    inspect(ctx.get_operator_raw(), content="\{value}")
  }

  let typed_unknown = @cairoon.run_cairo(() => ctx.get_operator())
  match typed_unknown {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw operator")
  }

  ctx.set_operator_raw(0)
  debug_inspect(ctx.get_operator(), content="OperatorClear")
}

///|
test "context raw drawing state enums mirror pycairo c int passthrough" {
  let antialias_ctx = @cairoon.Context::new(context_state_surface())
  antialias_ctx.set_antialias(@cairoon.AntialiasGood)
  inspect(antialias_ctx.get_antialias_raw(), content="5")
  antialias_ctx.set_antialias_raw(42)
  inspect(antialias_ctx.get_antialias_raw(), content="42")
  match @cairoon.run_cairo(() => antialias_ctx.get_antialias()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw antialias")
  }
  antialias_ctx.set_antialias_raw(0)
  debug_inspect(antialias_ctx.get_antialias(), content="AntialiasDefault")

  let fill_rule_ctx = @cairoon.Context::new(context_state_surface())
  fill_rule_ctx.set_fill_rule(@cairoon.FillEvenOdd)
  inspect(fill_rule_ctx.get_fill_rule_raw(), content="1")
  fill_rule_ctx.set_fill_rule_raw(42)
  inspect(fill_rule_ctx.get_fill_rule_raw(), content="42")
  match @cairoon.run_cairo(() => fill_rule_ctx.get_fill_rule()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw fill rule")
  }
  fill_rule_ctx.set_fill_rule_raw(0)
  debug_inspect(fill_rule_ctx.get_fill_rule(), content="FillWinding")

  let line_cap_ctx = @cairoon.Context::new(context_state_surface())
  line_cap_ctx.set_line_cap(@cairoon.LineCapRound)
  inspect(line_cap_ctx.get_line_cap_raw(), content="1")
  line_cap_ctx.set_line_cap_raw(42)
  inspect(line_cap_ctx.get_line_cap_raw(), content="42")
  match @cairoon.run_cairo(() => line_cap_ctx.get_line_cap()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw line cap")
  }
  line_cap_ctx.set_line_cap_raw(2)
  debug_inspect(line_cap_ctx.get_line_cap(), content="LineCapSquare")

  let line_join_ctx = @cairoon.Context::new(context_state_surface())
  line_join_ctx.set_line_join(@cairoon.LineJoinBevel)
  inspect(line_join_ctx.get_line_join_raw(), content="2")
  line_join_ctx.set_line_join_raw(42)
  inspect(line_join_ctx.get_line_join_raw(), content="42")
  match @cairoon.run_cairo(() => line_join_ctx.get_line_join()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw line join")
  }
  line_join_ctx.set_line_join_raw(1)
  debug_inspect(line_join_ctx.get_line_join(), content="LineJoinRound")
}

///|
test "context save restore preserves drawing state" {
  let ctx = @cairoon.Context::new(context_state_surface())
  ctx.set_line_width(3.0)
  ctx.set_operator(@cairoon.OperatorOver)
  ctx.set_hairline(true)
  ctx.save()
  ctx.set_hairline(false)
  ctx.set_line_width(7.0)
  ctx.set_operator(@cairoon.OperatorClear)
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
  let ctx = @cairoon.Context::new(context_state_surface())
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
  let ctx = @cairoon.Context::new(context_state_surface())
  let negative_result = @cairoon.run_cairo(() => {
    ctx.set_dash([-1.0], offset=0.0)
  })
  inspect(negative_result is Err(_), content="true")
  match negative_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidDash, _)) => ()
    _ => @test.fail("expected InvalidDash")
  }

  let zero_result = @cairoon.run_cairo(() => {
    ctx.set_dash([0.0, 0.0], offset=0.0)
  })
  inspect(zero_result is Err(_), content="true")
  match zero_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidDash, _)) => ()
    _ => @test.fail("expected InvalidDash")
  }
}

///|
test "context invalid restore maps to cairo error" {
  let ctx = @cairoon.Context::new(context_state_surface())
  debug_inspect(ctx.status(), content="Success")
  let result = @cairoon.run_cairo(() => ctx.restore())
  inspect(result is Err(_), content="true")
  debug_inspect(ctx.status(), content="InvalidRestore")
  match result {
    Err(@cairoon.CairoError(@cairoon.InvalidRestore, _)) => ()
    _ => @test.fail("expected InvalidRestore")
  }
}

///|
test "context drawing state getters propagate cairo error" {
  let ctx = @cairoon.Context::new(context_state_surface())
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")
  let get_result = @cairoon.run_cairo(() => ctx.get_line_width())
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
  let get_hairline_result = @cairoon.run_cairo(() => ctx.get_hairline())
  inspect(get_hairline_result is Err(_), content="true")
  match get_hairline_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
  let set_hairline_result = @cairoon.run_cairo(() => ctx.set_hairline(true))
  inspect(set_hairline_result is Err(_), content="true")
  match set_hairline_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
