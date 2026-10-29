///|
test "internal version package delegates to cairo" {
  inspect(@version.cairo_version() > 0, content="true")
  inspect(@version.cairo_version_string().contains("."), content="true")
}
