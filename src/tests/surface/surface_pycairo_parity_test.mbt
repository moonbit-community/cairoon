///|
fn expect_pycairo_surface_invalid_matrix(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
fn pycairo_similar_image_from_local_pdf() -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::pdf(1.0, 1.0)
  surface.create_similar_image(@cairoon.Argb32, 24, 42)
}

///|
test "pycairo surface context manager fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  surface.with_finished(() => surface.show_page())
  expect_surface_finished(@cairoon.run_cairo(() => surface.show_page()))
}

///|
test "pycairo surface cmp hash fixture" {
  let main = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  let ctx = @cairoon.Context::new(main)
  let target = ctx.get_target()

  inspect(target == main, content="true")
  inspect(target != main, content="false")
  inspect(target.equal(main), content="true")
  inspect(target.not_equal(main), content="false")
  inspect(Hash::hash(target) == Hash::hash(main), content="true")

  let other = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  inspect(main != other, content="true")
}

///|
test "pycairo surface content and format getters fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  inspect(surface.get_content_raw(), content="12288")
  debug_inspect(surface.get_format(), content="Argb32")
  inspect(surface.get_format_raw(), content="0")
}

///|
test "pycairo surface device scale fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  debug_inspect(surface.get_device_scale(), content="(1, 1)")

  surface.set_device_scale(5.0, 3.0)
  debug_inspect(surface.get_device_scale(), content="(5, 3)")

  expect_pycairo_surface_invalid_matrix(
    @cairoon.run_cairo(() => surface.set_device_scale(1.0, 0.0)),
  )

  let max_double = 1.7976931348623157e308
  surface.set_device_scale(max_double, -max_double)
  debug_inspect(
    surface.get_device_scale(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )

  expect_pycairo_surface_invalid_matrix(
    @cairoon.run_cairo(() => surface.set_device_scale(0.0, 0.0)),
  )
}

///|
test "pycairo surface create_for_rectangle fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 100, 100)
  let child = surface.create_for_rectangle(0.0, 0.0, 10.0, 10.0)
  inspect(child.status().is_success(), content="true")

  expect_surface_invalid_size(
    @cairoon.run_cairo(() => surface.create_for_rectangle(0.0, 0.0, 10.0, -1.0)),
  )
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => surface.create_for_rectangle(0.0, 0.0, -1.0, 10.0)),
  )

  let max_double = 1.7976931348623157e308
  let min_positive = 2.2250738585072014e-308
  inspect(
    surface
    .create_for_rectangle(max_double, max_double, max_double, max_double)
    .status()
    .is_success(),
    content="true",
  )
  inspect(
    surface
    .create_for_rectangle(-max_double, -max_double, min_positive, min_positive)
    .status()
    .is_success(),
    content="true",
  )
}

///|
test "pycairo surface create_similar_image fixture" {
  let surface = @cairoon.Surface::pdf(1.0, 1.0)
  let image = surface.create_similar_image(@cairoon.Argb32, 24, 42)
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_format(), content="Argb32")
  inspect(image.get_width(), content="24")
  inspect(image.get_height(), content="42")

  let scoped_image = pycairo_similar_image_from_local_pdf()
  debug_inspect(scoped_image.get_type(), content="SurfaceTypeImage")
  debug_inspect(scoped_image.get_format(), content="Argb32")
  inspect(scoped_image.get_width(), content="24")
  inspect(scoped_image.get_height(), content="42")
  inspect(scoped_image.copy_data().length(), content="4032")

  expect_surface_invalid_size(
    @cairoon.run_cairo(() => {
      surface.create_similar_image(@cairoon.Argb32, 24, -1)
    }),
  )
}

///|
test "pycairo surface create_similar fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  let similar = surface.create_similar(@cairoon.ContentColor, 10, 10)
  inspect(similar.status().is_success(), content="true")
  debug_inspect(similar.get_content(), content="ContentColor")

  expect_surface_invalid_size(
    @cairoon.run_cairo(() => {
      surface.create_similar(@cairoon.ContentColor, -1, 10)
    }),
  )
  expect_surface_invalid_size(
    @cairoon.run_cairo(() => {
      surface.create_similar(@cairoon.ContentColor, 10, -1)
    }),
  )
}

///|
test "pycairo surface device offset fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  surface.set_device_offset(1.0, 1.0)
  debug_inspect(surface.get_device_offset(), content="(1, 1)")

  let max_double = 1.7976931348623157e308
  surface.set_device_offset(max_double, -max_double)
  debug_inspect(
    surface.get_device_offset(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )
}

///|
test "pycairo surface fallback resolution and dirty page fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  surface.set_fallback_resolution(42.0, 42.0)
  debug_inspect(surface.get_fallback_resolution(), content="(42, 42)")

  surface.copy_page()
  surface.mark_dirty()
  surface.mark_dirty_rectangle(0, 0, 10, 10)
  surface.show_page()
  inspect(surface.status().is_success(), content="true")
}
