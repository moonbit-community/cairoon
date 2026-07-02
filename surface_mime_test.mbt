///|
fn expect_mime_bytes(
  surface : Surface,
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
test "surface mime data set get and clear" {
  let surface = Surface::image(Argb32, 1, 1)
  inspect(surface.get_mime_data("foo") is None, content="true")
  inspect(surface.get_mime_data("image/jpeg") is None, content="true")

  let payload = @utf8.encode("bar")
  surface.set_mime_data("foo", Some(payload))
  expect_mime_bytes(surface, "foo", payload)

  surface.set_mime_data("foo", None)
  inspect(surface.get_mime_data("foo") is None, content="true")
}

///|
test "surface mime data preserves embedded nul bytes and zero length payloads" {
  let surface = Surface::image(Argb32, 1, 1)
  let binary = binary_mime_payload()
  surface.set_mime_data("image/jpeg", Some(binary))
  expect_mime_bytes(surface, "image/jpeg", binary)

  let empty : FixedArray[Byte] = FixedArray::make(0, b'\x00')
  surface.set_mime_data("application/x-empty", Some(Bytes::from_array(empty)))
  match surface.get_mime_data("application/x-empty") {
    Some(bytes) => inspect(bytes.length(), content="0")
    None => @test.fail("expected zero length MIME data")
  }
}

///|
test "surface mime data validates mime type strings" {
  let surface = Surface::image(Argb32, 1, 1)
  let invalid = run_cairo(() => {
    surface.set_mime_data("bad\u{0}mime", Some(@utf8.encode("data")))
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for set_mime_data")
  }

  let get_invalid = run_cairo(() => {
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
  let surface = Surface::image(Argb32, 1, 1)
  inspect(
    surface.supports_mime_type("application/x-cairoon-test"),
    content="false",
  )
}
