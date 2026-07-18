///|
fn expect_font_options_api_unavailable(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected font options API to be unavailable")
  }
}

///|
test "font options new exposes default state" {
  let options = @cairoon.FontOptions::new()
  debug_inspect(options.get_antialias(), content="AntialiasDefault")
  debug_inspect(options.get_subpixel_order(), content="SubpixelDefault")
  debug_inspect(options.get_hint_style(), content="HintStyleDefault")
  debug_inspect(options.get_hint_metrics(), content="HintMetricsDefault")
  if @cairoon.CAIRO_VERSION >= 11800 {
    debug_inspect(options.get_color_mode(), content="ColorModeDefault")
    inspect(options.get_color_palette().reinterpret_as_int(), content="0")
    inspect(
      options.get_color_palette() == @cairoon.COLOR_PALETTE_DEFAULT,
      content="true",
    )
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => {
        let _ = options.get_color_mode()
        ()
      }),
    )
  }
  if @cairoon.CAIRO_VERSION >= 11600 {
    inspect(options.get_variations() is None, content="true")
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => {
        let _ = options.get_variations()
        ()
      }),
    )
  }
}

///|
test "font options setters round trip state" {
  let options = @cairoon.FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_subpixel_order(SubpixelVrgb)
  options.set_hint_style(HintStyleSlight)
  options.set_hint_metrics(HintMetricsOff)
  if @cairoon.CAIRO_VERSION >= 11800 {
    options.set_color_mode(ColorModeColor)
    options.set_color_palette(42U)
  }
  if @cairoon.CAIRO_VERSION >= 11600 {
    options.set_variations(Some("wght=200,wdth=140.5"))
  }
  debug_inspect(options.get_antialias(), content="AntialiasGray")
  debug_inspect(options.get_subpixel_order(), content="SubpixelVrgb")
  debug_inspect(options.get_hint_style(), content="HintStyleSlight")
  debug_inspect(options.get_hint_metrics(), content="HintMetricsOff")
  if @cairoon.CAIRO_VERSION >= 11800 {
    debug_inspect(options.get_color_mode(), content="ColorModeColor")
    inspect(options.get_color_palette().reinterpret_as_int(), content="42")
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => options.set_color_mode(ColorModeColor)),
    )
  }
  if @cairoon.CAIRO_VERSION >= 11600 {
    match options.get_variations() {
      Some(variations) => inspect(variations, content="wght=200,wdth=140.5")
      None => @test.fail("expected font variations")
    }
    options.set_variations(None)
    inspect(options.get_variations() is None, content="true")
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => options.set_variations(Some("wght=200"))),
    )
  }
}

///|
test "font options variations reject embedded nul strings" {
  let options = @cairoon.FontOptions::new()
  if @cairoon.CAIRO_VERSION >= 11600 {
    options.set_variations(Some("wght=300"))
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => options.set_variations(Some("wght=300"))),
    )
  }
  let result = @cairoon.run_cairo(() => {
    options.set_variations(Some("wght=300\u{0}wdth=80"))
  })
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
  if @cairoon.CAIRO_VERSION >= 11600 {
    match options.get_variations() {
      Some(variations) => inspect(variations, content="wght=300")
      None => @test.fail("expected original variations to survive failed set")
    }
  }
}

