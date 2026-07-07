///|
fn expect_surface_invalid_size(
  result : Result[@cairoon.Surface, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }
}

///|
fn[T] expect_surface_finished(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn[T] expect_surface_type_mismatch(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_surface_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
fn[T] expect_surface_invalid_format(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidFormat, _)) => ()
    _ => @test.fail("expected InvalidFormat")
  }
}

///|
test "surface equality and hash use cairo pointer identity" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  let target = ctx.get_target()
  inspect(surface.equal(target), content="true")
  inspect(target.equal(surface), content="true")
  inspect(surface.hash() == target.hash(), content="true")

  let other = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  inspect(surface.equal(other), content="false")
}

///|
test "surface finish records status for base methods" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  debug_inspect(surface.status(), content="Success")
  surface.finish()
  debug_inspect(surface.status(), content="SurfaceFinished")

  // Cairo finish is intentionally idempotent; operations after finish fail.
  surface.finish()
  expect_surface_finished(@cairoon.run_cairo(() => surface.flush()))
  expect_surface_finished(@cairoon.run_cairo(() => surface.copy_page()))
  expect_surface_finished(@cairoon.run_cairo(() => surface.show_page()))
}

///|
test "surface with_finished finishes after success and cairo errors" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let len = surface.with_finished(() => {
    let ctx = @cairoon.Context::new(surface)
    ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    ctx.paint()
    surface.copy_data().length()
  })
  inspect(len, content="4")
  debug_inspect(surface.status(), content="SurfaceFinished")
  expect_surface_finished(@cairoon.run_cairo(() => surface.flush()))

  let failed_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => {
      failed_surface.with_finished(() => {
        failed_surface.create_similar(@cairoon.ContentColor, -1, 1)
      })
    }),
  )
  debug_inspect(failed_surface.status(), content="SurfaceFinished")
}

///|
test "surface finished status covers capability dirty and state methods" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  inspect(
    surface.has_show_text_glyphs() || !surface.has_show_text_glyphs(),
    content="true",
  )
  surface.finish()
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.has_show_text_glyphs()),
  )
  expect_surface_finished(@cairoon.run_cairo(() => surface.mark_dirty()))
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.mark_dirty_rectangle(0, 0, 1, 1)),
  )
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.set_device_offset(1.0, 2.0)),
  )
  expect_surface_finished(@cairoon.run_cairo(() => surface.get_device_offset()))
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.set_device_scale(1.0, 2.0)),
  )
  expect_surface_finished(@cairoon.run_cairo(() => surface.get_device_scale()))
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.set_fallback_resolution(72.0, 72.0)),
  )
  expect_surface_finished(
    @cairoon.run_cairo(() => surface.get_fallback_resolution()),
  )
}

///|
test "surface similar constructors and state queries" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let similar = source.create_similar(@cairoon.ContentColor, 3, 4)
  inspect(similar.status().is_success(), content="true")
  debug_inspect(similar.get_content(), content="ContentColor")

  let image = source.create_similar_image(@cairoon.Rgb24, 3, 4)
  inspect(image.status().is_success(), content="true")
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_content(), content="ContentColor")
  debug_inspect(image.get_format(), content="Rgb24")
  inspect(image.get_format_raw(), content="1")
  inspect(image.get_width(), content="3")
  inspect(image.get_height(), content="4")

  let raw_image = source.create_similar_image_raw(5, 1, 1)
  debug_inspect(raw_image.get_format(), content="Rgb30")
  inspect(raw_image.get_format_raw(), content="5")
}

///|
test "surface similar constructors validate invalid dimensions" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => source.create_similar(@cairoon.ContentColor, -1, 1)),
  )
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => source.create_similar(@cairoon.ContentColor, 1, -1)),
  )
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => source.create_similar_image(@cairoon.Argb32, -1, 1)),
  )
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => source.create_similar_image(@cairoon.Argb32, 1, -1)),
  )
  expect_surface_invalid_format(
    @cairoon.run_cairo(() => source.create_similar_image_raw(-1, 1, 1)),
  )
}

///|
test "surface device state and dirty markers round trip" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 3, 3)
  surface.set_device_offset(1.25, -2.5)
  debug_inspect(surface.get_device_offset(), content="(1.25, -2.5)")

  surface.set_device_scale(5.0, 3.0)
  debug_inspect(surface.get_device_scale(), content="(5, 3)")

  let bad_scale = @cairoon.run_cairo(() => surface.set_device_scale(0.0, 1.0))
  match bad_scale {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix for zero device scale")
  }

  surface.set_fallback_resolution(42.0, 96.0)
  debug_inspect(surface.get_fallback_resolution(), content="(42, 96)")

  surface.mark_dirty()
  surface.mark_dirty_rectangle(0, 0, 1, 1)

  let has_text_glyphs = surface.has_show_text_glyphs()
  inspect(has_text_glyphs || !has_text_glyphs, content="true")
}

///|
test "surface state and subsurface constructors preserve pycairo numeric limits" {
  let max_double = 1.7976931348623157e308
  let min_double = -max_double
  let min_positive = 2.2250738585072014e-308
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 100, 100)

  surface.set_device_offset(max_double, min_double)
  debug_inspect(
    surface.get_device_offset(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )

  surface.set_device_scale(max_double, min_double)
  debug_inspect(
    surface.get_device_scale(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )

  let huge_child = surface.create_for_rectangle(
    max_double, max_double, max_double, max_double,
  )
  inspect(huge_child.status().is_success(), content="true")

  let tiny_child = surface.create_for_rectangle(
    min_double, min_double, min_positive, min_positive,
  )
  inspect(tiny_child.status().is_success(), content="true")
}

///|
test "context paints deterministic argb32 bytes" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}
