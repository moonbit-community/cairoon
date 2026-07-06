///|
fn pycairo_context_surface(
  width : Int,
  height : Int,
) -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(@cairoon.Argb32, width, height)
}

///|
fn assert_pycairo_context_close(
  actual : Double,
  expected : Double,
) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected \{expected}, got \{actual}")
  }
}

///|
fn assert_pycairo_context_extents_close(
  actual : (Double, Double, Double, Double),
  expected : (Double, Double, Double, Double),
) -> Unit raise {
  let (actual_x1, actual_y1, actual_x2, actual_y2) = actual
  let (expected_x1, expected_y1, expected_x2, expected_y2) = expected
  assert_pycairo_context_close(actual_x1, expected_x1)
  assert_pycairo_context_close(actual_y1, expected_y1)
  assert_pycairo_context_close(actual_x2, expected_x2)
  assert_pycairo_context_close(actual_y2, expected_y2)
}

///|
fn assert_pycairo_context_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_pycairo_context_close(actual_x, expected_x)
  assert_pycairo_context_close(actual_y, expected_y)
}

///|
fn assert_pycairo_context_matrix_close(
  actual : @cairoon.Matrix,
  expected : @cairoon.Matrix,
) -> Unit raise {
  assert_pycairo_context_close(actual.xx, expected.xx)
  assert_pycairo_context_close(actual.yx, expected.yx)
  assert_pycairo_context_close(actual.xy, expected.xy)
  assert_pycairo_context_close(actual.yy, expected.yy)
  assert_pycairo_context_close(actual.x0, expected.x0)
  assert_pycairo_context_close(actual.y0, expected.y0)
}

///|
fn assert_pycairo_context_argb32_pixel(
  surface : @cairoon.Surface,
  expected : Array[Int],
) -> Unit raise {
  let data = surface.copy_data()
  inspect(data.length(), content="4")
  for index in 0..<expected.length() {
    inspect(data[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn pycairo_context_has_nonzero_byte(bytes : Bytes) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != 0 {
      return true
    }
  }
  false
}

///|
fn expect_pycairo_context_invalid_pop_group(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.InvalidPopGroup, _)) => ()
    _ => @test.fail("expected InvalidPopGroup")
  }
}

///|
test "context default clip extents mirror pycairo fixture dimensions" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.clip_extents(),
    (0.0, 0.0, 42.0, 42.0),
  )
}

///|
test "zero radius arcs leave non-empty paths like pycairo" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.copy_path().length(), content="0")

  ctx.arc(0.0, 0.0, 0.0, 0.0, 0.0)
  inspect(ctx.copy_path().length() > 0, content="true")

  ctx.new_path()
  inspect(ctx.copy_path().length(), content="0")

  ctx.arc_negative(0.0, 0.0, 0.0, 0.0, 0.0)
  inspect(ctx.copy_path().length() > 0, content="true")
}

///|
test "context polygon path_extents mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_pycairo_context_extents_close(ctx.path_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context fill_extents and empty in_fill mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.in_fill(0.1, 0.1), content="false")

  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_pycairo_context_extents_close(ctx.fill_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context line in_stroke mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(0.0, 0.0)
  ctx.line_to(1.0, 1.0)
  inspect(ctx.in_stroke(0.0, 0.0), content="true")
  inspect(ctx.in_stroke(0.0, 2.0), content="false")
}

///|
test "context current point mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.has_current_point(), content="false")
  assert_pycairo_context_point_close(ctx.get_current_point(), (0.0, 0.0))

  ctx.move_to(10.0, 10.0)
  inspect(ctx.has_current_point(), content="true")
  assert_pycairo_context_point_close(ctx.get_current_point(), (10.0, 10.0))
}

///|
test "context rectangle and relative path methods mirror pycairo fixtures" {
  let rectangle_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rectangle_ctx.rectangle(1.0, 2.0, 4.0, 5.0)
  assert_pycairo_context_extents_close(
    rectangle_ctx.path_extents(),
    (1.0, 2.0, 5.0, 7.0),
  )

  let rel_line_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_line_ctx.line_to(0.0, 0.0)
  rel_line_ctx.rel_line_to(1.0, 1.0)
  assert_pycairo_context_point_close(
    rel_line_ctx.get_current_point(),
    (1.0, 1.0),
  )

  let rel_move_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_move_ctx.line_to(0.0, 0.0)
  rel_move_ctx.rel_move_to(1.0, 1.0)
  assert_pycairo_context_point_close(
    rel_move_ctx.get_current_point(),
    (1.0, 1.0),
  )

  let rel_curve_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_curve_ctx.line_to(0.0, 0.0)
  rel_curve_ctx.rel_curve_to(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  assert_pycairo_context_point_close(
    rel_curve_ctx.get_current_point(),
    (0.0, 0.0),
  )
}

///|
test "context empty stroke_extents mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.stroke_extents(),
    (0.0, 0.0, 0.0, 0.0),
  )
}

