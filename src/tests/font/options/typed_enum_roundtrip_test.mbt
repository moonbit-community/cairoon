///|
test "font subpixel orders round trip through cairo" {
  let options = @cairoon.FontOptions::new()
  let orders : Array[@cairoon.SubpixelOrder] = [
    @cairoon.SubpixelDefault,
    @cairoon.SubpixelRgb,
    @cairoon.SubpixelBgr,
    @cairoon.SubpixelVrgb,
    @cairoon.SubpixelVbgr,
  ]
  for order in orders {
    options.set_subpixel_order(order)
    inspect(options.get_subpixel_order() == order, content="true")
  }
}

///|
test "font hint styles round trip through cairo" {
  let options = @cairoon.FontOptions::new()
  let styles : Array[@cairoon.HintStyle] = [
    @cairoon.HintStyleDefault,
    @cairoon.HintStyleNone,
    @cairoon.HintStyleSlight,
    @cairoon.HintStyleMedium,
    @cairoon.HintStyleFull,
  ]
  for style in styles {
    options.set_hint_style(style)
    inspect(options.get_hint_style() == style, content="true")
  }
}

///|
test "font color modes round trip when supported" {
  if @cairoon.CAIRO_VERSION >= 11800 {
    let options = @cairoon.FontOptions::new()
    let modes : Array[@cairoon.ColorMode] = [
      @cairoon.ColorModeDefault,
      @cairoon.ColorModeNoColor,
      @cairoon.ColorModeColor,
    ]
    for mode in modes {
      options.set_color_mode(mode)
      inspect(options.get_color_mode() == mode, content="true")
    }
  } else {
    let options = @cairoon.FontOptions::new()
    let modes : Array[@cairoon.ColorMode] = [
      @cairoon.ColorModeDefault,
      @cairoon.ColorModeNoColor,
      @cairoon.ColorModeColor,
    ]
    for mode in modes {
      expect_font_options_api_unavailable(
        @cairoon.run_cairo(() => options.set_color_mode(mode)),
      )
    }
    expect_font_options_api_unavailable(
      @cairoon.run_cairo(() => {
        let _ = options.get_color_palette()
        ()
      }),
    )
    if @cairoon.CAIRO_VERSION < 11600 {
      expect_font_options_api_unavailable(
        @cairoon.run_cairo(() => options.set_variations(None)),
      )
    }
  }
}
