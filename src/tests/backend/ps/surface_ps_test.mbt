///|
fn expect_ps_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_ps_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "ps level helpers expose cairo-supported levels" {
  let levels = @cairoon.PSLevel::supported()
  let level : @cairoon.PSLevel = @cairoon.PsLevel3
  inspect(levels.length() > 0, content="true")
  inspect(levels.any(item => item == level), content="true")
  inspect(level.to_string().contains("PS"), content="true")
  inspect(@cairoon.PSLevel::to_string_raw(0).contains("PS"), content="true")
  match @cairoon.run_cairo(() => @cairoon.PSLevel::to_string_raw(99)) {
    Err(@cairoon.CairoError(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected InvalidStatus for invalid raw PS level")
  }
}

///|
test "ps surface exposes pycairo-compatible raw C-int backend enums" {
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  surface.ps_restrict_to_level_raw(0)
  surface.finish()
  expect_ps_surface_finished(
    @cairoon.run_cairo(() => surface.ps_restrict_to_level_raw(1)),
  )
}

///|
test "ps surface no-output constructor exposes eps size dsc and level APIs" {
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePs")
  inspect(surface.ps_get_eps() || !surface.ps_get_eps(), content="true")
  surface.ps_set_eps(true)
  inspect(surface.ps_get_eps(), content="true")
  surface.ps_restrict_to_level(@cairoon.PsLevel2)
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
    @cairoon.run_cairo(() => surface.ps_restrict_to_level(@cairoon.PsLevel3)),
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
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  surface.ps_dsc_begin_page_setup()
  surface.ps_dsc_begin_setup()
  inspect(surface.status().is_success(), content="true")
}

///|
test "ps surface validates dsc comments and path strings" {
  let surface = @cairoon.Surface::ps(10.0, 10.0)
  let invalid_comment = @cairoon.run_cairo(() => surface.ps_dsc_comment(""))
  match invalid_comment {
    Err(@cairoon.CairoError(@cairoon.InvalidDscComment, _)) => ()
    _ => @test.fail("expected InvalidDscComment")
  }

  let invalid_path = "/tmp/cairoon\u{0}bad.ps"
  let invalid = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::ps(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PS path")
  }
}

///|
test "ps surface filename constructor renders and finishes" {
  let path = "/tmp/cairoon_surface_ps_roundtrip.ps"
  let surface = @cairoon.Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test "ps surface methods reject other surface types" {
  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
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
    @cairoon.run_cairo(() => image.ps_restrict_to_level(@cairoon.PsLevel2)),
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
  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
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
