///|
fn expect_mime_bytes(
  surface : @cairoon.Surface,
  mime_type : String,
  expected : Bytes,
) -> Unit raise {
  match surface.get_mime_data(mime_type) {
    Some(bytes) => inspect(bytes == expected, content="true")
    None => @test.fail("expected MIME data for \{mime_type}")
  }
}

///|
fn binary_mime_payload() -> Bytes {
  let data : FixedArray[Byte] = FixedArray::make(6, b'\x00')
  data[1] = b'q'
  data[2] = b'u'
  data[3] = b'u'
  data[4] = b'x'
  Bytes::from_array(data)
}

///|
fn pycairo_pdf_jpeg_payload() -> Bytes {
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
fn mime_bytes_contains(haystack : Bytes, needle : Bytes) -> Bool {
  if needle.length() == 0 {
    return true
  }
  if needle.length() > haystack.length() {
    return false
  }
  let last = haystack.length() - needle.length()
  for start in 0..<=last {
    let mut matched = true
    for offset in 0..<needle.length() {
      if haystack[start + offset] != needle[offset] {
        matched = false
      }
    }
    if matched {
      return true
    }
  }
  false
}

///|
fn write_pycairo_pdf_jpeg_mime(path : String, jpeg : Bytes) -> Unit raise {
  let surface = @cairoon.Surface::pdf(3.0, 3.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-mime-parity")
  surface.pdf_set_metadata(PdfMetadataCreateDate, "2026-01-02T03:04:05+00:00")
  surface.pdf_set_metadata(PdfMetadataModDate, "2026-01-02T03:04:05+00:00")
  let ctx = @cairoon.Context::new(surface)
  let image = @cairoon.Surface::image(Rgb24, 1, 1)
  image.set_mime_data(@cairoon.MIME_TYPE_JPEG, Some(jpeg))
  ctx.set_source_surface(image)
  ctx.paint()
  surface.finish()
}

///|
test "surface mime data set get and clear" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  inspect(surface.get_mime_data("foo") is None, content="true")
  inspect(
    surface.get_mime_data(@cairoon.MIME_TYPE_JPEG) is None,
    content="true",
  )

  let payload = @utf8.encode("bar")
  surface.set_mime_data("foo", Some(payload))
  expect_mime_bytes(surface, "foo", payload)

  surface.set_mime_data("foo", None)
  inspect(surface.get_mime_data("foo") is None, content="true")
}

///|
test "pycairo mime data multi-key clear fixture" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let payload = @utf8.encode("bla")
  let head = Bytes::from_array([b'b'])

  surface.set_mime_data("foo", Some(payload))
  surface.set_mime_data("foo2", Some(payload))
  surface.set_mime_data("foo3", Some(head))
  expect_mime_bytes(surface, "foo", payload)
  expect_mime_bytes(surface, "foo2", payload)
  expect_mime_bytes(surface, "foo3", head)

  surface.set_mime_data("foo", None)
  inspect(surface.get_mime_data("foo") is None, content="true")
  expect_mime_bytes(surface, "foo2", payload)
  expect_mime_bytes(surface, "foo3", head)

  surface.set_mime_data("foo2", None)
  inspect(surface.get_mime_data("foo2") is None, content="true")
  expect_mime_bytes(surface, "foo3", head)

  surface.set_mime_data("foo3", None)
  inspect(surface.get_mime_data("foo3") is None, content="true")
  surface.finish()
}

///|
test "pycairo PDF MIME data embeds JPEG payload fixture" {
  let jpeg = pycairo_pdf_jpeg_payload()
  let path = "/tmp/cairoon_pycairo_pdf_jpeg_mime.pdf"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }
  write_pycairo_pdf_jpeg_mime(path, jpeg)
  let output = @fs.read_file_to_bytes(path)
  inspect(mime_bytes_contains(output, jpeg), content="true")
  @fs.remove_file(path)
}

///|
test "surface mime data preserves embedded nul bytes and zero length payloads" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let binary = binary_mime_payload()
  surface.set_mime_data(@cairoon.MIME_TYPE_JPEG, Some(binary))
  expect_mime_bytes(surface, @cairoon.MIME_TYPE_JPEG, binary)

  let empty : FixedArray[Byte] = FixedArray::make(0, b'\x00')
  surface.set_mime_data("application/x-empty", Some(Bytes::from_array(empty)))
  match surface.get_mime_data("application/x-empty") {
    Some(bytes) => inspect(bytes.length(), content="0")
    None => @test.fail("expected zero length MIME data")
  }
}

