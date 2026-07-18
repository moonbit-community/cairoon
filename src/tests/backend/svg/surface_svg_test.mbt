///|
fn expect_svg_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_svg_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "svg version helpers expose cairo-supported versions" {
  let versions = @cairoon.SVGVersion::supported()
  let version : @cairoon.SVGVersion = SvgVersion1_2
  inspect(versions.length() > 0, content="true")
  inspect(versions.any(item => item == version), content="true")
  inspect(version.to_string().contains("SVG"), content="true")
  inspect(@cairoon.SVGVersion::to_string_raw(0).contains("SVG"), content="true")
  for invalid in [-1, 99] {
    match
      @cairoon.run_cairo(() => @cairoon.SVGVersion::to_string_raw(invalid)) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => @test.fail("expected InvalidStatus for invalid raw SVG version")
    }
  }
}

///|
test "svg surface exposes pycairo-compatible raw C-int backend enums" {
  let surface = @cairoon.Surface::svg(10.0, 10.0)
  surface.svg_set_document_unit_raw(3)
  inspect(surface.svg_get_document_unit_raw(), content="3")
  debug_inspect(surface.svg_get_document_unit(), content="SvgUnitPx")
  surface.svg_set_document_unit_raw(99)
  inspect(surface.svg_get_document_unit_raw(), content="3")
  surface.svg_restrict_to_version_raw(99)
  debug_inspect(surface.status(), content="Success")
  surface.svg_restrict_to_version_raw(1)
  surface.finish()
  expect_svg_surface_finished(
    @cairoon.run_cairo(() => surface.svg_set_document_unit_raw(3)),
  )
  expect_svg_surface_finished(
    @cairoon.run_cairo(() => surface.svg_restrict_to_version_raw(1)),
  )
}

///|
test "svg surface no-output constructor exposes units and version restriction" {
  let surface = @cairoon.Surface::svg(10.0, 10.0)
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
    @cairoon.run_cairo(() => surface.svg_set_document_unit(SvgUnitPx)),
  )
  expect_svg_surface_finished(
    @cairoon.run_cairo(() => surface.svg_restrict_to_version(SvgVersion1_2)),
  )
}

///|
test "svg surface filename constructor and invalid paths" {
  let path = "/tmp/cairoon_surface_svg_roundtrip.svg"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }

  let surface = @cairoon.Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()

  let output = @fs.read_file_to_string(path)
  inspect(output.length() > 16, content="true")
  inspect(output.contains("<svg"), content="true")
  @fs.remove_file(path)

  let invalid_path = "/tmp/cairoon\u{0}bad.svg"
  let invalid = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::svg(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for SVG path")
  }
}

///|
test "svg surface methods reject other surface types" {
  let image = @cairoon.Surface::image(Argb32, 1, 1)
  expect_svg_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.svg_get_document_unit()
      ()
    }),
  )
  expect_svg_surface_type_mismatch(
    @cairoon.run_cairo(() => image.svg_set_document_unit(SvgUnitPx)),
  )
  expect_svg_surface_type_mismatch(
    @cairoon.run_cairo(() => image.svg_set_document_unit_raw(3)),
  )
  expect_svg_surface_type_mismatch(
    @cairoon.run_cairo(() => image.svg_restrict_to_version(SvgVersion1_2)),
  )
  expect_svg_surface_type_mismatch(
    @cairoon.run_cairo(() => image.svg_restrict_to_version_raw(1)),
  )
}

///|
test "svg document unit getter rejects finished surfaces" {
  let surface = @cairoon.Surface::svg(10.0, 10.0)
  surface.finish()
  expect_svg_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = surface.svg_get_document_unit()
      ()
    }),
  )
  expect_svg_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = surface.svg_get_document_unit_raw()
      ()
    }),
  )
}
