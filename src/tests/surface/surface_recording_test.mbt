///|
fn expect_recording_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_recording_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
test "recording surface exposes bounded and unbounded extents" {
  let unbounded = @cairoon.Surface::recording(@cairoon.ContentColorAlpha)
  debug_inspect(unbounded.get_type(), content="SurfaceTypeRecording")
  inspect(unbounded.recording_get_extents() is None, content="true")
  debug_inspect(
    unbounded.recording_ink_extents().components(),
    content="(0, 0, 0, 0)",
  )

  let bounds = @cairoon.Rectangle::new(1.0, 2.0, 3.0, 4.0)
  let bounded = @cairoon.Surface::recording(
    @cairoon.ContentColor,
    extents=Some(bounds),
  )
  match bounded.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(1, 2, 3, 4)")
    None => @test.fail("expected recording surface extents")
  }
  debug_inspect(bounded.get_content(), content="ContentColor")
}

///|
test "recording surface accepts pycairo raw content ints" {
  let bounds = @cairoon.Rectangle::new(0.0, 0.0, 2.0, 3.0)
  let recording = @cairoon.Surface::recording_raw(0x3000, extents=Some(bounds))
  debug_inspect(recording.get_type(), content="SurfaceTypeRecording")
  inspect(recording.get_content_raw(), content="12288")
  debug_inspect(recording.get_content(), content="ContentColorAlpha")
  match recording.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(0, 0, 2, 3)")
    None => @test.fail("expected recording surface extents")
  }

  expect_recording_invalid_content(
    @cairoon.run_cairo(() => @cairoon.Surface::recording_raw(0)),
  )
}

///|
test "recording surface records drawing operations and replays as pattern" {
  let recording = @cairoon.Surface::recording(@cairoon.ContentColorAlpha)
  let recorder = @cairoon.Context::new(recording)
  recorder.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  recorder.rectangle(0.0, 0.0, 1.0, 1.0)
  recorder.fill()

  debug_inspect(
    recording.recording_ink_extents().components(),
    content="(0, 0, 1, 1)",
  )

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(@cairoon.Pattern::for_surface(recording))
  ctx.paint()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "recording surface methods reject other surface types" {
  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  expect_recording_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.recording_ink_extents()
      ()
    }),
  )
  expect_recording_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.recording_get_extents()
      ()
    }),
  )
}