///|
test "surface mime data validates mime type strings" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let invalid = @cairoon.run_cairo(() => {
    surface.set_mime_data("bad\u{0}mime", Some(@utf8.encode("data")))
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for set_mime_data")
  }

  let get_invalid = @cairoon.run_cairo(() => {
    let _ = surface.get_mime_data("bad\u{0}mime")
    ()
  })
  match get_invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for get_mime_data")
  }
}

///|
test "surface reports unsupported mime type" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_JPEG), content="false")

  let invalid = @cairoon.run_cairo(() => {
    let _ = surface.supports_mime_type("bad\u{0}mime")
    ()
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for supports_mime_type")
  }
}

///|
fn inspect_mime_support(
  backend : String,
  surface : @cairoon.Surface,
  jpeg~ : Bool,
  png~ : Bool,
  jp2~ : Bool,
  uri~ : Bool,
  unique_id~ : Bool,
  ccitt~ : Bool,
  ccitt_params~ : Bool,
  eps~ : Bool,
  eps_params~ : Bool,
  jbig2~ : Bool,
  jbig2_global~ : Bool,
  jbig2_global_id~ : Bool,
) -> Unit raise {
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_JPEG),
    content="\{jpeg}",
  )
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_PNG), content="\{png}")
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_JP2), content="\{jp2}")
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_URI), content="\{uri}")
  let actual_unique_id = surface.supports_mime_type(
    @cairoon.MIME_TYPE_UNIQUE_ID,
  )
  if actual_unique_id != unique_id {
    @test.fail(
      "unexpected \{backend} unique-id MIME support: expected \{unique_id}, got \{actual_unique_id}",
    )
  }
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_CCITT_FAX),
    content="\{ccitt}",
  )
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_CCITT_FAX_PARAMS),
    content="\{ccitt_params}",
  )
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_EPS), content="\{eps}")
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_EPS_PARAMS),
    content="\{eps_params}",
  )
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_JBIG2),
    content="\{jbig2}",
  )
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_JBIG2_GLOBAL),
    content="\{jbig2_global}",
  )
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_JBIG2_GLOBAL_ID),
    content="\{jbig2_global_id}",
  )
  inspect(surface.supports_mime_type("nope"), content="false")
}

///|
test "backend surfaces report cairo mime support matrix" {
  inspect_mime_support(
    "image",
    @cairoon.Surface::image(Argb32, 1, 1),
    jpeg=false,
    png=false,
    jp2=false,
    uri=false,
    unique_id=false,
    ccitt=false,
    ccitt_params=false,
    eps=false,
    eps_params=false,
    jbig2=false,
    jbig2_global=false,
    jbig2_global_id=false,
  )

  inspect_mime_support(
    "pdf",
    @cairoon.Surface::pdf(1.0, 1.0),
    jpeg=true,
    png=false,
    jp2=true,
    uri=false,
    unique_id=true,
    ccitt=true,
    ccitt_params=true,
    eps=false,
    eps_params=false,
    jbig2=true,
    jbig2_global=true,
    jbig2_global_id=true,
  )

  inspect_mime_support(
    "ps",
    @cairoon.Surface::ps(1.0, 1.0),
    jpeg=true,
    png=false,
    jp2=false,
    uri=false,
    unique_id=@cairoon.CAIRO_VERSION >= 11600,
    ccitt=true,
    ccitt_params=true,
    eps=@cairoon.CAIRO_VERSION >= 11600,
    eps_params=@cairoon.CAIRO_VERSION >= 11600,
    jbig2=false,
    jbig2_global=false,
    jbig2_global_id=false,
  )

  inspect_mime_support(
    "svg",
    @cairoon.Surface::svg(1.0, 1.0),
    jpeg=true,
    png=true,
    jp2=false,
    uri=true,
    unique_id=true,
    ccitt=false,
    ccitt_params=false,
    eps=false,
    eps_params=false,
    jbig2=false,
    jbig2_global=false,
    jbig2_global_id=false,
  )
}
