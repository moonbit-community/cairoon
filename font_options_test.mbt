///|
test "font options new exposes default state" {
  let options = FontOptions::new()
  debug_inspect(options.get_antialias(), content="AntialiasDefault")
  debug_inspect(options.get_subpixel_order(), content="SubpixelDefault")
  debug_inspect(options.get_hint_style(), content="HintStyleDefault")
  debug_inspect(options.get_hint_metrics(), content="HintMetricsDefault")
  debug_inspect(options.get_color_mode(), content="ColorModeDefault")
  inspect(options.get_color_palette().reinterpret_as_int(), content="0")
  inspect(options.get_variations() is None, content="true")
}

///|
test "font options setters round trip state" {
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_subpixel_order(SubpixelVrgb)
  options.set_hint_style(HintStyleSlight)
  options.set_hint_metrics(HintMetricsOff)
  options.set_color_mode(ColorModeColor)
  options.set_color_palette(42U)
  options.set_variations(Some("wght=200,wdth=140.5"))
  debug_inspect(options.get_antialias(), content="AntialiasGray")
  debug_inspect(options.get_subpixel_order(), content="SubpixelVrgb")
  debug_inspect(options.get_hint_style(), content="HintStyleSlight")
  debug_inspect(options.get_hint_metrics(), content="HintMetricsOff")
  debug_inspect(options.get_color_mode(), content="ColorModeColor")
  inspect(options.get_color_palette().reinterpret_as_int(), content="42")
  match options.get_variations() {
    Some(variations) => inspect(variations, content="wght=200,wdth=140.5")
    None => @test.fail("expected font variations")
  }
  options.set_variations(None)
  inspect(options.get_variations() is None, content="true")
}

///|
test "font options custom palette colors map invalid index" {
  let options = FontOptions::new()
  let missing = run_cairo(() => {
    let _ = options.get_custom_palette_color(24U)
    ()
  })
  inspect(missing is Err(_), content="true")
  match missing {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }

  options.set_custom_palette_color(42U, 0.25, 0.5, 0.75, 1.0)
  let (red, green, blue, alpha) = options.get_custom_palette_color(42U)
  inspect(red, content="0.25")
  inspect(green, content="0.5")
  inspect(blue, content="0.75")
  inspect(alpha, content="1")
}

///|
test "font options copy equal hash and merge follow cairo state" {
  let options = FontOptions::new()
  options.set_hint_metrics(HintMetricsDefault)
  let copied = options.copy()
  inspect(options.equal(copied), content="true")
  inspect(options.hash() == options.hash(), content="true")
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsDefault")

  options.set_hint_metrics(HintMetricsOn)
  inspect(options.equal(copied), content="false")
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsDefault")
  copied.merge(options)
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsOn")
}

///|
test "surface and context expose font options wrappers" {
  let surface = Surface::image(Rgb24, 1, 1)
  let surface_options = surface.get_font_options()
  inspect(surface_options.status().is_success(), content="true")

  let ctx = Context::new(surface)
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_hint_style(HintStyleMedium)
  ctx.set_font_options(options)
  let returned = ctx.get_font_options()
  debug_inspect(returned.get_antialias(), content="AntialiasGray")
  debug_inspect(returned.get_hint_style(), content="HintStyleMedium")
}

///|
test "context font options methods propagate cairo error" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let options = FontOptions::new()
  let set_matrix_result = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_matrix_result is Err(_), content="true")

  let get_result = run_cairo(() => {
    let _ = ctx.get_font_options()
    ()
  })
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_result = run_cairo(() => ctx.set_font_options(options))
  inspect(set_result is Err(_), content="true")
  match set_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "font options allocation and copy stress" {
  for index in 0..<1000 {
    let options = FontOptions::new()
    options.set_color_palette(index.reinterpret_as_uint())
    let copied = options.copy()
    inspect(options.equal(copied), content="true")
  }
}
