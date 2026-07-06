///|
fn inspect_tee_pixel(bytes : Bytes, expected : Array[Int]) -> Unit raise {
  inspect(bytes.length(), content="\{expected.length()}")
  for index in 0..<expected.length() {
    inspect(bytes[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn paint_tee(
  surface : Surface,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgba(red, green, blue, 1.0)
  ctx.paint()
}

///|
fn tee_with_local_target() -> Surface raise CairoError {
  let master_data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let target_data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let master = Surface::image_for_data(master_data, Argb32, 1, 1)
  let target = Surface::image_for_data(target_data, Argb32, 1, 1)
  let tee = Surface::tee(master)
  tee.tee_add(target)
  tee
}

///|
test "tee surface mirrors drawing to primary and added target" {
  let primary = Surface::image(Argb32, 1, 1)
  let target = Surface::image(Argb32, 1, 1)
  let tee = Surface::tee(primary)
  debug_inspect(tee.get_type(), content="SurfaceTypeTee")

  tee.tee_add(target)
  paint_tee(tee, 1.0, 0.0, 0.0)
  inspect_tee_pixel(primary.copy_data(), [0, 0, 255, 255])
  inspect_tee_pixel(target.copy_data(), [0, 0, 255, 255])

  let indexed_primary = tee.tee_index(0)
  let indexed_target = tee.tee_index(1)
  debug_inspect(indexed_primary.get_type(), content="SurfaceTypeImage")
  debug_inspect(indexed_target.get_type(), content="SurfaceTypeImage")
  inspect_tee_pixel(indexed_primary.copy_data(), [0, 0, 255, 255])
  inspect_tee_pixel(indexed_target.copy_data(), [0, 0, 255, 255])

  tee.tee_remove(target)
  paint_tee(tee, 0.0, 1.0, 0.0)
  inspect_tee_pixel(primary.copy_data(), [0, 255, 0, 255])
  inspect_tee_pixel(target.copy_data(), [0, 0, 255, 255])
}

///|
test "tee surface retains primary and added target wrappers" {
  let tee = tee_with_local_target()
  paint_tee(tee, 0.0, 0.0, 1.0)
  inspect_tee_pixel(tee.tee_index(0).copy_data(), [255, 0, 0, 255])
  inspect_tee_pixel(tee.tee_index(1).copy_data(), [255, 0, 0, 255])
}

///|
test "tee index preserves cairo no-memory status for positive out of range" {
  let primary = Surface::image(Argb32, 1, 1)
  let tee = Surface::tee(primary)
  let out_of_range = run_cairo(() => tee.tee_index(1))
  match out_of_range {
    Err(CairoMemoryError(NoMemory, _)) => ()
    _ => @test.fail("expected NoMemory for out-of-range tee index")
  }
}

///|
test "tee methods map subtype and index errors" {
  let image = Surface::image(Argb32, 1, 1)
  let other = Surface::image(Argb32, 1, 1)

  let add = run_cairo(() => image.tee_add(other))
  match add {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch for tee_add on image surface")
  }

  let remove = run_cairo(() => image.tee_remove(other))
  match remove {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ =>
      @test.fail("expected SurfaceTypeMismatch for tee_remove on image surface")
  }

  let index = run_cairo(() => image.tee_index(0))
  match index {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ =>
      @test.fail("expected SurfaceTypeMismatch for tee_index on image surface")
  }

  let tee = Surface::tee(image)
  let negative = run_cairo(() => tee.tee_index(-1))
  match negative {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex for negative tee index")
  }

  let self_add = run_cairo(() => tee.tee_add(tee))
  match self_add {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected InvalidStatus for tee self-add")
  }

  let self_remove = run_cairo(() => tee.tee_remove(tee))
  match self_remove {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected InvalidStatus for tee self-remove")
  }
}
