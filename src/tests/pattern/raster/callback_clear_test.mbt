///|
test "raster callback setter with no callbacks clears registration" {
  let pattern = @cairoon.Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_callbacks()
  let (acquire, release) = pattern.raster_get_callbacks()
  inspect(acquire is None, content="true")
  inspect(release is None, content="true")
}
