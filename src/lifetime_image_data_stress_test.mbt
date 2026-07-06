///|
fn lifetime_image_data_from_local_surface(
  value : Byte,
) -> ImageData raise CairoError {
  let surface = Surface::image(Argb32, 1, 1)
  let data = surface.get_data()
  data.set(0, value)
  data
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
  let backed_surface = Surface::image_for_data(backing, Argb32, 1, 1)
  let backed = backed_surface.get_data()
  backed.set(2, first)
  backed.set(3, second)
  if backing[2] != first || backing[3] != second {
    @test.fail("image data view stopped sharing buffer-backed storage")
  }

  let base = Surface::image(Rgb24, 1, 1)
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
    expect_lifetime_rgb24_white(base.copy_data())
    expect_lifetime_mapped_finished(
      run_cairo(() => {
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
