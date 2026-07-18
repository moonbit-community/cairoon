///|
fn expect_ps_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_ps_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn ps_dsc_comment_with_byte_length(length : Int) -> String {
  let builder = StringBuilder()
  builder.write_string("%")
  for _ in 1..<length {
    builder.write_string("x")
  }
  builder.to_string()
}

///|
fn expect_invalid_ps_dsc_comment(comment : String) -> Unit raise {
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  match @cairoon.run_cairo(() => surface.ps_dsc_comment(comment)) {
    Err(CairoError(InvalidDscComment, _)) => ()
    _ => @test.fail("expected InvalidDscComment")
  }
}

///|
fn ps_bytes_find(haystack : Bytes, needle : Bytes) -> Int {
  if needle.length() == 0 {
    return 0
  }
  if needle.length() > haystack.length() {
    return -1
  }
  let last = haystack.length() - needle.length()
  for start in 0..<=last {
    let mut matched = true
    for offset in 0..<needle.length() {
      if haystack[start + offset] != needle[offset] {
        matched = false
      }
    }
    if matched {
      return start
    }
  }
  -1
}

///|
test "ps level helpers expose cairo-supported levels" {
  let levels = @cairoon.PSLevel::supported()
  let level : @cairoon.PSLevel = PsLevel3
  inspect(levels.length() > 0, content="true")
  inspect(levels.any(item => item == level), content="true")
  inspect(level.to_string().contains("PS"), content="true")
  inspect(@cairoon.PSLevel::to_string_raw(0).contains("PS"), content="true")
  for invalid in [-1, 99] {
    match @cairoon.run_cairo(() => @cairoon.PSLevel::to_string_raw(invalid)) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => @test.fail("expected InvalidStatus for invalid raw PS level")
    }
  }
}

///|
test "ps surface exposes pycairo-compatible raw C-int backend enums" {
  let path = "/tmp/cairoon_ps_raw_level.ps"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }
  let surface = @cairoon.Surface::ps(10.0, 10.0, path=Some(path))
  surface.ps_restrict_to_level_raw(0)
  surface.ps_restrict_to_level_raw(99)
  debug_inspect(surface.status(), content="Success")
  let ctx = @cairoon.Context::new(surface)
  ctx.paint()
  surface.finish()
  let output = @fs.read_file_to_string(path)
  inspect(output.contains("%%LanguageLevel: 2"), content="true")
  @fs.remove_file(path)
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_restrict_to_level_raw(1)),
  )
}

///|
test "ps surface no-output constructor exposes eps size dsc and level APIs" {
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePs")
  inspect(surface.ps_get_eps(), content="false")
  surface.ps_set_eps(true)
  inspect(surface.ps_get_eps(), content="true")
  surface.ps_restrict_to_level(PsLevel2)
  surface.ps_set_size(12.0, 14.0)
  surface.ps_dsc_comment("%%Title: Cairoon PS")
  surface.ps_dsc_begin_setup()
  surface.ps_dsc_comment("%%IncludeFeature: *MediaColor White")
  surface.ps_dsc_begin_page_setup()
  surface.ps_dsc_comment("%%IncludeFeature: *PageSize A4")
  surface.finish()

  expect_ps_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = surface.ps_get_eps()
      ()
    }),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_set_eps(false)),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_restrict_to_level(PsLevel3)),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_set_size(1.0, 1.0)),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_dsc_begin_setup()),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_dsc_begin_page_setup()),
  )
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_dsc_comment("%%Title: after finish")),
  )
}

///|
test "pycairo ps surface dsc setup order fixture" {
  let path = "/tmp/cairoon_ps_dsc_order.ps"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }
  let surface = @cairoon.Surface::ps(10.0, 10.0, path=Some(path))
  surface.ps_dsc_begin_page_setup()
  surface.ps_dsc_comment("%%CairoonPageFirst: one")
  surface.ps_dsc_begin_setup()
  surface.ps_dsc_comment("%%CairoonPageSecond: two")
  let ctx = @cairoon.Context::new(surface)
  ctx.paint()
  inspect(surface.status().is_success(), content="true")
  surface.finish()

  let output = @fs.read_file_to_bytes(path)
  let begin_page_setup = ps_bytes_find(output, @utf8.encode("%%BeginPageSetup"))
  let first = ps_bytes_find(output, @utf8.encode("%%CairoonPageFirst: one"))
  let second = ps_bytes_find(output, @utf8.encode("%%CairoonPageSecond: two"))
  let end_page_setup = ps_bytes_find(output, @utf8.encode("%%EndPageSetup"))
  inspect(begin_page_setup >= 0, content="true")
  inspect(begin_page_setup < first, content="true")
  inspect(first < second, content="true")
  inspect(second < end_page_setup, content="true")
  @fs.remove_file(path)
}

///|
test "ps surface validates dsc comments and path strings" {
  let boundary = @cairoon.Surface::ps(10.0, 10.0)
  boundary.ps_dsc_comment(ps_dsc_comment_with_byte_length(255))
  debug_inspect(boundary.status(), content="Success")
  boundary.finish()

  for
    invalid in [
      "",
      "Title: missing percent",
      ps_dsc_comment_with_byte_length(256),
    ] {
    expect_invalid_ps_dsc_comment(invalid)
  }

  let invalid_comment_string = @cairoon.Surface::ps(10.0, 10.0)
  match
    @cairoon.run_cairo(() => {
      invalid_comment_string.ps_dsc_comment("%%Title: bad\u{0}comment")
    }) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PS DSC comment")
  }

  let invalid_path = "/tmp/cairoon\u{0}bad.ps"
  let invalid = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::ps(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PS path")
  }
}

///|
test "ps surface filename constructor renders and finishes" {
  let path = "/tmp/cairoon_surface_ps_roundtrip.ps"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }

  let surface = @cairoon.Surface::ps(10.0, 10.0, path=Some(path))
  surface.ps_set_eps(true)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()

  let output = @fs.read_file_to_string(path)
  inspect(output.length() > 16, content="true")
  inspect(output.contains("%!PS"), content="true")
  inspect(output.contains("EPSF"), content="true")
  @fs.remove_file(path)
}

///|
test "ps surface methods reject other surface types" {
  let image = @cairoon.Surface::image(Argb32, 1, 1)
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.ps_get_eps()
      ()
    }),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_set_eps(true)),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_restrict_to_level(PsLevel2)),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_restrict_to_level_raw(0)),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_dsc_comment("%%Title: nope")),
  )
}

///|
test "ps setup and size methods reject other surface types" {
  let image = @cairoon.Surface::image(Argb32, 1, 1)
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_set_size(10.0, 10.0)),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_dsc_begin_setup()),
  )
  expect_ps_surface_type_mismatch(
    @cairoon.run_cairo(() => image.ps_dsc_begin_page_setup()),
  )
}
