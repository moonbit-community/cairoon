///|
test "new regions report success status" {
  let region = @cairoon.Region::new()
  debug_inspect(region.status(), content="Success")
}
