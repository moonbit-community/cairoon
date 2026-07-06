///|
test "cairo version is available" {
  inspect(cairo_version() > 0, content="true")
  inspect(cairo_version_string().contains("."), content="true")
  inspect(CAIRO_VERSION == cairo_version(), content="true")
  inspect(CAIRO_VERSION_STRING == cairo_version_string(), content="true")
}
