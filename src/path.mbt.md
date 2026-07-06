# Path

`Path` is an owned snapshot of Cairo path data returned by
`Context::copy_path` or `Context::copy_path_flat`. It cannot be constructed
directly from MoonBit user code.

pycairo exposes path iteration as `(PathDataType, tuple[float, ...])` pairs.
cairoon uses a typed `PathSegment` enum and provides `components()` when code
needs the pycairo-like data/type split.

## Segments

```mbt check
///|
test "path docs: copy path exposes typed segments" {
  let ctx = Context::new(Surface::image(Argb32, 16, 16))
  ctx.move_to(1.0, 2.0)
  ctx.line_to(5.0, 2.0)
  ctx.curve_to(6.0, 3.0, 7.0, 4.0, 8.0, 5.0)

  let path = ctx.copy_path()
  inspect(path.status().is_success(), content="true")
  inspect(path.length(), content="3")
  debug_inspect(
    path.segments(),
    content="[\n  PathSegmentMoveTo(1, 2),\n  PathSegmentLineTo(5, 2),\n  PathSegmentCurveTo(6, 3, 7, 4, 8, 5),\n]",
  )
  debug_inspect(
    path.iter().to_array().map(segment => segment.components()),
    content="[\n  (PathMoveTo, [1, 2]),\n  (PathLineTo, [5, 2]),\n  (PathCurveTo, [6, 3, 7, 4, 8, 5]),\n]",
  )
}
```

## String Form

`Path::to_string` mirrors pycairo's `Path.__str__` formatting. This is useful
for debugging and for parity checks, but program logic should prefer
`segments()` or `iter()`.

```mbt check
///|
test "path docs: string form mirrors pycairo formatting" {
  let ctx = Context::new(Surface::image(Argb32, 16, 16))
  ctx.line_to(1.0, 2.0)
  ctx.line_to(2.0, 3.0)

  inspect(
    ctx.copy_path().to_string(),
    content="move_to 1.000000 2.000000\nline_to 2.000000 3.000000",
  )
}
```

## Flatten And Append

`copy_path_flat` converts curves into line segments. The resulting path remains
an owned Cairo path object and can be appended to any compatible context.

```mbt check
///|
test "path docs: flattened paths append without curve segments" {
  let source = Context::new(Surface::image(Argb32, 24, 24))
  source.move_to(1.0, 1.0)
  source.curve_to(2.0, 3.0, 4.0, 5.0, 6.0, 7.0)

  let original = source.copy_path()
  inspect(
    original.segments().any(segment => segment.data_type() == PathCurveTo),
    content="true",
  )

  let flat = source.copy_path_flat()
  inspect(
    flat.segments().any(segment => segment.data_type() == PathCurveTo),
    content="false",
  )
  inspect(
    flat.segments().any(segment => segment.data_type() == PathLineTo),
    content="true",
  )

  let target = Context::new(Surface::image(Argb32, 24, 24))
  target.append_path(flat)
  let appended = target.copy_path()
  inspect(appended.length() > 1, content="true")
  inspect(
    appended.segments().any(segment => segment.data_type() == PathCurveTo),
    content="false",
  )
}
```

## Ownership And Errors

A copied path is independent of the source context. APIs that fail map Cairo
statuses into checked `CairoError` suberrors instead of exposing raw status
integers.

```mbt check
///|
test "path docs: copied paths are independent and errors are checked" {
  let source = Context::new(Surface::image(Argb32, 20, 20))
  source.rectangle(2.0, 3.0, 4.0, 5.0)
  let path = source.copy_path()
  source.new_path()
  debug_inspect(source.path_extents(), content="(0, 0, 0, 0)")

  let target = Context::new(Surface::image(Argb32, 20, 20))
  target.append_path(path)
  debug_inspect(target.path_extents(), content="(2, 3, 6, 8)")

  let broken = Context::new(Surface::image(Argb32, 20, 20))
  match run_cairo(() => broken.set_matrix(Matrix::new(xx=0.0, yy=0.0))) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from set_matrix")
  }

  let copy_result = run_cairo(() => {
    let _ = broken.copy_path()
    ()
  })
  match copy_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from copy_path")
  }

  match run_cairo(() => broken.append_path(path)) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from append_path")
  }
}
```
