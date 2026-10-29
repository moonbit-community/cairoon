///|
test "cairo version constants compose encoded version" {
  inspect(
    @constants.CAIRO_VERSION_MAJOR * 10000 +
    @constants.CAIRO_VERSION_MINOR * 100 +
    @constants.CAIRO_VERSION_MICRO ==
    @constants.CAIRO_VERSION,
    content="true",
  )
  inspect(
    @constants.CAIRO_VERSION_STRING ==
    "\{@constants.CAIRO_VERSION_MAJOR}.\{@constants.CAIRO_VERSION_MINOR}.\{@constants.CAIRO_VERSION_MICRO}",
    content="true",
  )
}

///|
test "mime tag and numeric constants expose cairo spellings" {
  inspect(@constants.MIME_TYPE_JPEG, content="image/jpeg")
  inspect(@constants.MIME_TYPE_PNG, content="image/png")
  inspect(@constants.TAG_DEST, content="cairo.dest")
  inspect(@constants.TAG_LINK, content="Link")
  inspect(@constants.PDF_OUTLINE_ROOT, content="0")
  inspect(@constants.COLOR_PALETTE_DEFAULT, content="0")
}