///|
test "font options raw enums mirror pycairo c int passthrough" {
  let antialias_options = @cairoon.FontOptions::new()
  antialias_options.set_antialias(AntialiasGood)
  inspect(antialias_options.get_antialias_raw(), content="5")
  antialias_options.set_antialias_raw(42)
  inspect(antialias_options.get_antialias_raw(), content="42")
  match @cairoon.run_cairo(() => antialias_options.get_antialias()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw antialias")
  }
  antialias_options.set_antialias_raw(0)
  debug_inspect(antialias_options.get_antialias(), content="AntialiasDefault")

  let subpixel_options = @cairoon.FontOptions::new()
  subpixel_options.set_subpixel_order(SubpixelVbgr)
  inspect(subpixel_options.get_subpixel_order_raw(), content="4")
  subpixel_options.set_subpixel_order_raw(42)
  inspect(subpixel_options.get_subpixel_order_raw(), content="42")
  match @cairoon.run_cairo(() => subpixel_options.get_subpixel_order()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ =>
      @test.fail("expected typed getter to reject unknown raw subpixel order")
  }
  subpixel_options.set_subpixel_order_raw(0)
  debug_inspect(
    subpixel_options.get_subpixel_order(),
    content="SubpixelDefault",
  )

  let hint_style_options = @cairoon.FontOptions::new()
  hint_style_options.set_hint_style(HintStyleFull)
  inspect(hint_style_options.get_hint_style_raw(), content="4")
  hint_style_options.set_hint_style_raw(42)
  inspect(hint_style_options.get_hint_style_raw(), content="42")
  match @cairoon.run_cairo(() => hint_style_options.get_hint_style()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw hint style")
  }
  hint_style_options.set_hint_style_raw(0)
  debug_inspect(hint_style_options.get_hint_style(), content="HintStyleDefault")

  let hint_metrics_options = @cairoon.FontOptions::new()
  hint_metrics_options.set_hint_metrics(HintMetricsOn)
  inspect(hint_metrics_options.get_hint_metrics_raw(), content="2")
  hint_metrics_options.set_hint_metrics_raw(42)
  inspect(hint_metrics_options.get_hint_metrics_raw(), content="42")
  match @cairoon.run_cairo(() => hint_metrics_options.get_hint_metrics()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw hint metrics")
  }
  hint_metrics_options.set_hint_metrics_raw(0)
  debug_inspect(
    hint_metrics_options.get_hint_metrics(),
    content="HintMetricsDefault",
  )

  let color_mode_options = @cairoon.FontOptions::new()
  if @cairoon.CAIRO_VERSION >= 11800 {
    color_mode_options.set_color_mode(ColorModeColor)
    inspect(color_mode_options.get_color_mode_raw(), content="2")
    color_mode_options.set_color_mode_raw(42)
    inspect(color_mode_options.get_color_mode_raw(), content="42")
    match @cairoon.run_cairo(() => color_mode_options.get_color_mode()) {
      Err(CairoInvalidArgument(InvalidStatus, _)) => ()
      _ => @test.fail("expected typed getter to reject unknown raw color mode")
    }
    color_mode_options.set_color_mode_raw(0)
    debug_inspect(
      color_mode_options.get_color_mode(),
      content="ColorModeDefault",
    )
  } else {
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => color_mode_options.set_color_mode_raw(42)),
    )
  }
}

///|
test "font options custom palette colors map invalid index" {
  let options = @cairoon.FontOptions::new()
  let missing = @cairoon.run_cairo(() => {
    let _ = options.get_custom_palette_color(24U)
    ()
  })
  inspect(missing is Err(_), content="true")
  if @cairoon.CAIRO_VERSION >= 11800 {
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
  } else {
    expect_font_options_api_unavailable(missing)
  }
}

///|
test "font options copy equal hash and merge follow cairo state" {
  let options = @cairoon.FontOptions::new()
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
  let surface = @cairoon.Surface::image(Rgb24, 1, 1)
  let surface_options = surface.get_font_options()
  inspect(surface_options.status().is_success(), content="true")

  let ctx = @cairoon.Context::new(surface)
  let options = @cairoon.FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_hint_style(HintStyleMedium)
  ctx.set_font_options(options)
  let returned = ctx.get_font_options()
  debug_inspect(returned.get_antialias(), content="AntialiasGray")
  debug_inspect(returned.get_hint_style(), content="HintStyleMedium")
}

///|
test "context font options methods propagate cairo error" {
  let ctx = @cairoon.Context::new(@cairoon.Surface::image(Argb32, 1, 1))
  let options = @cairoon.FontOptions::new()
  let set_matrix_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_matrix_result is Err(_), content="true")

  let get_result = @cairoon.run_cairo(() => {
    let _ = ctx.get_font_options()
    ()
  })
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_result = @cairoon.run_cairo(() => ctx.set_font_options(options))
  inspect(set_result is Err(_), content="true")
  match set_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "font options allocation and copy stress" {
  for index in 0..<1000 {
    let options = @cairoon.FontOptions::new()
    if @cairoon.CAIRO_VERSION >= 11800 {
      options.set_color_palette(index.reinterpret_as_uint())
    } else {
      options.set_antialias(AntialiasGray)
    }
    let copied = options.copy()
    inspect(options.equal(copied), content="true")
  }
}
