# Context

`Context` owns a `cairo_t *` drawing state. A context retains its target
`Surface`, so drawing remains valid even when the original surface binding is
only reachable through the context.

Most mutating operations can observe Cairo status and therefore raise
`CairoError`. Query methods also check the current context status before
returning state. Raw C-int enum methods are compatibility APIs for pycairo's C
glue; prefer typed methods unless porting code that intentionally passes or
observes raw Cairo enum values.

## Construction And Drawing State

`Context::new` maps pycairo's `Context(surface)` constructor. Drawing state can
be queried, changed, saved, and restored. The normal MoonBit API keeps
antialias, fill-rule, line-cap, line-join, and operator state typed. Matching
`*_raw` methods exist only for pycairo compatibility with raw C `int` enum
values. If a raw value is not a known Cairo enum value, the raw getter can still
report it but the typed getter raises `CairoInvalidArgument(InvalidStatus, _)`.

```mbt check
///|
test "context docs: construction state save restore and dash" {
  let surface = Surface::image(Argb32, 8, 8)
  let ctx = Context::new(surface)
  inspect(ctx.get_target().equal(surface), content="true")
  debug_inspect(ctx.get_operator(), content="OperatorOver")
  debug_inspect(ctx.get_line_cap(), content="LineCapButt")
  inspect(ctx.get_dash_count(), content="0")

  ctx.set_operator(OperatorSource)
  ctx.set_operator_raw(1)
  inspect(ctx.get_operator_raw(), content="1")
  ctx.set_line_cap_raw(42)
  inspect(ctx.get_line_cap_raw(), content="42")
  match run_cairo(() => ctx.get_line_cap()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected unknown raw line cap to stay outside typed API")
  }
  ctx.set_line_cap_raw(1)
  ctx.set_line_width(4.0)
  ctx.set_line_cap(LineCapRound)
  ctx.set_dash([2.0, 1.0], offset=0.5)
  inspect(ctx.get_dash_count(), content="2")
  let (dashes, offset) = ctx.get_dash()
  debug_inspect(dashes, content="[2, 1]")
  inspect(offset, content="0.5")

  ctx.save()
  ctx.set_operator(OperatorClear)
  ctx.set_line_cap(LineCapSquare)
  debug_inspect(ctx.get_operator(), content="OperatorClear")
  debug_inspect(ctx.get_line_cap(), content="LineCapSquare")
  ctx.restore()
  debug_inspect(ctx.get_operator(), content="OperatorSource")
  debug_inspect(ctx.get_line_cap(), content="LineCapRound")
}
```

## Transformations

Context transformations mutate the current transformation matrix. Coordinate
conversion helpers expose the same Cairo user/device mapping pycairo exposes.

```mbt check
///|
test "context docs: transforms and coordinate conversion" {
  let ctx = Context::new(Surface::image(Argb32, 16, 16))
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  debug_inspect(ctx.user_to_device(1.0, 1.0), content="(7, 10)")
  debug_inspect(ctx.user_to_device_distance(2.0, 2.0), content="(4, 6)")
  debug_inspect(ctx.device_to_user(7.0, 10.0), content="(1, 1)")
  debug_inspect(ctx.device_to_user_distance(4.0, 6.0), content="(2, 2)")

  ctx.identity_matrix()
  debug_inspect(ctx.user_to_device(1.0, 1.0), content="(1, 1)")

  ctx.transform(Matrix::new(xx=2.0, yy=2.0, x0=3.0, y0=4.0))
  debug_inspect(
    ctx.get_matrix(),
    content="{ xx: 2, yx: 0, xy: 0, yy: 2, x0: 3, y0: 4 }",
  )
}
```

## Paths And Extents

Path methods mirror Cairo's current-path state machine. Relative operations
require a current point; `copy_path` returns an owned `Path` that can be
appended to another context.

