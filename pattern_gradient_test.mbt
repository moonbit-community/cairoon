///|
test "linear gradient points and color stops" {
  let pattern = Pattern::linear(1.0, 2.0, 4.0, 5.0)
  debug_inspect(pattern.get_linear_points(), content="(1, 2, 4, 5)")
  inspect(pattern.get_color_stop_count(), content="0")

  pattern.add_color_stop_rgb(0.125, 0.25, 0.5, 0.75)
  pattern.add_color_stop_rgba(1.0, 0.75, 0.5, 0.25, 0.125)
  inspect(pattern.get_color_stop_count(), content="2")
  debug_inspect(
    pattern.get_color_stop_rgba(0),
    content="(0.125, 0.25, 0.5, 0.75, 1)",
  )
  debug_inspect(
    pattern.get_color_stop_rgba(1),
    content="(1, 0.75, 0.5, 0.25, 0.125)",
  )
  let stops = pattern.get_color_stops_rgba()
  inspect(stops.length(), content="2")
  debug_inspect(stops[0], content="(0.125, 0.25, 0.5, 0.75, 1)")
  debug_inspect(stops[1], content="(1, 0.75, 0.5, 0.25, 0.125)")
}

///|
test "gradient color stop snapshots preserve duplicate offset insertion order" {
  let pattern = Pattern::linear(0.0, 0.0, 1.0, 0.0)
  pattern.add_color_stop_rgba(0.5, 1.0, 0.0, 0.0, 1.0)
  pattern.add_color_stop_rgba(0.5, 0.0, 1.0, 0.0, 0.75)
  pattern.add_color_stop_rgba(0.5, 0.0, 0.0, 1.0, 0.5)

  let stops = pattern.get_color_stops_rgba()
  inspect(stops.length(), content="3")
  debug_inspect(stops[0], content="(0.5, 1, 0, 0, 1)")
  debug_inspect(stops[1], content="(0.5, 0, 1, 0, 0.75)")
  debug_inspect(stops[2], content="(0.5, 0, 0, 1, 0.5)")

  pattern.add_color_stop_rgba(0.75, 0.25, 0.5, 0.75, 1.0)
  inspect(stops.length(), content="3")
  inspect(pattern.get_color_stop_count(), content="4")
}

///|
test "radial gradient circles and color stops" {
  let pattern = Pattern::radial(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  debug_inspect(pattern.get_radial_circles(), content="(1, 2, 3, 4, 5, 6)")
  pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
  pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0)
  inspect(pattern.get_color_stop_count(), content="2")
}

///|
test "gradient queries map pattern type mismatches" {
  let solid = Pattern::solid_rgb(0.0, 0.0, 0.0)
  let count_result = run_cairo(() => solid.get_color_stop_count())
  inspect(count_result is Err(_), content="true")
  match count_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let linear = Pattern::linear(0.0, 0.0, 1.0, 1.0)
  let radial_result = run_cairo(() => linear.get_radial_circles())
  inspect(radial_result is Err(_), content="true")
  match radial_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let radial = Pattern::radial(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
  let linear_result = run_cairo(() => radial.get_linear_points())
  inspect(linear_result is Err(_), content="true")
  match linear_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "gradient invalid color stop index maps to cairo invalid argument" {
  let pattern = Pattern::linear(0.0, 0.0, 1.0, 1.0)
  let result = run_cairo(() => pattern.get_color_stop_rgba(0))
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}
