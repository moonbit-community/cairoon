///|
fn expect_ps_surface_type_mismatch(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_ps_surface_finished(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "ps level helpers expose cairo-supported levels" {
  let levels = PSLevel::supported()
  let level : PSLevel = PsLevel3
  inspect(levels.length() > 0, content="true")
  inspect(levels.any(item => item == level), content="true")
  inspect(level.to_string().contains("PS"), content="true")
}

///|
test "ps surface no-output constructor exposes eps size dsc and level APIs" {
  let surface = Surface::ps(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePs")
  inspect(surface.ps_get_eps() || !surface.ps_get_eps(), content="true")
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

  expect_ps_surface_finished(run_cairo(() => surface.ps_set_eps(false)))
  expect_ps_surface_finished(
    run_cairo(() => surface.ps_restrict_to_level(PsLevel3)),
  )
}

///|
test "ps surface validates dsc comments and path strings" {
  let surface = Surface::ps(10.0, 10.0)
  let invalid_comment = run_cairo(() => surface.ps_dsc_comment(""))
  match invalid_comment {
    Err(CairoError(InvalidDscComment, _)) => ()
    _ => @test.fail("expected InvalidDscComment")
  }

  let invalid_path = "/tmp/cairoon\u{0}bad.ps"
  let invalid = run_cairo(() => {
    let _ = Surface::ps(10.0, 10.0, path=Some(invalid_path))
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
  let surface = Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test "ps surface methods reject other surface types" {
  let image = Surface::image(Argb32, 1, 1)
  expect_ps_surface_type_mismatch(
    run_cairo(() => {
      let _ = image.ps_get_eps()
      ()
    }),
  )
  expect_ps_surface_type_mismatch(run_cairo(() => image.ps_set_eps(true)))
  expect_ps_surface_type_mismatch(
    run_cairo(() => image.ps_restrict_to_level(PsLevel2)),
  )
  expect_ps_surface_type_mismatch(
    run_cairo(() => image.ps_dsc_comment("%%Title: nope")),
  )
}

///|
test "ps setup and size methods reject other surface types" {
  let image = Surface::image(Argb32, 1, 1)
  expect_ps_surface_type_mismatch(
    run_cairo(() => image.ps_set_size(10.0, 10.0)),
  )
  expect_ps_surface_type_mismatch(run_cairo(() => image.ps_dsc_begin_setup()))
  expect_ps_surface_type_mismatch(
    run_cairo(() => image.ps_dsc_begin_page_setup()),
  )
}