```mbt check
///|
test "context docs: path construction copy append and extents" {
  let source = Context::new(Surface::image(Argb32, 16, 16))
  inspect(source.has_current_point(), content="false")
  source.move_to(2.0, 3.0)
  source.rel_line_to(4.0, 0.0)
  source.line_to(6.0, 8.0)
  source.close_path()
  inspect(source.has_current_point(), content="true")
  debug_inspect(source.get_current_point(), content="(2, 3)")
  debug_inspect(source.path_extents(), content="(2, 3, 6, 8)")

  let path = source.copy_path()
  source.new_path()
  debug_inspect(source.path_extents(), content="(0, 0, 0, 0)")

  let target = Context::new(Surface::image(Argb32, 16, 16))
  target.append_path(path)
  debug_inspect(target.path_extents(), content="(2, 3, 6, 8)")
  inspect(target.in_fill(3.0, 4.0), content="true")
}
```

## Painting, Filling, And Stroking

Painting uses the current source. Fill and stroke operations consume the current
path unless the `_preserve` variant is used.

```mbt check
///|
test "context docs: paint fill preserve stroke and pixel output" {
  let surface = Surface::image(Argb32, 4, 4)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.rectangle(1.0, 1.0, 2.0, 2.0)
  debug_inspect(ctx.fill_extents(), content="(1, 1, 3, 3)")
  ctx.fill_preserve()
  inspect(ctx.has_current_point(), content="true")

  let filled = surface.copy_data()
  let stride = surface.get_stride()
  let center = stride * 2 + 8
  inspect(filled[center].to_int(), content="0")
  inspect(filled[center + 1].to_int(), content="0")
  inspect(filled[center + 2].to_int(), content="255")
  inspect(filled[center + 3].to_int(), content="255")

  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.set_line_width(1.0)
  ctx.stroke()
  inspect(ctx.has_current_point(), content="false")
}
```

## Clipping

Clip APIs expose rectangular clip lists when Cairo can represent the clip as
rectangles. Non-rectangular clips raise `ClipNotRepresentable` through the
normal checked error path. `Rectangle` supports checked index syntax in
pycairo tuple order: x, y, width, then height.

```mbt check
///|
test "context docs: clip extents rectangle lists and reset" {
  let ctx = Context::new(Surface::image(Argb32, 20, 20))
  debug_inspect(ctx.clip_extents(), content="(0, 0, 20, 20)")
  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  ctx.clip_preserve()
  debug_inspect(ctx.clip_extents(), content="(2, 3, 7, 10)")
  inspect(ctx.in_clip(3.0, 4.0), content="true")
  inspect(ctx.in_clip(0.0, 0.0), content="false")

  let rectangles = ctx.copy_clip_rectangle_list()
  inspect(rectangles.length(), content="1")
  debug_inspect(rectangles[0].components(), content="(2, 3, 5, 7)")
  inspect(rectangles[0][1], content="3")

  ctx.reset_clip()
  debug_inspect(ctx.clip_extents(), content="(0, 0, 20, 20)")
}
```

## Groups And Sources

Groups render into an intermediate surface. `pop_group` returns a paintable
surface pattern; `pop_group_to_source` installs that pattern as the current
source. `push_group_with_content_raw` mirrors pycairo's C-int `Content`
argument for ported code.

```mbt check
///|
test "context docs: group output becomes a reusable source pattern" {
  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.push_group()
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  let pattern = ctx.pop_group()
  inspect(pattern.get_surface().get_width(), content="1")

  ctx.set_source(pattern)
  ctx.paint()
  ctx.push_group_with_content_raw(0x1000)
  inspect(ctx.get_group_target().get_content_raw(), content="4096")
  let _ = ctx.pop_group()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}
```

## Text And Glyphs

Toy-font text APIs encode MoonBit `String` values to UTF-8 and reject embedded
NUL bytes. Glyph APIs accept pure `Glyph` arrays.

