///|
fn compile_string_constant(id : Int) -> String {
  @utf8.decode_lossy(compile_string_constant_ffi(id))
}

///|
fn expect_feature_constant(actual : Bool, id : Int) -> Unit raise {
  inspect(actual == compile_feature_flag_ffi(id), content="true")
}

///|
fn expect_string_constant(actual : String, id : Int) -> Unit raise {
  inspect(actual == compile_string_constant(id), content="true")
}

///|
test "cairo version constants mirror compile-time cairo macros" {
  inspect(CAIRO_VERSION == compile_int_constant_ffi(0), content="true")
  inspect(CAIRO_VERSION_MAJOR == compile_int_constant_ffi(1), content="true")
  inspect(CAIRO_VERSION_MINOR == compile_int_constant_ffi(2), content="true")
  inspect(CAIRO_VERSION_MICRO == compile_int_constant_ffi(3), content="true")
  inspect(CAIRO_VERSION_STRING == compile_string_constant(0), content="true")
  inspect(CAIRO_VERSION == cairo_version(), content="true")
  inspect(CAIRO_VERSION_STRING == cairo_version_string(), content="true")
  inspect(
    CAIRO_VERSION_MAJOR * 10000 +
    CAIRO_VERSION_MINOR * 100 +
    CAIRO_VERSION_MICRO,
    content="11804",
  )
}

///|
test "cairo feature constants mirror compile-time cairo macros" {
  expect_feature_constant(HAS_ATSUI_FONT, 0)
  expect_feature_constant(HAS_FT_FONT, 1)
  expect_feature_constant(HAS_GLITZ_SURFACE, 2)
  expect_feature_constant(HAS_IMAGE_SURFACE, 3)
  expect_feature_constant(HAS_MIME_SURFACE, 4)
  expect_feature_constant(HAS_PDF_SURFACE, 5)
  expect_feature_constant(HAS_PNG_FUNCTIONS, 6)
  expect_feature_constant(HAS_PS_SURFACE, 7)
  expect_feature_constant(HAS_QUARTZ_SURFACE, 8)
  expect_feature_constant(HAS_RECORDING_SURFACE, 9)
  expect_feature_constant(HAS_SCRIPT_SURFACE, 10)
  expect_feature_constant(HAS_SVG_SURFACE, 11)
  expect_feature_constant(HAS_TEE_SURFACE, 12)
  expect_feature_constant(HAS_USER_FONT, 13)
  expect_feature_constant(HAS_WIN32_FONT, 14)
  expect_feature_constant(HAS_WIN32_SURFACE, 15)
  expect_feature_constant(HAS_XCB_SURFACE, 16)
  expect_feature_constant(HAS_XLIB_SURFACE, 17)
  expect_feature_constant(HAS_DWRITE_FONT, 18)
}

///|
test "cairo string constants mirror compile-time cairo macros" {
  expect_string_constant(MIME_TYPE_JP2, 1)
  expect_string_constant(MIME_TYPE_JPEG, 2)
  expect_string_constant(MIME_TYPE_PNG, 3)
  expect_string_constant(MIME_TYPE_URI, 4)
  expect_string_constant(MIME_TYPE_UNIQUE_ID, 5)
  expect_string_constant(MIME_TYPE_CCITT_FAX, 6)
  expect_string_constant(MIME_TYPE_CCITT_FAX_PARAMS, 7)
  expect_string_constant(MIME_TYPE_EPS, 8)
  expect_string_constant(MIME_TYPE_EPS_PARAMS, 9)
  expect_string_constant(MIME_TYPE_JBIG2, 10)
  expect_string_constant(MIME_TYPE_JBIG2_GLOBAL, 11)
  expect_string_constant(MIME_TYPE_JBIG2_GLOBAL_ID, 12)
  expect_string_constant(TAG_DEST, 13)
  expect_string_constant(TAG_LINK, 14)
  expect_string_constant(TAG_CONTENT, 15)
  expect_string_constant(TAG_CONTENT_REF, 16)
}

///|
test "cairo integer constants mirror compile-time cairo macros" {
  inspect(PDF_OUTLINE_ROOT == compile_int_constant_ffi(4), content="true")
  inspect(
    COLOR_PALETTE_DEFAULT.reinterpret_as_int() == compile_int_constant_ffi(5),
    content="true",
  )
  inspect(FORMAT_INVALID == compile_int_constant_ffi(6), content="true")
}
