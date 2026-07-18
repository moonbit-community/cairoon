///|
fn path_test_context() -> @cairoon.Context raise @cairoon.CairoError {
  @cairoon.Context::new(@cairoon.Surface::image(Argb32, 42, 42))
}

///|
fn copied_path_from_local_context() -> @cairoon.Path raise @cairoon.CairoError {
  let ctx = path_test_context()
  ctx.move_to(1.0, 2.0)
  ctx.line_to(3.0, 4.0)
  ctx.copy_path()
}

///|
test "path empty string segments and length" {
  let ctx = path_test_context()
  let path = ctx.copy_path()
  inspect(path.length(), content="0")
  inspect(path.segments().length(), content="0")
  inspect(path.iter().to_array().length(), content="0")
  inspect(path.to_string(), content="")
}

///|
test "path string mirrors pycairo path formatting" {
  let ctx = path_test_context()
  ctx.line_to(1.0, 2.0)
  inspect(ctx.copy_path().to_string(), content="move_to 1.000000 2.000000")

  ctx.line_to(1.0, 2.0)
  inspect(
    ctx.copy_path().to_string(),
    content="move_to 1.000000 2.000000\nline_to 1.000000 2.000000",
  )

  ctx.new_path()
  ctx.curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  inspect(
    ctx.copy_path().to_string(),
    content="move_to 0.000000 1.000000\ncurve_to 0.000000 1.000000 2.000000 3.000000 4.000000 5.000000",
  )
}

///|
test "path string includes pycairo close path continuation" {
  let ctx = path_test_context()
  ctx.line_to(1.0, 2.0)
  ctx.close_path()
  inspect(
    ctx.copy_path().to_string(),
    content="move_to 1.000000 2.000000\nclose path\nmove_to 1.000000 2.000000",
  )
}

///|
test "path copy survives source context scope" {
  let path = copied_path_from_local_context()
  inspect(path.length(), content="2")
  inspect(
    path.to_string(),
    content="move_to 1.000000 2.000000\nline_to 3.000000 4.000000",
  )
}

///|
test "path segments mirror pycairo iterator data" {
  let ctx = path_test_context()
  ctx.line_to(1.0, 2.0)
  ctx.line_to(2.0, 3.0)
  ctx.curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  ctx.close_path()
  let path = ctx.copy_path()
  inspect(path.length(), content="5")
  debug_inspect(
    path.segments(),
    content="[\n  PathSegmentMoveTo(1, 2),\n  PathSegmentLineTo(2, 3),\n  PathSegmentCurveTo(0, 1, 2, 3, 4, 5),\n  PathSegmentClosePath,\n  PathSegmentMoveTo(1, 2),\n]",
  )
  debug_inspect(
    path.iter().to_array().map(segment => segment.components()),
    content="[\n  (PathMoveTo, [1, 2]),\n  (PathLineTo, [2, 3]),\n  (PathCurveTo, [0, 1, 2, 3, 4, 5]),\n  (PathClosePath, []),\n  (PathMoveTo, [1, 2]),\n]",
  )
}

///|
test "path flattened copy exposes line segments instead of curves" {
  let ctx = path_test_context()
  ctx.move_to(1.0, 1.0)
  ctx.curve_to(2.0, 3.0, 4.0, 5.0, 6.0, 7.0)
  let flat = ctx.copy_path_flat()
  inspect(
    flat.segments().any(segment => segment.data_type() == PathCurveTo),
    content="false",
  )
  inspect(
    flat.segments().any(segment => segment.data_type() == PathLineTo),
    content="true",
  )
}

///|
test "path equality and hash use cairo path identity" {
  let ctx = path_test_context()
  ctx.rectangle(1.0, 1.0, 3.0, 3.0)
  let first = ctx.copy_path()
  let second = ctx.copy_path()
  inspect(first.equal(first), content="true")
  inspect(first.equal(second), content="false")
  let zero : UInt64 = 0
  inspect(first.hash() == zero, content="false")
}