```mbt check
///|
test "context docs: text extents paths glyphs and scaled font" {
  let surface = Surface::image(Argb32, 48, 24)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(16.0)
  ctx.move_to(2.0, 18.0)
  let extents = ctx.text_extents("foo")
  inspect(extents.x_advance > 0.0, content="true")
  ctx.show_text("foo")
  let (x, y) = ctx.get_current_point()
  inspect(x > 2.0, content="true")
  inspect(y, content="18")

  let glyphs = [Glyph::new(0UL, 2.0, 18.0)]
  inspect(
    ctx.glyph_extents(glyphs) == ctx.get_scaled_font().glyph_extents(glyphs),
    content="true",
  )
  ctx.glyph_path(glyphs)
  let (_, y1, _, y2) = ctx.path_extents()
  inspect(y2 > y1, content="true")
}
```

## PDF Tags And Links

`tag_begin` and `tag_end` expose Cairo's generic tag interface. For Cairo
1.18, cairoon treats the following official attribute forms as the finite
portable contract:

- `TAG_LINK` accepts one target: `uri`, `dest`, or `page` with `pos`. A link
  may add `file` for an external document and `rect=[x y width height ...]`
  for one or more explicit hit regions; otherwise Cairo derives the region
  from tagged drawing extents.
- `TAG_DEST` requires `name`, accepts optional `x` and `y`, and accepts the
  `internal` flag. Without coordinates, Cairo derives the destination from
  tagged drawing extents.
- `TAG_CONTENT` requires `tag_name` and accepts `id`.
- `TAG_CONTENT_REF` requires `ref`, which names a content `id`.

Document structure names such as `Document`, `Sect`, `H1`, and `P` use the
same begin/end calls. Invalid attributes or nesting raise `CairoError` with
`TagError`; Cairo may report a structural error only when a page is committed.

```mbt check
///|
test "context docs: PDF links destinations and content references" {
  let surface = Surface::pdf(96.0, 72.0)
  let ctx = Context::new(surface)
  ctx.select_font_face("sans")
  ctx.set_font_size(8.0)

  ctx.tag_begin(@cairoon.TAG_CONTENT, "tag_name='H1' id='heading'")
  ctx.move_to(8.0, 12.0)
  ctx.show_text("Tagged heading")
  ctx.tag_end(@cairoon.TAG_CONTENT)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[8 18 36 10 48 18 36 10] uri='https://example.com/cairoon'",
  )
  ctx.move_to(10.0, 25.0)
  ctx.show_text("two hit regions")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(@cairoon.TAG_LINK, "dest='chapter-two'")
  ctx.move_to(8.0, 40.0)
  ctx.show_text("next page")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin("Document", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(@cairoon.TAG_CONTENT_REF, "ref='heading'")
  ctx.tag_end(@cairoon.TAG_CONTENT_REF)
  ctx.tag_end("H1")
  ctx.tag_end("Document")
  surface.show_page()

  ctx.tag_begin(@cairoon.TAG_DEST, "name='chapter-two' x=8 y=16 internal")
  ctx.move_to(8.0, 16.0)
  ctx.show_text("Destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
  debug_inspect(surface.status(), content="SurfaceFinished")

  let invalid = Context::new(Surface::pdf(16.0, 16.0))
  match
    run_cairo(() => {
      invalid.tag_begin(@cairoon.TAG_DEST, "x=1 y=2")
      invalid.show_page()
    }) {
    Err(CairoError(TagError, _)) => ()
    _ => @test.fail("expected TagError after committing an invalid tag")
  }
}
```

## Checked Errors

Sticky Cairo errors are surfaced immediately by safe wrappers. Use `run_cairo`
when a test or caller wants the `Result` form.

```mbt check
///|
test "context docs: invalid context operations are checked errors" {
  let ctx = Context::new(Surface::image(Argb32, 8, 8))

  match run_cairo(() => ctx.restore()) {
    Err(CairoError(InvalidRestore, _)) => ()
    _ => @test.fail("expected InvalidRestore")
  }

  let no_point = Context::new(Surface::image(Argb32, 8, 8))
  match run_cairo(() => no_point.rel_line_to(1.0, 1.0)) {
    Err(CairoError(NoCurrentPoint, _)) => ()
    _ => @test.fail("expected NoCurrentPoint")
  }

  let text_ctx = Context::new(Surface::image(Argb32, 8, 8))
  match run_cairo(() => text_ctx.show_text("bad\u{0}text")) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}
```
