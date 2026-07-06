///|
fn inspect_rgb24_bytes(bytes : Bytes, expected : Array[Int]) -> Unit raise {
  inspect(bytes.length(), content="\{expected.length()}")
  for i in 0..<expected.length() {
    inspect(bytes[i].to_int(), content="\{expected[i]}")
  }
}

///|
fn expect_mapped_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "mapped image paints whole surface and explicit unmap uploads" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 2, 1)
  inspect_rgb24_bytes(main.copy_data(), [0, 0, 0, 0, 0, 0, 0, 0])

  let mapped = main.map_to_image()
  inspect(mapped.status().is_success(), content="true")
  debug_inspect(mapped.get_format(), content="Rgb24")
  inspect(mapped.get_format_raw(), content="1")
  inspect(mapped.get_width(), content="2")
  inspect(mapped.get_height(), content="1")
  inspect(mapped.get_stride(), content="8")

  let ctx = @cairoon.Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  main.unmap_image(mapped)
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255, 255, 255, 255, 255])

  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    }),
  )
}

///|
test "mapped image extents update only selected rectangle" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 2, 1)
  let mapped = main.map_to_image(
    extents=Some(@cairoon.RectangleInt::new(x=0, y=0, width=1, height=1)),
  )
  inspect(mapped.get_width(), content="1")
  inspect(mapped.get_height(), content="1")

  let ctx = @cairoon.Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  mapped.unmap()
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255, 0, 0, 0, 0])
}

///|
test "mapped image rejects wrong base and double unmap" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 2, 1)
  let mapped = main.map_to_image()
  let other = @cairoon.Surface::image(@cairoon.Rgb24, 2, 1)

  let wrong_base = @cairoon.run_cairo(() => other.unmap_image(mapped))
  inspect(wrong_base is Err(_), content="true")
  match wrong_base {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }

  main.unmap_image(mapped)
  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => main.unmap_image(mapped)),
  )
  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = @cairoon.Context::new_for_mapped_image(mapped)
      ()
    }),
  )
}

///|
test "mapped image can unmap through mapped wrapper" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = main.map_to_image()
  let ctx = @cairoon.Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  mapped.unmap()
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255])
  expect_mapped_surface_finished(@cairoon.run_cairo(() => mapped.unmap()))
}

///|
test "mapped image with_unmapped unmaps after success and cairo errors" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = main.map_to_image()
  mapped.with_unmapped(() => {
    let ctx = @cairoon.Context::new_for_mapped_image(mapped)
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.paint()
  })
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255])
  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    }),
  )

  let failed_main = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let failed_mapped = failed_main.map_to_image()
  let failed = @cairoon.run_cairo(() => {
    failed_mapped.with_unmapped(() => {
      let _ = failed_main.create_similar(@cairoon.ContentColor, -1, 1)
      ()
    })
  })
  match failed {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }
  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = failed_mapped.copy_data()
      ()
    }),
  )
}

///|
test "mapped image with_unmapped uploads before propagated cairo error" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = main.map_to_image()
  let failed = @cairoon.run_cairo(() => {
    mapped.with_unmapped(() => {
      let ctx = @cairoon.Context::new_for_mapped_image(mapped)
      ctx.set_source_rgb(1.0, 1.0, 1.0)
      ctx.paint()
      let _ = main.create_similar(@cairoon.ContentColor, -1, 1)
      ()
    })
  })
  match failed {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255])
  expect_mapped_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    }),
  )
}
