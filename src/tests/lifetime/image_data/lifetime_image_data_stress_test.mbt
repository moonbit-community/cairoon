///|
fn lifetime_image_data_from_local_surface(
  value : Byte,
) -> @cairoon.ImageData raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let data = surface.get_data()
  data.set(0, value)
  data
}

///|
fn expect_lifetime_image_data_rgb24_white(data : Bytes) -> Unit raise {
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
fn expect_lifetime_image_data_mapped_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn lifetime_stress_image_data_views(index : Int) -> Unit raise {
  let first : Byte = if index % 2 == 0 { b'\x11' } else { b'\x22' }
  let second : Byte = if index % 2 == 0 { b'\x33' } else { b'\x44' }

  let retained = lifetime_image_data_from_local_surface(first)
  retained.set(1, second)
  let retained_copy = retained.copy()
  if retained_copy.length() != 4 ||
    retained_copy[0] != first ||
    retained_copy[1] != second {
    @test.fail("image data view lost retained surface storage")
  }

  let backing : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let backed_surface = @cairoon.Surface::image_for_data(backing, Argb32, 1, 1)
  let backed = backed_surface.get_data()
  backed.set(2, first)
  backed.set(3, second)
  if backing[2] != first || backing[3] != second {
    @test.fail("image data view stopped sharing buffer-backed storage")
  }

  let base = @cairoon.Surface::image(Rgb24, 1, 1)
  let mapped = base.map_to_image()
  let mapped_data = mapped.get_data()
  mapped_data.set(0, b'\xff')
  mapped_data.set(1, b'\xff')
  mapped_data.set(2, b'\xff')
  mapped_data.set(3, b'\xff')
  if mapped_data.copy().length() != 4 {
    @test.fail("mapped image data view reported unexpected length")
  }
  mapped.unmap()
  if index % 250 == 0 {
    expect_lifetime_image_data_rgb24_white(base.copy_data())
    expect_lifetime_image_data_mapped_finished(
      @cairoon.run_cairo(() => {
        let _ = mapped_data.copy()
        ()
      }),
    )
    inspect(retained.length(), content="4")
    inspect(backed.length(), content="4")
  }
}

///|
test "image data view allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_image_data_views(index)
  }
}
