///|
fn expect_device_finished(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(DeviceFinished, _)) => ()
    _ => @test.fail("expected DeviceFinished")
  }
}

///|
fn expect_device_invalid_string(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn expect_device_surface_type_mismatch(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn script_chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
fn write_script_stream_with_status(status : Status) -> Unit raise CairoError {
  let device = Device::script_stream(fn(_) { status })
  let surface = Surface::script(device, ContentColorAlpha, 4.0, 4.0)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()
  device.finish()
}

///|
fn expect_script_stream_write_error(status : Status) -> Unit raise {
  let result = run_cairo(() => write_script_stream_with_status(status))
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from script stream writer")
  }
}

///|
test "image surfaces report no device" {
  let surface = Surface::image(Argb32, 10, 10)
  inspect(surface.get_device() is None, content="true")
}

///|
test "script device lifecycle and surface device references" {
  let device = Device::script("/tmp/cairoon_script_device_lifecycle.cs")
  debug_inspect(device.status(), content="Success")
  debug_inspect(device.get_type(), content="DeviceTypeScript")

  device.acquire()
  device.release()
  let acquired_type = device.with_acquired(() => device.get_type())
  debug_inspect(acquired_type, content="DeviceTypeScript")

  debug_inspect(device.script_get_mode(), content="ScriptModeAscii")
  device.script_set_mode(ScriptModeBinary)
  debug_inspect(device.script_get_mode(), content="ScriptModeBinary")
  device.script_set_mode(ScriptModeAscii)
  device.script_write_comment("cairoon script device")

  let surface = Surface::script(device, ContentColorAlpha, 42.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.flush()

  match surface.get_device() {
    Some(other) => {
      inspect(device.equal(other), content="true")
      inspect(device.hash() == other.hash(), content="true")
      debug_inspect(other.get_type(), content="DeviceTypeScript")
    }
    None => @test.fail("expected script surface device")
  }

  device.flush()
  device.finish()
  expect_device_finished(run_cairo(() => device.acquire()))
}

///|
test "script device with_finished finishes after success and cairo errors" {
  let device = Device::script("/tmp/cairoon_script_device_with_finished.cs")
  let type_ = device.with_finished(() => {
    device.script_write_comment("cairoon scoped device")
    device.get_type()
  })
  debug_inspect(type_, content="DeviceTypeScript")
  expect_device_finished(run_cairo(() => device.acquire()))

  let failed = Device::script(
    "/tmp/cairoon_script_device_with_finished_error.cs",
  )
  expect_device_invalid_string(
    run_cairo(() => {
      failed.with_finished(() => failed.script_write_comment("bad\u{0}comment"))
    }),
  )
  expect_device_finished(run_cairo(() => failed.acquire()))
}

///|
test "script stream device writes output chunks" {
  let chunks : Array[Bytes] = []
  let device = Device::script_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  debug_inspect(device.get_type(), content="DeviceTypeScript")
  device.script_write_comment("cairoon script stream")

  let surface = Surface::script(device, ContentColorAlpha, 4.0, 4.0)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()
  device.finish()

  inspect(chunks.length() > 0, content="true")
  inspect(
    script_chunks_to_string(chunks).contains("cairoon script stream"),
    content="true",
  )
}

///|
test "script stream writer status maps to cairo IO error" {
  expect_script_stream_write_error(WriteError)
}

///|
test "script stream writer invalid status maps to write error" {
  expect_script_stream_write_error(LastStatus)
}

///|
test "script device validates strings and recording replay surface type" {
  expect_device_invalid_string(
    run_cairo(() => {
      let _ = Device::script("/tmp/cairoon\u{0}bad.cs")
      ()
    }),
  )

  let device = Device::script("/tmp/cairoon_script_device_recording.cs")
  expect_device_invalid_string(
    run_cairo(() => device.script_write_comment("bad\u{0}comment")),
  )

  let recording = Surface::recording(ContentColorAlpha)
  let recorder = Context::new(recording)
  recorder.set_source_rgb(0.0, 0.0, 1.0)
  recorder.paint()
  device.script_from_recording_surface(recording)

  let image = Surface::image(Argb32, 1, 1)
  expect_device_surface_type_mismatch(
    run_cairo(() => device.script_from_recording_surface(image)),
  )
}

///|
test "script surface create_for_target wraps and paints target" {
  let device = Device::script("/tmp/cairoon_script_surface_target.cs")
  let target = Surface::image(Argb32, 1, 1)
  let surface = Surface::script_for_target(device, target)
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")

  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  surface.flush()
  target.flush()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn script_surface_from_local_device() -> Surface raise CairoError {
  let device = Device::script("/tmp/cairoon_script_surface_local_device.cs")
  Surface::script(device, ContentColorAlpha, 2.0, 2.0)
}

///|
test "script surface get_device survives local device wrapper scope" {
  let surface = script_surface_from_local_device()
  for _ in 0..<10 {
    match surface.get_device() {
      Some(device) =>
        debug_inspect(device.get_type(), content="DeviceTypeScript")
      None => @test.fail("expected script surface device")
    }
  }
}
