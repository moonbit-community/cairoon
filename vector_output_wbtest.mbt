///|
fn expect_vector_output(path : String, markers : Array[String]) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="true",
    )
  }
}

///|
fn expect_vector_output_bytes(path : String, marker : Bytes) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  inspect(test_file_contains_ffi(filename, marker), content="true")
}

///|
fn expect_vector_output_absent(
  path : String,
  markers : Array[String],
) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="false",
    )
  }
}

///|
fn fixed_pdf_metadata_date() -> String {
  "2026-01-02T03:04:05+00:00"
}

///|
fn tiny_jpeg_payload() -> Bytes {
  let data : FixedArray[Byte] = [
    b'\xFF', b'\xD8', b'\xFF', b'\xE0', b'\x00', b'\x10', b'\x4A', b'\x46', b'\x49',
    b'\x46', b'\x00', b'\x01', b'\x01', b'\x01', b'\x00', b'\x48', b'\x00', b'\x48',
    b'\x00', b'\x00', b'\xFF', b'\xDB', b'\x00', b'\x43', b'\x00', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\xFF',
    b'\xC2', b'\x00', b'\x0B', b'\x08', b'\x00', b'\x01', b'\x00', b'\x01', b'\x01',
    b'\x01', b'\x11', b'\x00', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x00', b'\x01',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x09', b'\xFF', b'\xDA',
    b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x00', b'\x00', b'\x01', b'\x7F',
    b'\x3F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10', b'\x01', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xDA', b'\x00', b'\x08',
    b'\x01', b'\x01', b'\x00', b'\x01', b'\x05', b'\x02', b'\x7F', b'\xFF', b'\xC4',
    b'\x00', b'\x14', b'\x10', b'\x01', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\xFF', b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00',
    b'\x06', b'\x3F', b'\x02', b'\x7F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10',
    b'\x01', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF',
    b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x01', b'\x3F', b'\x21',
    b'\x7F', b'\xFF', b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x00',
    b'\x00', b'\x10', b'\x7F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10', b'\x01',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xDA',
    b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x01', b'\x3F', b'\x10', b'\x7F',
    b'\xFF', b'\xD9',
  ]
  Bytes::from_array(data)
}

///|
fn vector_output_extension(kind : Int) -> String {
  match kind {
    0 => "pdf"
    1 => "ps"
    2 => "svg"
    _ => "out"
  }
}

///|
fn expect_vector_outputs_equal(
  kind : Int,
  left_path : String,
  right_path : String,
) -> Unit raise {
  inspect(
    test_vector_files_equal_ffi(
      kind,
      checked_path_bytes(left_path),
      checked_path_bytes(right_path),
    ),
    content="true",
  )
}

///|
fn expect_vector_oracle_match(
  kind : Int,
  scene : Int,
  cairoon_path : String,
  oracle_path : String,
) -> Unit raise {
  check_status(
    test_render_vector_scene_oracle_ffi(
      kind,
      scene,
      checked_path_bytes(oracle_path),
    ),
  )
  inspect(
    test_vector_files_equal_ffi(
      kind,
      checked_path_bytes(cairoon_path),
      checked_path_bytes(oracle_path),
    ),
    content="true",
  )
}

