///|
fn lifetime_child_from_local_parent() -> Surface raise CairoError {
  let parent = Surface::image(Argb32, 4, 4)
  parent.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
}

///|
fn lifetime_pattern_from_data_surface() -> Pattern raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  Pattern::for_surface(source)
}

///|
fn lifetime_raster_pattern_from_data_surface() -> Pattern raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) { source })
  pattern
}

///|
fn lifetime_mapped_from_local_base() -> MappedImageSurface raise CairoError {
  let base = Surface::image(Rgb24, 1, 1)
  base.map_to_image()
}

///|
fn lifetime_context_from_local_mapping() -> Context raise CairoError {
  let mapped = lifetime_mapped_from_local_base()
  Context::new_for_mapped_image(mapped)
}

///|
fn expect_lifetime_argb32_blue(data : Bytes) -> Unit raise {
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn expect_lifetime_rgb24_white(data : Bytes) -> Unit raise {
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
fn expect_lifetime_mapped_finished(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn lifetime_scaled_font_from_local_inputs() -> ScaledFont raise CairoError {
  let face = FontFace::toy("serif", weight=FontWeightBold)
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  ScaledFont::new(
    face,
    Matrix::new(xx=12.0, yy=12.0),
    Matrix::new(xx=2.0, yy=3.0),
    options,
  )
}

///|
fn lifetime_mesh_pattern() -> Pattern raise CairoError {
  let pattern = Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(2.0, 0.0)
  pattern.mesh_line_to(0.0, 2.0)
  pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(1, 0.0, 1.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(2, 0.0, 0.0, 1.0, 1.0)
  pattern.mesh_end_patch()
  pattern
}

///|
fn lifetime_stress_value_wrappers(index : Int) -> Unit raise {
  let surface = Surface::image(Argb32, 4, 4)
  let ctx = Context::new(surface)
  ctx.rectangle(0.0, 0.0, 2.0, 2.0)
  let path = ctx.copy_path()
  let flat_path = ctx.copy_path_flat()
  let target_ctx = Context::new(Surface::image(Argb32, 4, 4))
  target_ctx.append_path(path)
  target_ctx.append_path(flat_path)

  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=2, height=2),
  )
  let region_copy = region.copy()
  let _ = region_copy.union_rectangle(
    RectangleInt::new(x=2, y=0, width=2, height=2),
  )

  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  let copied_options = options.copy()
  copied_options.merge(options)

  let face = FontFace::toy("serif", weight=FontWeightBold)
  let scaled_font = lifetime_scaled_font_from_local_inputs()
  let returned_face = scaled_font.get_font_face()
  let returned_options = scaled_font.get_font_options()
  let _ = scaled_font.extents()
  let _ = scaled_font.text_extents("ffi")

  let solid = Pattern::solid_rgba(0.25, 0.5, 0.75, 1.0)
  let gradient = Pattern::linear(0.0, 0.0, 4.0, 0.0)
  gradient.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
  gradient.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
  gradient.set_matrix(Matrix::new(xx=0.5, yy=0.5))
  let mesh = lifetime_mesh_pattern()
  let mesh_path = mesh.mesh_get_path(0)

  let recording = Surface::recording(
    ContentColorAlpha,
    extents=Some(Rectangle::new(0.0, 0.0, 4.0, 4.0)),
  )
  let recorder = Context::new(recording)
  recorder.rectangle(0.0, 0.0, 1.0, 1.0)
  recorder.fill()
  let similar = surface.create_similar(ContentColorAlpha, 2, 2)
  let similar_image = surface.create_similar_image(Argb32, 2, 2)
  let tee = Surface::tee(similar)
  tee.tee_add(similar_image)
  let _ = tee.tee_index(0)
  let _ = tee.tee_index(1)
  tee.tee_remove(similar_image)

  let chunk_count = Ref(0)
  let device = Device::script_stream(fn(chunk) {
    if chunk.length() > 0 {
      chunk_count.val += 1
    }
    Success
  })
  let device_type = device.get_type()
  device.script_write_comment("lifetime stress")
  device.flush()
  device.finish()

  if index % 250 == 0 {
    inspect(path.length(), content="6")
    inspect(flat_path.length() >= 5, content="true")
    inspect(path.to_string().contains("line_to"), content="true")
    debug_inspect(
      region_copy.get_extents().components(),
      content="(0, 0, 4, 2)",
    )
    inspect(copied_options.equal(options), content="true")
    inspect(face.get_family(), content="serif")
    inspect(returned_face.get_family(), content="serif")
    debug_inspect(returned_options.get_antialias(), content="AntialiasGray")
    debug_inspect(solid.get_rgba(), content="(0.25, 0.5, 0.75, 1)")
    inspect(gradient.get_color_stop_count(), content="2")
    inspect(mesh.mesh_get_patch_count(), content="1")
    inspect(mesh_path.length() > 0, content="true")
    debug_inspect(
      recording.recording_get_extents().map(rect => rect.components()),
      content="Some((0, 0, 4, 4))",
    )
    inspect(recording.recording_ink_extents().width > 0.0, content="true")
    debug_inspect(device_type, content="DeviceTypeScript")
    inspect(chunk_count.val > 0, content="true")
  }
}

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
fn lifetime_paint_stream_surface(surface : Surface) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
fn expect_lifetime_write_error(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError")
  }
}

///|
fn lifetime_record_stream_chunk(
  chunk : Bytes,
  chunk_count : Ref[Int],
  byte_count : Ref[Int],
) -> Status {
  chunk_count.val += 1
  byte_count.val += chunk.length()
  Success
}

///|
fn lifetime_png_bytes() -> Bytes raise CairoError {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  let mut output = Bytes::default()
  surface.write_to_png_stream(fn(chunk) {
    output = output + chunk
    Success
  })
  output
}

///|
fn lifetime_bytes_slice(bytes : Bytes, offset : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(i) { bytes[offset + i] })
}