///|
test "context default coordinate conversions mirror pycairo zero fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_point_close(ctx.device_to_user(0.0, 0.0), (0.0, 0.0))
  assert_pycairo_context_point_close(
    ctx.device_to_user_distance(0.0, 0.0),
    (0.0, 0.0),
  )
  assert_pycairo_context_point_close(ctx.user_to_device(0.0, 0.0), (0.0, 0.0))
  assert_pycairo_context_point_close(
    ctx.user_to_device_distance(0.0, 0.0),
    (0.0, 0.0),
  )
}

///|
test "context matrix mutators mirror pycairo method fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let identity = @cairoon.Matrix::new()
  ctx.set_matrix(identity)
  assert_pycairo_context_matrix_close(ctx.get_matrix(), identity)

  ctx.translate(0.5, 0.5)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(x0=0.5, y0=0.5),
  )

  ctx.scale(2.0, 3.0)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=0.5, y0=0.5),
  )

  ctx.identity_matrix()
  let transform = @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  ctx.transform(transform)
  assert_pycairo_context_matrix_close(ctx.get_matrix(), transform)

  ctx.identity_matrix()
  ctx.rotate(0.3)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::init_rotate(0.3),
  )
}

///|
test "context default drawing state getters mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  debug_inspect(ctx.get_antialias(), content="AntialiasDefault")
  debug_inspect(ctx.get_fill_rule(), content="FillWinding")
  debug_inspect(ctx.get_line_cap(), content="LineCapButt")
  debug_inspect(ctx.get_line_join(), content="LineJoinMiter")
  debug_inspect(ctx.get_operator(), content="OperatorOver")
}

///|
test "context drawing state setters mirror pycairo enum fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_antialias(@cairoon.AntialiasSubpixel)
  ctx.set_fill_rule(@cairoon.FillEvenOdd)
  ctx.set_line_cap(@cairoon.LineCapSquare)
  ctx.set_line_join(@cairoon.LineJoinBevel)
  ctx.set_operator(@cairoon.OperatorSource)

  debug_inspect(ctx.get_antialias(), content="AntialiasSubpixel")
  debug_inspect(ctx.get_fill_rule(), content="FillEvenOdd")
  debug_inspect(ctx.get_line_cap(), content="LineCapSquare")
  debug_inspect(ctx.get_line_join(), content="LineJoinBevel")
  debug_inspect(ctx.get_operator(), content="OperatorSource")
}

///|
test "context hairline mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.get_hairline(), content="false")
  ctx.set_hairline(true)
  inspect(ctx.get_hairline(), content="true")
}

///|
test "context raw operator limits mirror pycairo c int fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let min_c_int = -2147483647 - 1
  let values = [-1, 0, 2147483647, min_c_int]
  for value in values {
    ctx.set_operator_raw(value)
    inspect(ctx.get_operator_raw(), content="\{value}")
  }

  match @cairoon.run_cairo(() => ctx.get_operator()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw operator")
  }

  ctx.set_operator_raw(0)
  debug_inspect(ctx.get_operator(), content="OperatorClear")
}

///|
test "context save restore preserves drawing state like pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_line_width(3.0)
  ctx.save()
  ctx.set_line_width(7.0)
  assert_pycairo_context_close(ctx.get_line_width(), 7.0)
  ctx.restore()
  assert_pycairo_context_close(ctx.get_line_width(), 3.0)
}

///|
test "context dash state mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
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
}

///|
test "context scalar setters mirror pycairo numeric fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.set_line_width(42.0)
  assert_pycairo_context_close(ctx.get_line_width(), 42.0)

  ctx.set_miter_limit(42.0)
  assert_pycairo_context_close(ctx.get_miter_limit(), 42.0)

  ctx.set_tolerance(42.0)
  assert_pycairo_context_close(ctx.get_tolerance(), 42.0)
}

///|
test "context source rgba mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  assert_pycairo_context_extents_close(
    ctx.get_source().get_rgba(),
    (1.0, 1.0, 1.0, 1.0),
  )

  ctx.set_source_rgba(1.0, 1.0, 1.0, 0.5)
  assert_pycairo_context_extents_close(
    ctx.get_source().get_rgba(),
    (1.0, 1.0, 1.0, 0.5),
  )
}

///|
test "context explicit source pattern mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  ctx.set_source(pattern)
  inspect(ctx.get_source().equal(pattern), content="true")
}

