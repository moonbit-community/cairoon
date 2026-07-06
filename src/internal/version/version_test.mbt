///|
test "internal version package delegates to cairo" {
  inspect(cairo_version() > 0, content="true")
  inspect(cairo_version_string().contains("."), content="true")
}
