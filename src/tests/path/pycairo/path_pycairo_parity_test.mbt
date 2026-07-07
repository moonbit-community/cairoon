///|
fn pycairo_path_context() -> @cairoon.Context raise @cairoon.CairoError {
  @cairoon.Context::new(@cairoon.Surface::image(@cairoon.Argb32, 42, 42))
}

///|
test "pycairo path empty string fixture" {
  let ctx = pycairo_path_context()
  let path = ctx.copy_path()
  inspect(path.to_string(), content="")
  inspect(path.length(), content="0")
  inspect(path.segments().length(), content="0")
}

///|
test "pycairo path string fixture" {
  let ctx = pycairo_path_context()
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

  ctx.new_path()
  ctx.line_to(1.0, 2.0)
  ctx.close_path()
  inspect(
    ctx.copy_path().to_string(),
    content="move_to 1.000000 2.000000\nclose path\nmove_to 1.000000 2.000000",
  )
}

///|
test "pycairo path compare hash fixture" {
  let ctx = pycairo_path_context()
  let path = ctx.copy_path()
  inspect(path == path, content="true")
  inspect(path != path, content="false")
  inspect(path < path, content="false")
  inspect(path <= path, content="true")
  inspect(path >= path, content="true")
  inspect(path > path, content="false")
  inspect(Hash::hash(path) == Hash::hash(path), content="true")
}

///|
test "pycairo path iter fixture" {
  let ctx = pycairo_path_context()
  ctx.line_to(1.0, 2.0)
  ctx.line_to(2.0, 3.0)
  ctx.curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  ctx.close_path()
  let path = ctx.copy_path()
  let items = path.iter().to_array().map(segment => segment.components())
  debug_inspect(
    items,
    content="[\n  (PathMoveTo, [1, 2]),\n  (PathLineTo, [2, 3]),\n  (PathCurveTo, [0, 1, 2, 3, 4, 5]),\n  (PathClosePath, []),\n  (PathMoveTo, [1, 2]),\n]",
  )
  debug_inspect(items[0].0, content="PathMoveTo")
}
