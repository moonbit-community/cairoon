///|
fn lifetime_scaled_font_from_local_inputs() -> @cairoon.ScaledFont raise @cairoon.CairoError {
  let face = @cairoon.FontFace::toy("serif", weight=@cairoon.FontWeightBold)
  let options = @cairoon.FontOptions::new()
  options.set_antialias(@cairoon.AntialiasGray)
  @cairoon.ScaledFont::new(
    face,
    @cairoon.Matrix::new(xx=12.0, yy=12.0),
    @cairoon.Matrix::new(xx=2.0, yy=3.0),
    options,
  )
}

///|
fn lifetime_mesh_pattern() -> @cairoon.Pattern raise @cairoon.CairoError {
  let pattern = @cairoon.Pattern::mesh()
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
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  ctx.rectangle(0.0, 0.0, 2.0, 2.0)
  let path = ctx.copy_path()
  let flat_path = ctx.copy_path_flat()
  let target_ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 4, 4),
  )
  target_ctx.append_path(path)
  target_ctx.append_path(flat_path)

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=2, height=2),
  )
  let region_copy = region.copy()
  let _ = region_copy.union_rectangle(
    @cairoon.RectangleInt::new(x=2, y=0, width=2, height=2),
  )

  let options = @cairoon.FontOptions::new()
  options.set_antialias(@cairoon.AntialiasGray)
  let copied_options = options.copy()
  copied_options.merge(options)

  let face = @cairoon.FontFace::toy("serif", weight=@cairoon.FontWeightBold)
  let scaled_font = lifetime_scaled_font_from_local_inputs()
  let returned_face = scaled_font.get_font_face()
  let returned_options = scaled_font.get_font_options()
  let _ = scaled_font.extents()
  let _ = scaled_font.text_extents("ffi")

  let solid = @cairoon.Pattern::solid_rgba(0.25, 0.5, 0.75, 1.0)
  let gradient = @cairoon.Pattern::linear(0.0, 0.0, 4.0, 0.0)
  gradient.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
  gradient.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
  gradient.set_matrix(@cairoon.Matrix::new(xx=0.5, yy=0.5))
  let mesh = lifetime_mesh_pattern()
  let mesh_path = mesh.mesh_get_path(0)

  let recording = @cairoon.Surface::recording(
    @cairoon.ContentColorAlpha,
    extents=Some(@cairoon.Rectangle::new(0.0, 0.0, 4.0, 4.0)),
  )
  let recorder = @cairoon.Context::new(recording)
  recorder.rectangle(0.0, 0.0, 1.0, 1.0)
  recorder.fill()
  let similar = surface.create_similar(@cairoon.ContentColorAlpha, 2, 2)
  let similar_image = surface.create_similar_image(@cairoon.Argb32, 2, 2)
  let tee = @cairoon.Surface::tee(similar)
  tee.tee_add(similar_image)
  let _ = tee.tee_index(0)
  let _ = tee.tee_index(1)
  tee.tee_remove(similar_image)

  let chunk_count = Ref(0)
  let device = @cairoon.Device::script_stream(fn(chunk) {
    if chunk.length() > 0 {
      chunk_count.val += 1
    }
    @cairoon.Success
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
test "external value wrapper allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_value_wrappers(index)
  }
}
