///|
test "cairo version constants compose encoded version" {
  inspect(
    CAIRO_VERSION_MAJOR * 10000 +
    CAIRO_VERSION_MINOR * 100 +
    CAIRO_VERSION_MICRO ==
    CAIRO_VERSION,
    content="true",
  )
  inspect(
    CAIRO_VERSION_STRING ==
    "\{CAIRO_VERSION_MAJOR}.\{CAIRO_VERSION_MINOR}.\{CAIRO_VERSION_MICRO}",
    content="true",
  )
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
