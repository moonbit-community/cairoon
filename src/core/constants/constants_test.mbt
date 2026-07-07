///|
test "cairo version constants compose encoded version" {
  inspect(
    CAIRO_VERSION_MAJOR * 10000 +
    CAIRO_VERSION_MINOR * 100 +
    CAIRO_VERSION_MICRO,
    content="11804",
  )
  inspect(CAIRO_VERSION, content="11804")
  inspect(CAIRO_VERSION_STRING, content="1.18.4")
}

///|
test "mime tag and numeric constants expose cairo spellings" {
  inspect(MIME_TYPE_JPEG, content="image/jpeg")
  inspect(MIME_TYPE_PNG, content="image/png")
  inspect(TAG_DEST, content="cairo.dest")
  inspect(TAG_LINK, content="Link")
  inspect(PDF_OUTLINE_ROOT, content="0")
  inspect(COLOR_PALETTE_DEFAULT, content="0")
}
