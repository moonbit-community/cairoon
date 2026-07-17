///|
test "raw recording constructor supports unbounded surfaces" {
  let recording = @cairoon.Surface::recording_raw(0x3000)
  debug_inspect(recording.get_content(), content="ContentColorAlpha")
  inspect(recording.recording_get_extents() is None, content="true")
}
