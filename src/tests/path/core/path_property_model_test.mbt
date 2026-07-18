///|
fn path_property_coordinate(seed : Int, step : Int, salt : Int) -> Double {
  ((seed * 31 + step * 17 + salt * 13) % 41 - 20).to_double() / 4.0
}

///|
fn path_property_assert_point(
  actual : (Double, Double),
  expected : (Double, Double),
  case : String,
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  if !actual_x.is_close(expected_x, absolute_tolerance=0.000001) ||
    !actual_y.is_close(expected_y, absolute_tolerance=0.000001) {
    @test.fail(
      "path current point diverged for \{case}: expected (\{expected_x}, \{expected_y}), got (\{actual_x}, \{actual_y})",
    )
  }
}

///|
fn path_property_segment_codes(
  segments : ArrayView[@cairoon.PathSegment],
) -> String {
  let builder = StringBuilder()
  for segment in segments {
    builder.write_string(
      match segment {
        PathSegmentMoveTo(_, _) => "M"
        PathSegmentLineTo(_, _) => "L"
        PathSegmentCurveTo(_, _, _, _, _, _) => "C"
        PathSegmentClosePath => "Z"
      },
    )
  }
  builder.to_string()
}

///|
fn path_property_assert_segments(
  actual : Array[@cairoon.PathSegment],
  expected : Array[@cairoon.PathSegment],
  case : String,
) -> Unit raise {
  if actual.length() != expected.length() {
    @test.fail(
      "path segment count diverged for \{case}: expected \{expected.length()} (\{path_property_segment_codes(expected)}), got \{actual.length()} (\{path_property_segment_codes(actual)})",
    )
  }
  for index in 0..<actual.length() {
    if actual[index] != expected[index] {
      @test.fail("path segment \{index} diverged for \{case}")
    }
  }
}

///|
fn path_property_new_context() -> @cairoon.Context raise @cairoon.CairoError {
  @cairoon.Context::new(@cairoon.Surface::image(Argb32, 8, 8))
}

///|
fn path_property_push_move(
  segments : Array[@cairoon.PathSegment],
  x : Double,
  y : Double,
) -> Unit {
  if segments.length() > 0 {
    let last = segments.length() - 1
    match segments[last] {
      PathSegmentMoveTo(_, _) => segments[last] = PathSegmentMoveTo(x, y)
      _ => segments.push(PathSegmentMoveTo(x, y))
    }
  } else {
    segments.push(PathSegmentMoveTo(x, y))
  }
}

///|
fn path_property_canonicalize_replay(
  segments : ArrayView[@cairoon.PathSegment],
) -> Array[@cairoon.PathSegment] {
  let canonical : Array[@cairoon.PathSegment] = []
  let mut previous : (Double, Double)? = None
  let mut current : (Double, Double)? = None
  let mut last_was_line = false
  for segment in segments {
    match segment {
      PathSegmentMoveTo(x, y) => {
        path_property_push_move(canonical, x, y)
        previous = None
        current = Some((x, y))
        last_was_line = false
      }
      PathSegmentLineTo(x, y) => {
        let mut folded = false
        if last_was_line {
          match (previous, current) {
            (Some((ax, ay)), Some((bx, by))) => {
              let abx = bx - ax
              let aby = by - ay
              let bcx = x - bx
              let bcy = y - by
              let cross = abx * bcy - aby * bcx
              let dot = abx * bcx + aby * bcy
              if cross.is_close(0.0, absolute_tolerance=0.000001) && dot >= 0.0 {
                canonical[canonical.length() - 1] = PathSegmentLineTo(x, y)
                current = Some((x, y))
                folded = true
              }
            }
            _ => ()
          }
        }
        if !folded {
          canonical.push(segment)
          previous = current
          current = Some((x, y))
          last_was_line = true
        }
      }
      PathSegmentCurveTo(_, _, _, _, x, y) => {
        canonical.push(segment)
        previous = None
        current = Some((x, y))
        last_was_line = false
      }
      PathSegmentClosePath => {
        canonical.push(segment)
        previous = None
        current = None
        last_was_line = false
      }
    }
  }
  canonical
}

