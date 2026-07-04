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
