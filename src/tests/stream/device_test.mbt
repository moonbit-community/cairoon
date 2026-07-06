///|
fn expect_device_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.DeviceFinished, _)) => ()
    _ => @test.fail("expected DeviceFinished")
  }
}

///|
fn expect_device_invalid_string(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn expect_device_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_script_surface_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
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
fn write_script_stream_with_status(
  status : @cairoon.Status,
) -> Unit raise @cairoon.CairoError {
  let device = @cairoon.Device::script_stream(fn(_) { status })
  let surface = @cairoon.Surface::script(
    device,
    @cairoon.ContentColorAlpha,
    4.0,
    4.0,
  )
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()
  device.finish()
}

///|
fn expect_script_stream_write_error(status : @cairoon.Status) -> Unit raise {
  let result = @cairoon.run_cairo(() => write_script_stream_with_status(status))
  match result {
    Err(@cairoon.CairoIOError(@cairoon.WriteError, _)) => ()
    _ => @test.fail("expected WriteError from script stream writer")
  }
}

///|
test "image surfaces report no device" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  inspect(surface.get_device() is None, content="true")
}

///|
test "script device lifecycle and surface device references" {
  let device = @cairoon.Device::script(
    "/tmp/cairoon_script_device_lifecycle.cs",
  )
  debug_inspect(device.status(), content="Success")
  debug_inspect(device.get_type(), content="DeviceTypeScript")

  device.acquire()
  device.release()
  let acquired_type = device.with_acquired(() => device.get_type())
  debug_inspect(acquired_type, content="DeviceTypeScript")

  debug_inspect(device.script_get_mode(), content="ScriptModeAscii")
  device.script_set_mode(@cairoon.ScriptModeBinary)
  debug_inspect(device.script_get_mode(), content="ScriptModeBinary")
  device.script_set_mode(@cairoon.ScriptModeAscii)
  device.script_write_comment("cairoon script device")

  let surface = @cairoon.Surface::script(
    device,
    @cairoon.ContentColorAlpha,
    42.0,
    10.0,
  )
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")
  let ctx = @cairoon.Context::new(surface)
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
  expect_device_finished(@cairoon.run_cairo(() => device.acquire()))
}

///|
test "script device with_finished finishes after success and cairo errors" {
  let device = @cairoon.Device::script(
    "/tmp/cairoon_script_device_with_finished.cs",
  )
  let type_ = device.with_finished(() => {
    device.script_write_comment("cairoon scoped device")
    device.get_type()
  })
  debug_inspect(type_, content="DeviceTypeScript")
  expect_device_finished(@cairoon.run_cairo(() => device.acquire()))

  let failed = @cairoon.Device::script(
    "/tmp/cairoon_script_device_with_finished_error.cs",
  )
  expect_device_invalid_string(
    @cairoon.run_cairo(() => {
      failed.with_finished(() => failed.script_write_comment("bad\u{0}comment"))
    }),
  )
  expect_device_finished(@cairoon.run_cairo(() => failed.acquire()))
}

///|
test "script stream device writes output chunks" {
  let chunks : Array[Bytes] = []
  let device = @cairoon.Device::script_stream(fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  debug_inspect(device.get_type(), content="DeviceTypeScript")
  device.script_write_comment("cairoon script stream")

  let surface = @cairoon.Surface::script(
    device,
    @cairoon.ContentColorAlpha,
    4.0,
    4.0,
  )
  let ctx = @cairoon.Context::new(surface)
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
  expect_script_stream_write_error(@cairoon.WriteError)
}

///|
test "script stream writer invalid status maps to write error" {
  expect_script_stream_write_error(@cairoon.LastStatus)
}

///|
test "script device validates strings and recording replay surface type" {
  expect_device_invalid_string(
    @cairoon.run_cairo(() => {
      let _ = @cairoon.Device::script("/tmp/cairoon\u{0}bad.cs")
      ()
    }),
  )

  let device = @cairoon.Device::script(
    "/tmp/cairoon_script_device_recording.cs",
  )
  expect_device_invalid_string(
    @cairoon.run_cairo(() => device.script_write_comment("bad\u{0}comment")),
  )

  let recording = @cairoon.Surface::recording(@cairoon.ContentColorAlpha)
  let recorder = @cairoon.Context::new(recording)
  recorder.set_source_rgb(0.0, 0.0, 1.0)
  recorder.paint()
  device.script_from_recording_surface(recording)

  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  expect_device_surface_type_mismatch(
    @cairoon.run_cairo(() => device.script_from_recording_surface(image)),
  )
}

///|
test "script surface create_for_target wraps and paints target" {
  let device = @cairoon.Device::script("/tmp/cairoon_script_surface_target.cs")
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let surface = @cairoon.Surface::script_for_target(device, target)
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")

  let ctx = @cairoon.Context::new(surface)
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
test "script surface accepts pycairo raw content ints" {
  let device = @cairoon.Device::script(
    "/tmp/cairoon_script_surface_raw_content.cs",
  )
  let surface = @cairoon.Surface::script_raw(device, 0x1000, 2.0, 2.0)
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")
  inspect(surface.get_content_raw(), content="4096")
  debug_inspect(surface.get_content(), content="ContentColor")

  expect_script_surface_invalid_content(
    @cairoon.run_cairo(() => {
      let failing = @cairoon.Device::script(
        "/tmp/cairoon_script_surface_bad_content.cs",
      )
      @cairoon.Surface::script_raw(failing, 0, 2.0, 2.0)
    }),
  )
}

///|
fn script_surface_from_local_device() -> @cairoon.Surface raise @cairoon.CairoError {
  let device = @cairoon.Device::script(
    "/tmp/cairoon_script_surface_local_device.cs",
  )
  @cairoon.Surface::script(device, @cairoon.ContentColorAlpha, 2.0, 2.0)
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
