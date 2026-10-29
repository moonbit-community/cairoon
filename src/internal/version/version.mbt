///|
pub fn cairo_version() -> Int32 {
  ignore(@native.native_anchor())
  cairo_version_ffi()
}

///|
pub fn cairo_version_string() -> String {
  ignore(@native.native_anchor())
  @utf8.decode_lossy(cairo_version_string_ffi())
}
