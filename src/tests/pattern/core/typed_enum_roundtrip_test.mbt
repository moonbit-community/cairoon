///|
test "pattern extend modes round trip through cairo" {
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  let modes : Array[@cairoon.Extend] = [
    @cairoon.ExtendNone,
    @cairoon.Repeat,
    @cairoon.Reflect,
    @cairoon.Pad,
  ]
  for mode in modes {
    pattern.set_extend(mode)
    inspect(pattern.get_extend() == mode, content="true")
  }
}

///|
test "pattern filter modes round trip through cairo" {
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  let modes : Array[@cairoon.Filter] = [
    @cairoon.Fast,
    @cairoon.Good,
    @cairoon.Best,
    @cairoon.Nearest,
    @cairoon.Bilinear,
    @cairoon.Gaussian,
  ]
  for mode in modes {
    pattern.set_filter(mode)
    inspect(pattern.get_filter() == mode, content="true")
  }
}

///|
test "pattern dither modes round trip when supported" {
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  if @cairoon.CAIRO_VERSION >= 11800 {
    let modes : Array[@cairoon.Dither] = [
      @cairoon.DitherNone,
      @cairoon.DitherDefault,
      @cairoon.DitherFast,
      @cairoon.DitherGood,
      @cairoon.DitherBest,
    ]
    for mode in modes {
      pattern.set_dither(mode)
      inspect(pattern.get_dither() == mode, content="true")
    }
  } else {
    let modes : Array[@cairoon.Dither] = [
      @cairoon.DitherNone,
      @cairoon.DitherDefault,
      @cairoon.DitherFast,
      @cairoon.DitherGood,
      @cairoon.DitherBest,
    ]
    for mode in modes {
      expect_pattern_dither_unavailable(
        @cairoon.run_cairo(() => pattern.set_dither(mode)),
      )
    }
  }
}
