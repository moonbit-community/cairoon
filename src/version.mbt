///|
pub fn cairo_version() -> Int {
  cairo_version_ffi()
}

///|
pub fn cairo_version_string() -> String {
  @utf8.decode_lossy(cairo_version_string_ffi())
}
