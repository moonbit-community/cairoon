///|
test "cairo version is available" {
  inspect(@cairoon.cairo_version() > 0, content="true")
  inspect(@cairoon.cairo_version_string().contains("."), content="true")
  inspect(@cairoon.CAIRO_VERSION == @cairoon.cairo_version(), content="true")
  inspect(
    @cairoon.CAIRO_VERSION_STRING == @cairoon.cairo_version_string(),
    content="true",
  )
}
