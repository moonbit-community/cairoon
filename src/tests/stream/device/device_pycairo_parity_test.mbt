///|
fn expect_pycairo_device_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(@cairoon.CairoError(@cairoon.DeviceFinished, _)) => ()
    _ => @test.fail("expected DeviceFinished")
  }
}

///|
fn pycairo_device_chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
test "pycairo device context manager fixture" {
  let device = @cairoon.Device::script_stream(_chunk => @cairoon.Success)
  device.with_finished(() => {
    device.acquire()
    device.release()
  })
  expect_pycairo_device_finished(@cairoon.run_cairo(() => device.acquire()))
}

///|
test "pycairo device cmp hash fixture" {
  let device = @cairoon.Device::script_stream(_chunk => @cairoon.Success)
  let surface = @cairoon.Surface::script(
    device,
    @cairoon.ContentColorAlpha,
    42.0,
    10.0,
  )
  match surface.get_device() {
    Some(other) => {
      inspect(device == other, content="true")
      inspect(device != other, content="false")
      inspect(Hash::hash(device) == Hash::hash(other), content="true")
      let unrelated = @cairoon.Device::script_stream(_chunk => @cairoon.Success)
      inspect(device != unrelated, content="true")
    }
    None => @test.fail("expected script surface device")
  }
}

///|
test "pycairo image surface get_device fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  inspect(surface.get_device() is None, content="true")
}

///|
test "pycairo script feature and device type fixture" {
  inspect(@cairoon.HAS_SCRIPT_SURFACE, content="true")
  let device = @cairoon.Device::script_stream(_chunk => @cairoon.Success)
  debug_inspect(device.get_type(), content="DeviceTypeScript")
}

///|
test "pycairo script device path and acquire fixture" {
  let path = "/tmp/cairoon_pycairo_script_device_to_path.cs"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }
  let device = @cairoon.Device::script(path)
  debug_inspect(device.get_type(), content="DeviceTypeScript")
  device.acquire()
  device.release()
  device.script_write_comment("pycairo path fixture")
  device.finish()
  let script = @fs.read_file_to_string(path)
  inspect(script.contains("pycairo path fixture"), content="true")
  @fs.remove_file(path)
  expect_pycairo_device_finished(@cairoon.run_cairo(() => device.acquire()))
}

///|
test "pycairo script device mode and comment fixture" {
  let chunks : Array[Bytes] = []
  let device = @cairoon.Device::script_stream(chunk => {
    chunks.push(chunk)
    @cairoon.Success
  })
  debug_inspect(device.script_get_mode(), content="ScriptModeAscii")
  device.script_set_mode(@cairoon.ScriptModeBinary)
  debug_inspect(device.script_get_mode(), content="ScriptModeBinary")
  device.script_write_comment("pycairo foo")
  device.script_write_comment("pycairo bar")
  device.flush()
  let script = pycairo_device_chunks_to_string(chunks)
  inspect(script.contains("pycairo foo"), content="true")
  inspect(script.contains("pycairo bar"), content="true")
}

///|
test "pycairo script device recording replay fixture" {
  let recording = @cairoon.Surface::recording(@cairoon.ContentColor)
  let ctx = @cairoon.Context::new(recording)
  ctx.paint()

  let chunks : Array[Bytes] = []
  let device = @cairoon.Device::script_stream(chunk => {
    chunks.push(chunk)
    @cairoon.Success
  })
  device.script_from_recording_surface(recording)
  device.flush()
  inspect(
    pycairo_device_chunks_to_string(chunks).contains("paint"),
    content="true",
  )

  device.finish()
  expect_pycairo_device_finished(
    @cairoon.run_cairo(() => device.script_from_recording_surface(recording)),
  )
}

///|
test "pycairo script surface create_for_target parity fixture" {
  let chunks : Array[Bytes] = []
  let device = @cairoon.Device::script_stream(chunk => {
    chunks.push(chunk)
    @cairoon.Success
  })
  let target = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let script = @cairoon.Surface::script_for_target(device, target)
  let script_ctx = @cairoon.Context::new(script)
  script_ctx.set_source_rgb(0.25, 0.5, 1.0)
  script_ctx.paint()
  script.flush()
  target.flush()
  device.flush()

  let direct = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let direct_ctx = @cairoon.Context::new(direct)
  direct_ctx.set_source_rgb(0.25, 0.5, 1.0)
  direct_ctx.paint()
  direct.flush()

  inspect(
    pycairo_device_chunks_to_string(chunks).contains("paint"),
    content="true",
  )
  inspect(target.copy_data() == direct.copy_data(), content="true")
}