///|
fn path_property_build_model(
  seed : Int,
) -> (
  @cairoon.Context,
  @cairoon.Path,
  Array[@cairoon.PathSegment],
  (Double, Double),
) raise @cairoon.CairoError {
  let context = path_property_new_context()
  let expected : Array[@cairoon.PathSegment] = []
  let mut current_x = path_property_coordinate(seed, 0, 0)
  let mut current_y = path_property_coordinate(seed, 0, 1)
  let mut start_x = current_x
  let mut start_y = current_y
  context.move_to(current_x, current_y)
  path_property_push_move(expected, current_x, current_y)

  for step in 0..<18 {
    match (seed + step) % 6 {
      0 => {
        current_x = path_property_coordinate(seed, step, 2)
        current_y = path_property_coordinate(seed, step, 3)
        context.line_to(current_x, current_y)
        expected.push(PathSegmentLineTo(current_x, current_y))
      }
      1 => {
        let dx = path_property_coordinate(seed, step, 4) / 2.0
        let dy = path_property_coordinate(seed, step, 5) / 2.0
        context.rel_line_to(dx, dy)
        current_x += dx
        current_y += dy
        expected.push(PathSegmentLineTo(current_x, current_y))
      }
      2 => {
        let x1 = path_property_coordinate(seed, step, 6)
        let y1 = path_property_coordinate(seed, step, 7)
        let x2 = path_property_coordinate(seed, step, 8)
        let y2 = path_property_coordinate(seed, step, 9)
        let x3 = path_property_coordinate(seed, step, 10)
        let y3 = path_property_coordinate(seed, step, 11)
        context.curve_to(x1, y1, x2, y2, x3, y3)
        expected.push(PathSegmentCurveTo(x1, y1, x2, y2, x3, y3))
        current_x = x3
        current_y = y3
      }
      3 => {
        let dx1 = path_property_coordinate(seed, step, 12) / 2.0
        let dy1 = path_property_coordinate(seed, step, 13) / 2.0
        let dx2 = path_property_coordinate(seed, step, 14) / 2.0
        let dy2 = path_property_coordinate(seed, step, 15) / 2.0
        let dx3 = path_property_coordinate(seed, step, 16) / 2.0
        let dy3 = path_property_coordinate(seed, step, 17) / 2.0
        context.rel_curve_to(dx1, dy1, dx2, dy2, dx3, dy3)
        expected.push(
          PathSegmentCurveTo(
            current_x + dx1,
            current_y + dy1,
            current_x + dx2,
            current_y + dy2,
            current_x + dx3,
            current_y + dy3,
          ),
        )
        current_x += dx3
        current_y += dy3
      }
      4 => {
        context.close_path()
        expected.push(PathSegmentClosePath)
        expected.push(PathSegmentMoveTo(start_x, start_y))
        current_x = start_x
        current_y = start_y
      }
      _ => {
        context.new_sub_path()
        current_x = path_property_coordinate(seed, step, 18)
        current_y = path_property_coordinate(seed, step, 19)
        start_x = current_x
        start_y = current_y
        context.move_to(current_x, current_y)
        path_property_push_move(expected, current_x, current_y)
      }
    }
  }
  let path = context.copy_path()
  (context, path, expected, (current_x, current_y))
}

///|
fn path_property_assert_roundtrip(
  path : @cairoon.Path,
  expected : Array[@cairoon.PathSegment],
  current : (Double, Double),
  case : String,
) -> Unit raise {
  path_property_assert_segments(path.segments(), expected, case)
  if path.length() != expected.length() {
    @test.fail("Path::length diverged from segments for \{case}")
  }
  let replay = path_property_new_context()
  replay.append_path(path)
  path_property_assert_segments(
    replay.copy_path().segments(),
    expected,
    "replayed \{case}",
  )
  path_property_assert_point(
    replay.get_current_point(),
    current,
    "replayed \{case}",
  )
}
