///|
fn make_raw_script_device(chunks : Array[Bytes]) -> RawDevice raise {
  let status = Ref(-1)
  let device = script_create_stream_raw(
    fn(chunk) {
      chunks.push(chunk)
      0
    },
    status,
  )
  inspect(status.val, content="0")
  inspect(status_raw(device), content="0")
  device
}

///|
test "raw script device preserves identity and mode state" {
  let chunks : Array[Bytes] = []
  let device = make_raw_script_device(chunks)
  inspect(equal_raw(device, device), content="true")
  inspect(hash_raw(device) != 0, content="true")

  let status = Ref(-1)
  inspect(get_type_raw(device, status), content="2")
  inspect(status.val, content="0")
  inspect(script_get_mode_raw(device, status), content="0")
  inspect(status.val, content="0")
  inspect(script_set_mode_raw(device, 1), content="0")
  inspect(script_get_mode_raw(device, status), content="1")
  inspect(status.val, content="0")
  inspect(script_set_mode_raw(device, 0), content="0")
  inspect(script_write_comment_raw(device, b"raw device test"), content="0")
  inspect(flush_raw(device), content="0")
  inspect(chunks.length() > 0, content="true")
}

///|
test "raw script device reports acquire after finish" {
  let chunks : Array[Bytes] = []
  let device = make_raw_script_device(chunks)
  inspect(acquire_raw(device), content="0")
  inspect(release_raw(device), content="0")
  inspect(finish_raw(device), content="0")
  inspect(status_raw(device), content="0")
  inspect(acquire_raw(device), content="37")
}

///|
test "raw script device exchanges cross-package surface handles" {
  let chunks : Array[Bytes] = []
  let device = make_raw_script_device(chunks)
  let status = Ref(-1)

  let surface = script_surface_create_raw(device, 0x3000, 2.0, 3.0, status)
  inspect(status.val, content="0")
  inspect(@surface_impl.status_raw(surface), content="0")
  inspect(@surface_impl.get_type_raw(surface), content="14")
  let has_device = Ref(0)
  let returned_device = surface_get_device_raw(surface, has_device, status)
  inspect(status.val, content="0")
  inspect(has_device.val, content="1")
  inspect(equal_raw(returned_device, device), content="true")

  let target = @surface_impl.image_create_raw(0, 2, 2)
  let target_surface = script_surface_create_for_target_raw(
    device, target, status,
  )
  inspect(status.val, content="0")
  inspect(@surface_impl.status_raw(target_surface), content="0")
  inspect(@surface_impl.get_type_raw(target_surface), content="14")

  let recording = @surface_impl.recording_create_raw(
    0x3000, false, 0.0, 0.0, 0.0, 0.0, status,
  )
  inspect(status.val, content="0")
  inspect(script_from_recording_surface_raw(device, recording), content="0")
}