///|
test "context append_path mirrors pycairo copied path fixture" {
  let source = @cairoon.Context::new(pycairo_context_surface(42, 42))
  source.line_to(1.0, 2.0)
  let path = source.copy_path()
  let source_string = path.to_string()

  let target = @cairoon.Context::new(pycairo_context_surface(42, 42))
  target.append_path(path)
  let target_string = target.copy_path().to_string()
  inspect(target_string == source_string, content="true")
}

///|
test "context empty clip reset mirrors pycairo in_clip fixture" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 100, 100),
  )
  inspect(ctx.in_clip(50.0, 50.0), content="true")
  ctx.clip()
  inspect(ctx.in_clip(50.0, 50.0), content="false")
  ctx.reset_clip()
  inspect(ctx.in_clip(50.0, 50.0), content="true")
}

///|
test "context group stack mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.push_group()
  let _ = ctx.pop_group()

  ctx.push_group()
  ctx.pop_group_to_source()

  ctx.push_group_with_content(@cairoon.ContentColor)
  let _ = ctx.pop_group()

  expect_pycairo_context_invalid_pop_group(
    @cairoon.run_cairo(() => {
      let _ = ctx.pop_group()
      ()
    }),
  )
}

///|
test "context mask and alpha paint mirror pycairo fixtures" {
  let paint_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let paint_ctx = @cairoon.Context::new(paint_surface)
  paint_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  paint_ctx.paint_with_alpha(1.0)
  assert_pycairo_context_argb32_pixel(paint_surface, [0, 0, 255, 255])

  let pattern_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let pattern_ctx = @cairoon.Context::new(pattern_surface)
  pattern_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  pattern_ctx.mask(@cairoon.Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0))
  assert_pycairo_context_argb32_pixel(pattern_surface, [0, 255, 0, 255])

  let mask_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let mask_ctx = @cairoon.Context::new(mask_surface)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.paint()

  let surface_mask_target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let surface_mask_ctx = @cairoon.Context::new(surface_mask_target)
  surface_mask_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  surface_mask_ctx.mask_surface(mask_surface)
  assert_pycairo_context_argb32_pixel(surface_mask_target, [255, 0, 0, 255])
}

///|
test "context font face round trips mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.get_font_face().status().is_success(), content="true")

  ctx.set_font_face(None)
  inspect(ctx.get_font_face().status().is_success(), content="true")

  let face = @cairoon.FontFace::toy(
    "serif",
    slant=@cairoon.FontSlantItalic,
    weight=@cairoon.FontWeightBold,
  )
  ctx.set_font_face(Some(face))
  let returned = ctx.get_font_face()
  inspect(returned.equal(face), content="true")
  inspect(returned.get_family(), content="serif")
  debug_inspect(returned.get_slant(), content="FontSlantItalic")
  debug_inspect(returned.get_weight(), content="FontWeightBold")
}

///|
test "context set_font_matrix mirrors pycairo identity fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let matrix = @cairoon.Matrix::new()
  ctx.set_font_matrix(matrix)
  assert_pycairo_context_matrix_close(ctx.get_font_matrix(), matrix)
}

///|
test "context font options round trip mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let options = ctx.get_font_options()
  options.set_antialias(@cairoon.AntialiasGray)
  options.set_hint_style(@cairoon.HintStyleSlight)

  ctx.set_font_options(options)
  let returned = ctx.get_font_options()
  debug_inspect(returned.get_antialias(), content="AntialiasGray")
  debug_inspect(returned.get_hint_style(), content="HintStyleSlight")
}

///|
test "context scaled font round trip mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let scaled_font = ctx.get_scaled_font()
  ctx.set_scaled_font(scaled_font)
  let returned = ctx.get_scaled_font()
  inspect(returned.equal(scaled_font), content="true")
  assert_pycairo_context_matrix_close(
    returned.get_font_matrix(),
    scaled_font.get_font_matrix(),
  )
}

///|
test "context empty font family selection mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.select_font_face("")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context set_font_size mirrors pycairo font matrix fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_font_size(42.0)
  assert_pycairo_context_matrix_close(
    ctx.get_font_matrix(),
    @cairoon.Matrix::new(xx=42.0, yy=42.0),
  )
}

