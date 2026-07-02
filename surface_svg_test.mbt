///|
fn expect_svg_surface_type_mismatch(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_svg_surface_finished(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "svg version helpers expose cairo-supported versions" {
  let versions = SVGVersion::supported()
  let version : SVGVersion = SvgVersion1_2
  inspect(versions.length() > 0, content="true")
  inspect(versions.any(item => item == version), content="true")
  inspect(version.to_string().contains("SVG"), content="true")
}

///|
test "svg surface no-output constructor exposes units and version restriction" {
  let surface = Surface::svg(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypeSvg")
  let default_unit = surface.svg_get_document_unit()
  inspect(
    default_unit == SvgUnitPt || default_unit == SvgUnitUser,
    content="true",
  )

  surface.svg_set_document_unit(SvgUnitPx)
  debug_inspect(surface.svg_get_document_unit(), content="SvgUnitPx")
  surface.svg_restrict_to_version(SvgVersion1_2)
  surface.finish()

  expect_svg_surface_finished(
    run_cairo(() => surface.svg_set_document_unit(SvgUnitPx)),
  )
  expect_svg_surface_finished(
    run_cairo(() => surface.svg_restrict_to_version(SvgVersion1_2)),
  )
}

///|
test "svg surface filename constructor and invalid paths" {
  let path = "/tmp/cairoon_surface_svg_roundtrip.svg"
  let surface = Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()

  let invalid_path = "/tmp/cairoon\u{0}bad.svg"
  let invalid = run_cairo(() => {
    let _ = Surface::svg(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for SVG path")
  }
}

///|
test "svg surface methods reject other surface types" {
  let image = Surface::image(Argb32, 1, 1)
  expect_svg_surface_type_mismatch(
    run_cairo(() => {
      let _ = image.svg_get_document_unit()
      ()
    }),
  )
  expect_svg_surface_type_mismatch(
    run_cairo(() => image.svg_set_document_unit(SvgUnitPx)),
  )
  expect_svg_surface_type_mismatch(
    run_cairo(() => image.svg_restrict_to_version(SvgVersion1_2)),
  )
}
