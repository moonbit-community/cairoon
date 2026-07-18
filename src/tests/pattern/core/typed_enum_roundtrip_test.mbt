///|
test "pattern extend modes round trip through cairo" {
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  let modes : Array[@cairoon.Extend] = [ExtendNone, Repeat, Reflect, Pad]
  for mode in modes {
    pattern.set_extend(mode)
    inspect(pattern.get_extend() == mode, content="true")
  }
}

///|
test "pattern filter modes round trip through cairo" {
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  let modes : Array[@cairoon.Filter] = [
    Fast,
    Good,
    Best,
    Nearest,
    Bilinear,
    Gaussian,
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
      DitherNone,
      DitherDefault,
      DitherFast,
      DitherGood,
      DitherBest,
    ]
    for mode in modes {
      pattern.set_dither(mode)
      inspect(pattern.get_dither() == mode, content="true")
    }
  } else {
    let modes : Array[@cairoon.Dither] = [
      DitherNone,
      DitherDefault,
      DitherFast,
      DitherGood,
      DitherBest,
    ]
    for mode in modes {
      expect_pattern_dither_unavailable(
        @cairoon.run_cairo(() => pattern.set_dither(mode)),
      )
    }
  }
}