///|
fn lifetime_stress_stream_callbacks(index : Int) -> Unit raise {
  let pdf_chunks = Ref(0)
  let pdf_bytes = Ref(0)
  let pdf = Surface::pdf_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, pdf_chunks, pdf_bytes)
  })
  lifetime_paint_stream_surface(pdf)

  let ps_chunks = Ref(0)
  let ps_bytes = Ref(0)
  let ps = Surface::ps_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, ps_chunks, ps_bytes)
  })
  lifetime_paint_stream_surface(ps)

  let svg_chunks = Ref(0)
  let svg_bytes = Ref(0)
  let svg = Surface::svg_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, svg_chunks, svg_bytes)
  })
  lifetime_paint_stream_surface(svg)

  let image = Surface::image(Argb32, 1, 1)
  let image_ctx = Context::new(image)
  image_ctx.set_source_rgb(1.0, 0.0, 0.0)
  image_ctx.paint()
  let png_write_chunks = Ref(0)
  let png_write_bytes = Ref(0)
  image.write_to_png_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, png_write_chunks, png_write_bytes)
  })

  let input = lifetime_png_bytes()
  let offset = Ref(0)
  let readback = Surface::image_from_png_stream(fn(length) {
    let chunk = lifetime_bytes_slice(input, offset.val, length)
    offset.val += length
    chunk
  })

  let script_chunks = Ref(0)
  let script_bytes = Ref(0)
  let script = Device::script_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, script_chunks, script_bytes)
  })
  let script_surface = Surface::script(script, ContentColorAlpha, 4.0, 4.0)
  lifetime_paint_stream_surface(script_surface)
  script.finish()

  if index % 250 == 0 {
    inspect(pdf_chunks.val > 0, content="true")
    inspect(pdf_bytes.val > 0, content="true")
    inspect(ps_chunks.val > 0, content="true")
    inspect(ps_bytes.val > 0, content="true")
    inspect(svg_chunks.val > 0, content="true")
    inspect(svg_bytes.val > 0, content="true")
    inspect(png_write_chunks.val > 0, content="true")
    inspect(png_write_bytes.val > 8, content="true")
    inspect(readback.get_width(), content="1")
    inspect(readback.get_height(), content="1")
    inspect(offset.val == input.length(), content="true")
    inspect(script_chunks.val > 0, content="true")
    inspect(script_bytes.val > 0, content="true")
  }

  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::pdf_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::ps_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::svg_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => image.write_to_png_stream(fn(_) { WriteError })),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing_script = Device::script_stream(fn(_) { WriteError })
      let failing_surface = Surface::script(
        failing_script,
        ContentColorAlpha,
        4.0,
        4.0,
      )
      let failing_ctx = Context::new(failing_surface)
      failing_ctx.paint()
      failing_surface.finish()
      failing_script.finish()
    }),
  )
}

///|
test "mapped image keeps base wrapper alive after local scope exits" {
  let mapped = lifetime_mapped_from_local_base()
  let ctx = Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  expect_lifetime_rgb24_white(mapped.copy_data())
  mapped.unmap()
  expect_lifetime_mapped_finished(
    run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    }),
  )
}

///|
test "context remains usable after mapped image wrapper scope exits" {
  let ctx = lifetime_context_from_local_mapping()
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  debug_inspect(ctx.status(), content="Success")
  let target = ctx.get_target()
  debug_inspect(target.status(), content="Success")
  debug_inspect(target.get_format(), content="Rgb24")
  inspect(target.get_width(), content="1")
  inspect(target.get_height(), content="1")
  inspect(target.copy_data().length(), content="4")
}

///|
test "retained cairo owner graph allocation stress" {
  for index in 0..<1000 {
    let child = lifetime_child_from_local_parent()
    let child_ctx = Context::new(child)
    child_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
    child_ctx.paint()
    child.flush()
    if !child.status().is_success() {
      @test.fail("subsurface became invalid during stress")
    }

    let pattern = lifetime_pattern_from_data_surface()
    let target = Surface::image(Argb32, 1, 1)
    let target_ctx = Context::new(target)
    target_ctx.set_source(pattern)
    target_ctx.paint()
    if index % 250 == 0 {
      expect_lifetime_argb32_blue(target.copy_data())
    }

    let raster_pattern = lifetime_raster_pattern_from_data_surface()
    let raster_target = Surface::image(Argb32, 1, 1)
    let raster_ctx = Context::new(raster_target)
    raster_ctx.set_source(raster_pattern)
    raster_ctx.paint()
    if index % 250 == 0 {
      expect_lifetime_argb32_blue(raster_target.copy_data())
    }

    let mapped = lifetime_mapped_from_local_base()
    let mapped_ctx = Context::new_for_mapped_image(mapped)
    mapped_ctx.set_source_rgb(1.0, 1.0, 1.0)
    mapped_ctx.paint()
    if index % 250 == 0 {
      expect_lifetime_rgb24_white(mapped.copy_data())
    }
    mapped.unmap()
  }
}

///|
test "external value wrapper allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_value_wrappers(index)
  }
}

///|
test "image data view allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_image_data_views(index)
  }
}

///|
test "backend stream callback allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_stream_callbacks(index)
  }
}
