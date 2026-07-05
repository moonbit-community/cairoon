///|
fn expect_recording_surface_type_mismatch(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_recording_invalid_content(
  result : Result[T, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
test "recording surface exposes bounded and unbounded extents" {
  let unbounded = Surface::recording(ContentColorAlpha)
  debug_inspect(unbounded.get_type(), content="SurfaceTypeRecording")
  inspect(unbounded.recording_get_extents() is None, content="true")
  debug_inspect(
    unbounded.recording_ink_extents().components(),
    content="(0, 0, 0, 0)",
  )

  let bounds = Rectangle::new(1.0, 2.0, 3.0, 4.0)
  let bounded = Surface::recording(ContentColor, extents=Some(bounds))
  match bounded.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(1, 2, 3, 4)")
    None => @test.fail("expected recording surface extents")
  }
  debug_inspect(bounded.get_content(), content="ContentColor")
}

///|
test "recording surface accepts pycairo raw content ints" {
  let bounds = Rectangle::new(0.0, 0.0, 2.0, 3.0)
  let recording = Surface::recording_raw(0x3000, extents=Some(bounds))
  debug_inspect(recording.get_type(), content="SurfaceTypeRecording")
  inspect(recording.get_content_raw(), content="12288")
  debug_inspect(recording.get_content(), content="ContentColorAlpha")
  match recording.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(0, 0, 2, 3)")
    None => @test.fail("expected recording surface extents")
  }

  expect_recording_invalid_content(run_cairo(() => Surface::recording_raw(0)))
}

///|
test "recording surface records drawing operations and replays as pattern" {
  let recording = Surface::recording(ContentColorAlpha)
  let recorder = Context::new(recording)
  recorder.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  recorder.rectangle(0.0, 0.0, 1.0, 1.0)
  recorder.fill()

  debug_inspect(
    recording.recording_ink_extents().components(),
    content="(0, 0, 1, 1)",
  )

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(Pattern::for_surface(recording))
  ctx.paint()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "recording surface methods reject other surface types" {
  let image = Surface::image(Argb32, 1, 1)
  expect_recording_surface_type_mismatch(
    run_cairo(() => {
      let _ = image.recording_ink_extents()
      ()
    }),
  )
  expect_recording_surface_type_mismatch(
    run_cairo(() => {
      let _ = image.recording_get_extents()
      ()
    }),
  )
}