///|
test "context text methods mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let context_extents = ctx.font_extents()
  let scaled_extents = ctx.get_scaled_font().extents()
  inspect(context_extents == scaled_extents, content="true")
  inspect(context_extents.height > 0.0, content="true")

  let text_extents = ctx.text_extents("foo")
  inspect(text_extents.x_advance > 0.0, content="true")
  inspect(text_extents.height > 0.0, content="true")
  let empty_extents = ctx.text_extents("")
  inspect(empty_extents.width, content="0")
  inspect(empty_extents.height, content="0")
  inspect(empty_extents.x_advance, content="0")

  ctx.move_to(2.0, 18.0)
  ctx.show_text("foo")
  assert_pycairo_context_point_close(
    ctx.get_current_point(),
    (2.0 + text_extents.x_advance, 18.0),
  )

  let path_surface = @cairoon.Surface::image(@cairoon.Argb32, 64, 32)
  let path_ctx = @cairoon.Context::new(path_surface)
  path_ctx.select_font_face("serif")
  path_ctx.set_font_size(16.0)
  path_ctx.move_to(2.0, 22.0)
  path_ctx.text_path("foo")
  let (x1, y1, x2, y2) = path_ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
  path_ctx.set_source_rgb(1.0, 0.0, 0.0)
  path_ctx.fill()
  inspect(
    pycairo_context_has_nonzero_byte(path_surface.copy_data()),
    content="true",
  )
}

///|
test "context glyph methods mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  ctx.select_font_face("Sans")
  ctx.set_font_size(16.0)
  let glyphs = [@cairoon.Glyph::new(0UL, 2.0, 22.0)]
  let context_extents = ctx.glyph_extents(glyphs)
  let scaled_extents = ctx.get_scaled_font().glyph_extents(glyphs)
  inspect(context_extents == scaled_extents, content="true")

  let empty_extents = ctx.glyph_extents([])
  inspect(empty_extents.width, content="0")
  inspect(empty_extents.height, content="0")
  inspect(empty_extents.x_advance, content="0")

  let show_surface = @cairoon.Surface::image(@cairoon.Argb32, 64, 32)
  let show_ctx = @cairoon.Context::new(show_surface)
  show_ctx.select_font_face("Sans")
  show_ctx.set_font_size(16.0)
  show_ctx.set_source_rgb(1.0, 0.0, 0.0)
  show_ctx.show_glyphs(glyphs)
  inspect(
    pycairo_context_has_nonzero_byte(show_surface.copy_data()),
    content="true",
  )
  inspect(show_ctx.has_current_point(), content="false")
  inspect(show_ctx.copy_path().length(), content="0")

  let path_ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  path_ctx.select_font_face("Sans")
  path_ctx.set_font_size(16.0)
  path_ctx.glyph_path(glyphs)
  let (x1, y1, x2, y2) = path_ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
}

///|
test "context show_text_glyphs mirrors pycairo pdf tuple fixture" {
  let surface = @cairoon.Surface::pdf(300.0, 300.0)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(300.0, 300.0)
  ctx.select_font_face("Sans")
  ctx.set_font_size(0.08)
  ctx.set_line_width(0.09)
  let scaled_font = ctx.get_scaled_font()

  let run = scaled_font.text_to_glyphs(0.5, 0.5, "foobar")
  inspect(run.glyphs.length() > 0, content="true")
  inspect(run.clusters.length() > 0, content="true")
  ctx.show_text_glyphs("foobar", run.glyphs, run.clusters, flags=run.flags)

  let empty = scaled_font.text_to_glyphs(0.5, 0.5, "")
  inspect(empty.glyphs.length(), content="0")
  inspect(empty.clusters.length(), content="0")
  ctx.show_text_glyphs("", empty.glyphs, empty.clusters, flags=empty.flags)
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context simple smoke mirrors pycairo method fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.clip_preserve()
  ctx.copy_page()
  let flat_path = ctx.copy_path_flat()
  inspect(flat_path.status().is_success(), content="true")
  ctx.fill()
  ctx.fill_preserve()
  let font_extents = ctx.font_extents()
  inspect(font_extents.height > 0.0, content="true")
  ctx.identity_matrix()
  ctx.new_sub_path()
  ctx.show_page()
  ctx.stroke_preserve()

  inspect(ctx.get_dash_count(), content="0")
  let font_matrix = ctx.get_font_matrix()
  inspect(font_matrix.xx > 0.0, content="true")
  inspect(font_matrix.yy > 0.0, content="true")
  inspect(ctx.get_group_target().status().is_success(), content="true")
  inspect(ctx.get_line_width() > 0.0, content="true")
  let tolerance : Double = ctx.get_tolerance()
  let miter_limit : Double = ctx.get_miter_limit()
  inspect(tolerance > 0.0, content="true")
  inspect(miter_limit > 0.0, content="true")
  assert_pycairo_context_matrix_close(ctx.get_matrix(), @cairoon.Matrix::new())
  inspect(ctx.status().is_success(), content="true")
}
