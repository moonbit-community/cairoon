# Pattern

`Pattern` is one opaque MoonBit owner for Cairo's solid, surface, gradient,
mesh, and raster-source pattern families. pycairo exposes several subclasses;
cairoon keeps one `Pattern` type and uses constructor and method names to make
the intended subtype explicit.

Subtype-specific queries raise `CairoError` when used with the wrong pattern
kind. Pattern objects are safe to pass to `Context::set_source`; patterns that
borrow a surface retain the MoonBit surface wrapper for as long as Cairo can use
it.

## Solid Patterns And State

Pattern state such as extend mode, filter, dither, and matrix is shared across
pattern families.

```mbt check
///|
test "pattern docs: solid rgba and shared pattern state" {
  let pattern = Pattern::solid_rgba(0.125, 0.25, 0.5, 0.75)
  debug_inspect(pattern.get_rgba(), content="(0.125, 0.25, 0.5, 0.75)")

  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  pattern.set_dither(DitherBest)
  pattern.set_matrix(Matrix::new(xx=0.5, yy=0.25, x0=3.0, y0=5.0))

  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  debug_inspect(pattern.get_dither(), content="DitherBest")
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 0.5, yx: 0, xy: 0, yy: 0.25, x0: 3, y0: 5 }",
  )
}
```

pycairo accepts C `int` values for pattern enum setters. cairoon keeps the
ordinary MoonBit API typed, and exposes explicit `*_raw` methods when porting
code needs that integer round trip. Typed getters reject unknown raw values
instead of manufacturing an enum constructor.

```mbt check
///|
test "pattern docs: raw enum compatibility is explicit" {
  let pattern = Pattern::solid_rgb(1.0, 0.0, 0.0)

  pattern.set_extend_raw(42)
  inspect(pattern.get_extend_raw(), content="42")
  match run_cairo(() => pattern.get_extend()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected unknown raw extend to stay outside typed API")
  }

  pattern.set_filter_raw(3)
  debug_inspect(pattern.get_filter(), content="Nearest")
  pattern.set_filter_raw(42)
  inspect(pattern.get_filter_raw(), content="42")
  match run_cairo(() => pattern.get_filter()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected unknown raw filter to stay outside typed API")
  }

  pattern.set_dither_raw(4)
  debug_inspect(pattern.get_dither(), content="DitherBest")
  pattern.set_dither_raw(42)
  inspect(pattern.get_dither_raw(), content="42")
  match run_cairo(() => pattern.get_dither()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected unknown raw dither to stay outside typed API")
  }
}
```

## Surface Patterns

`Pattern::for_surface` maps pycairo's `SurfacePattern` constructor. The pattern
retains the surface wrapper, and `get_surface` returns a referenced `Surface`
wrapper for the same Cairo source.

```mbt check
///|
test "pattern docs: surface pattern paints and exposes source surface" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let pattern = Pattern::for_surface(source)
  let returned = pattern.get_surface()
  inspect(returned.get_width(), content="1")
  inspect(returned.get_height(), content="1")

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}
```

## Gradients

Linear and radial gradients store color stops in Cairo order:
`(offset, red, green, blue, alpha)`.

```mbt check
///|
test "pattern docs: gradients expose geometry and color stops" {
  let linear = Pattern::linear(1.0, 2.0, 4.0, 5.0)
  debug_inspect(linear.get_linear_points(), content="(1, 2, 4, 5)")
  linear.add_color_stop_rgb(0.125, 0.25, 0.5, 0.75)
  linear.add_color_stop_rgba(1.0, 0.75, 0.5, 0.25, 0.125)

  inspect(linear.get_color_stop_count(), content="2")
  debug_inspect(
    linear.get_color_stops_rgba(),
    content="[(0.125, 0.25, 0.5, 0.75, 1), (1, 0.75, 0.5, 0.25, 0.125)]",
  )

  let radial = Pattern::radial(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  debug_inspect(radial.get_radial_circles(), content="(1, 2, 3, 4, 5, 6)")
}
```

## Mesh Patterns

Mesh construction follows Cairo's begin/end patch lifecycle. After a patch is
closed, callers can inspect its path and corner/control values.

```mbt check
///|
test "pattern docs: mesh patch exposes path and corner colors" {
  let pattern = Pattern::mesh()
  inspect(pattern.mesh_get_patch_count(), content="0")

  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(2.0, 0.0)
  pattern.mesh_line_to(0.0, 2.0)
  pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(1, 0.0, 1.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(2, 0.0, 0.0, 1.0, 0.5)
  pattern.mesh_set_control_point(0, 0.25, 0.5)
  pattern.mesh_end_patch()

  inspect(pattern.mesh_get_patch_count(), content="1")
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 2),
    content="(0, 0, 1, 0.5)",
  )
  debug_inspect(pattern.mesh_get_control_point(0, 0), content="(0.25, 0.5)")
  let path = pattern.mesh_get_path(0)
  inspect(path.length() > 0, content="true")
  debug_inspect(path.segments()[0].data_type(), content="PathMoveTo")
}
```

## Raster Sources

Raster-source acquire callbacks receive the target surface and requested
extents. If a release callback is supplied, Cairo calls it with the acquired
surface after the paint operation. `Pattern::raster_source_raw` mirrors
pycairo's C-int `Content` constructor argument.

```mbt check
///|
test "pattern docs: raster source callback paints and releases" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let target_width = Ref(0)
  let released_height = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  let raw_pattern = Pattern::raster_source_raw(0x3000, 1, 1)
  debug_inspect(raw_pattern.status(), content="Success")
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      target_width.val = try! target.get_width()
      extent_width.val = extents.width
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_height.val = try! surface.get_height()
    }),
  )

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val == acquire_calls.val, content="true")
  inspect(extent_width.val > 0, content="true")
  inspect(target_width.val, content="1")
  inspect(released_height.val, content="1")
}
```

## Checked Subtype Errors

Subtype-specific methods do not silently return placeholder values. Wrong
pattern kinds and invalid indexes are mapped into checked `CairoError`
suberrors.

```mbt check
///|
test "pattern docs: subtype and index errors are checked" {
  let solid = Pattern::solid_rgb(0.0, 0.0, 0.0)
  match run_cairo(() => solid.get_color_stop_count()) {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let linear = Pattern::linear(0.0, 0.0, 1.0, 1.0)
  match run_cairo(() => linear.get_color_stop_rgba(0)) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }

  let mesh = Pattern::mesh()
  mesh.mesh_begin_patch()
  match run_cairo(() => mesh.mesh_begin_patch()) {
    Err(CairoError(InvalidMeshConstruction, _)) => ()
    _ => @test.fail("expected InvalidMeshConstruction")
  }
}
```