///|
fn vector_oracle_surface(kind : Int, path : String) -> Surface raise CairoError {
  match kind {
    0 => {
      let surface = Surface::pdf(10.0, 10.0, path=Some(path))
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface
    }
    1 => Surface::ps(10.0, 10.0, path=Some(path))
    2 => Surface::svg(10.0, 10.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn draw_vector_oracle_scene(
  ctx : Context,
  scene : Int,
) -> Unit raise CairoError {
  match scene {
    0 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
    }
    1 => {
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(1.5)
      ctx.move_to(1.5, 1.5)
      ctx.line_to(8.5, 8.5)
      ctx.stroke()
    }
    2 => {
      ctx.rectangle(2.0, 2.0, 6.0, 6.0)
      ctx.set_source_rgba(0.0, 1.0, 0.0, 0.75)
      ctx.fill_preserve()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(1.0)
      ctx.stroke()
    }
    3 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(1.25)
      ctx.move_to(1.0, 9.0)
      ctx.curve_to(3.0, 1.0, 7.0, 9.0, 9.0, 1.0)
      ctx.stroke()
    }
    4 => {
      ctx.translate(5.0, 5.0)
      ctx.rotate(0.25)
      ctx.scale(1.2, 0.8)
      ctx.rectangle(-3.0, -2.0, 6.0, 4.0)
      ctx.set_source_rgb(1.0, 0.5, 0.0)
      ctx.fill()
    }
    5 => {
      let pattern = Pattern::linear(0.0, 0.0, 10.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      ctx.rectangle(0.0, 0.0, 10.0, 10.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    6 => {
      let pattern = Pattern::radial(5.0, 5.0, 1.0, 5.0, 5.0, 5.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0)
      ctx.rectangle(0.0, 0.0, 10.0, 10.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    7 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(4.0)
      ctx.move_to(1.0, 6.5)
      ctx.text_path("Hi")
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.fill()
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_vector_oracle_scene(
  kind : Int,
  scene : Int,
  path : String,
) -> Unit raise CairoError {
  let surface = vector_oracle_surface(kind, path)
  let ctx = Context::new(surface)
  draw_vector_oracle_scene(ctx, scene)
  surface.finish()
}

///|
fn fill_link_rect(ctx : Context, tagged : Bool) -> Unit raise CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  if tagged {
    ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  }
  ctx.rectangle(1.0, 1.0, 8.0, 8.0)
  ctx.fill()
  if tagged {
    ctx.tag_end(TAG_LINK)
  }
}

///|
test "pdf output contains stable structural markers" {
  let path = "/tmp/cairoon_vector_output.pdf"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, ["%PDF-1.4", "/Root", "/Info", "%%EOF"])
  expect_vector_oracle_match(0, 0, path, oracle_path)
}

///|
test "pdf output contains metadata and custom metadata markers" {
  let path = "/tmp/cairoon_vector_pdf_metadata.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Title")
  surface.pdf_set_metadata(PdfMetadataAuthor, "Cairoon Author")
  surface.pdf_set_metadata(PdfMetadataSubject, "Cairoon Subject")
  surface.pdf_set_metadata(PdfMetadataKeywords, "moonbit cairo ffi")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon metadata test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Title (Cairoon Title)", "/Author (Cairoon Author)", "/Subject (Cairoon Subject)",
    "/Keywords (moonbit cairo ffi)", "/Creator (cairoon metadata test)", "/CreationDate (20260102030405+00'00')",
    "/ModDate (20260102030405+00'00')", "/ISBN (978-0123456789)", "%%EOF",
  ])
}

///|
test "pdf link tag output contains annotation markers" {
  let path = "/tmp/cairoon_vector_tag_output.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("example link")
  ctx.tag_end(TAG_LINK)
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf output embeds jpeg mime data from image source" {
  let path = "/tmp/cairoon_vector_pdf_jpeg_mime.pdf"
  let jpeg = tiny_jpeg_payload()
  let surface = Surface::pdf(3.0, 3.0, path=Some(path))
  inspect(surface.supports_mime_type(MIME_TYPE_JPEG), content="true")
  let ctx = Context::new(surface)
  let image = Surface::image(Rgb24, 1, 1)
  image.set_mime_data(MIME_TYPE_JPEG, Some(jpeg))
  ctx.set_source_surface(image)
  ctx.paint()
  surface.finish()
  expect_vector_output_bytes(path, jpeg)
}

///|
test "ps output contains stable page and drawing markers" {
  let path = "/tmp/cairoon_vector_output.ps"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.ps"
  let surface = Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 1", "0 0 1 rg", "0 0 10 10 rectfill", "%%EOF",
  ])
  expect_vector_oracle_match(1, 0, path, oracle_path)
}

///|
test "ps link tags are inert for postscript output" {
  let plain_path = "/tmp/cairoon_vector_ps_plain_tag_scene.ps"
  let tagged_path = "/tmp/cairoon_vector_ps_tag_scene.ps"
  let plain = Surface::ps(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::ps(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(1, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "/Subtype /Link", "/URI",
  ])
}

///|
test "svg output contains stable geometry and color markers" {
  let path = "/tmp/cairoon_vector_output.svg"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.svg"
  let surface = Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"10\" height=\"10\"", "fill=\"rgb(0%, 0%, 100%)\"",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 0, path, oracle_path)
}

///|
test "vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 0..<8 {
      let cairoon_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "svg link tags are inert for svg output" {
  let plain_path = "/tmp/cairoon_vector_svg_plain_tag_scene.svg"
  let tagged_path = "/tmp/cairoon_vector_svg_tag_scene.svg"
  let plain = Surface::svg(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::svg(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(2, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "xlink:href=", "<a ",
  ])
}
