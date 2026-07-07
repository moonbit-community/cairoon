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
test "surface mime data set get and clear" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
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
test "surface mime data preserves embedded nul bytes and zero length payloads" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
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
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let invalid = @cairoon.run_cairo(() => {
    surface.set_mime_data("bad\u{0}mime", Some(@utf8.encode("data")))
  })
  match invalid {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for set_mime_data")
  }

  let get_invalid = @cairoon.run_cairo(() => {
    let _ = surface.get_mime_data("bad\u{0}mime")
    ()
  })
  match get_invalid {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for get_mime_data")
  }
}

///|
test "surface reports unsupported mime type" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  inspect(surface.supports_mime_type(@cairoon.MIME_TYPE_JPEG), content="false")

  let invalid = @cairoon.run_cairo(() => {
    let _ = surface.supports_mime_type("bad\u{0}mime")
    ()
  })
  match invalid {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for supports_mime_type")
  }
}

///|
fn inspect_mime_support(
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
  inspect(
    surface.supports_mime_type(@cairoon.MIME_TYPE_UNIQUE_ID),
    content="\{unique_id}",
  )
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
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
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
    @cairoon.Surface::ps(1.0, 1.0),
    jpeg=true,
    png=false,
    jp2=false,
    uri=false,
    unique_id=true,
    ccitt=true,
    ccitt_params=true,
    eps=true,
    eps_params=true,
    jbig2=false,
    jbig2_global=false,
    jbig2_global_id=false,
  )

  inspect_mime_support(
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
