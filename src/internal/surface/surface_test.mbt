///|
test "raw image surface preserves identity, state, and image properties" {
  let surface = image_create_raw(0, 3, 2)
  inspect(status_raw(surface), content="0")
  inspect(equal_raw(surface, surface), content="true")
  inspect(hash_raw(surface) != 0, content="true")
  inspect(get_content_raw(surface), content="12288")
  inspect(get_type_raw(surface), content="0")

  let status = Ref(-1)
  inspect(image_get_width_raw(surface, status), content="3")
  inspect(status.val, content="0")
  inspect(image_get_height_raw(surface, status), content="2")
  inspect(status.val, content="0")
  inspect(image_get_stride_raw(surface, status), content="12")
  inspect(status.val, content="0")
  inspect(image_get_format_raw(surface, status), content="0")
  inspect(status.val, content="0")

  inspect(set_device_offset_raw(surface, 1.5, -2.0), content="0")
  let x = Ref(0.0)
  let y = Ref(0.0)
  inspect(get_device_offset_raw(surface, x, y), content="0")
  inspect(x.val, content="1.5")
  inspect(y.val, content="-2")
  inspect(set_device_scale_raw(surface, 2.0, 3.0), content="0")
  inspect(get_device_scale_raw(surface, x, y), content="0")
  inspect(x.val, content="2")
  inspect(y.val, content="3")
  inspect(set_fallback_resolution_raw(surface, 96.0, 144.0), content="0")
  inspect(get_fallback_resolution_raw(surface, x, y), content="0")
  inspect(x.val, content="96")
  inspect(y.val, content="144")
}

///|
test "raw surface retains image data and mapped-image owners" {
  let status = Ref(-1)
  let surface = image_create_raw(0, 2, 1)
  let data = image_get_data_raw(surface, status)
  inspect(status.val, content="0")
  inspect(data_status_raw(data), content="0")
  inspect(data_length_raw(data), content="8")
  inspect(data_set_raw(data, 0, b'\x2a'), content="0")
  inspect(data_get_raw(data, 0, status).to_int(), content="42")
  inspect(status.val, content="0")
  inspect(data_copy_raw(data, status).length(), content="8")
  inspect(status.val, content="0")

  let mapped_base = image_create_raw(1, 2, 1)
  let mapped = map_to_image_raw(mapped_base, false, 0, 0, 0, 0, status)
  inspect(status.val, content="0")
  inspect(mapped_status_raw(mapped), content="0")
  inspect(mapped_get_width_raw(mapped), content="2")
  inspect(mapped_get_height_raw(mapped), content="1")
  inspect(mapped_get_stride_raw(mapped), content="8")
  inspect(mapped_get_format_raw(mapped), content="1")
  inspect(mapped_copy_data_raw(mapped).length(), content="8")
  inspect(mapped_unmap_raw(mapped), content="0")
}

///|
test "raw similar, recording, tee, MIME, and font-options paths compose" {
  let status = Ref(-1)
  let primary = image_create_raw(0, 4, 4)
  let similar = create_similar_raw(primary, 0x3000, 2, 2, status)
  inspect(status.val, content="0")
  inspect(status_raw(similar), content="0")
  let child = create_for_rectangle_raw(primary, 1.0, 1.0, 2.0, 2.0, status)
  inspect(status.val, content="0")
  inspect(status_raw(child), content="0")

  let mime_type = Bytes::from_array([
    b'i', b'm', b'a', b'g', b'e', b'/', b'j', b'p', b'e', b'g',
  ])
  let payload = Bytes::from_array([b'c', b'a', b'i', b'r', b'o'])
  inspect(set_mime_data_raw(primary, mime_type, payload), content="0")
  let has_data = Ref(0)
  inspect(
    get_mime_data_raw(primary, mime_type, has_data, status) == payload,
    content="true",
  )
  inspect(has_data.val, content="1")
  inspect(status.val, content="0")
  inspect(clear_mime_data_raw(primary, mime_type), content="0")

  let options = get_font_options_raw(primary, status)
  inspect(status.val, content="0")
  inspect(@font_options_impl.status_raw(options), content="0")

  let recording = recording_create_raw(
    0x3000, false, 0.0, 0.0, 0.0, 0.0, status,
  )
  inspect(status.val, content="0")
  let has_extents = Ref(-1)
  let x = Ref(0.0)
  let y = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  inspect(
    recording_get_extents_raw(recording, has_extents, x, y, width, height),
    content="0",
  )
  inspect(has_extents.val, content="0")

  let tee = tee_create_raw(primary, status)
  inspect(status.val, content="0")
  inspect(tee_add_raw(tee, similar), content="0")
  let indexed = tee_index_raw(tee, 0, status)
  inspect(status.val, content="0")
  inspect(equal_raw(indexed, primary), content="true")
  inspect(tee_remove_raw(tee, similar), content="0")
}

///|
test "raw PDF, PS, and SVG no-output surfaces expose backend state" {
  let status = Ref(-1)
  let empty = Bytes::from_array([])
  let pdf = pdf_create_raw(false, empty, 20.0, 30.0, status)
  inspect(status.val, content="0")
  inspect(status_raw(pdf), content="0")
  inspect(pdf_restrict_to_version_raw(pdf, 0), content="0")
  inspect(pdf_set_size_raw(pdf, 30.0, 40.0), content="0")
  inspect(pdf_set_thumbnail_size_raw(pdf, 4, 5), content="0")

  let ps = ps_create_raw(false, empty, 20.0, 30.0, status)
  inspect(status.val, content="0")
  inspect(status_raw(ps), content="0")
  inspect(ps_restrict_to_level_raw(ps, 0), content="0")
  inspect(ps_set_eps_raw(ps, true), content="0")
  inspect(ps_get_eps_raw(ps, status), content="true")
  inspect(status.val, content="0")

  let svg = svg_create_raw(false, empty, 20.0, 30.0, status)
  inspect(status.val, content="0")
  inspect(status_raw(svg), content="0")
  inspect(svg_restrict_to_version_raw(svg, 0), content="0")
  inspect(svg_set_document_unit_raw(svg, 1), content="0")
  inspect(svg_get_document_unit_raw(svg, status), content="1")
  inspect(status.val, content="0")
}

///|
fn raw_stream_chunks_to_bytes(chunks : Array[Bytes]) -> Bytes {
  let mut bytes = Bytes::default()
  for chunk in chunks {
    bytes = bytes + chunk
  }
  bytes
}

///|
fn raw_stream_bytes_slice(bytes : Bytes, offset : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(index) { bytes[offset + index] })
}

///|
test "raw vector and PNG stream callbacks stay inside Surface package" {
  let status = Ref(-1)

  let pdf_chunks : Array[Bytes] = []
  let pdf = pdf_create_stream_raw(
    fn(chunk) {
      pdf_chunks.push(chunk)
      0
    },
    20.0,
    30.0,
    status,
  )
  inspect(status.val, content="0")
  inspect(finish_raw(pdf), content="0")
  inspect(pdf_chunks.length() > 0, content="true")

  let ps_chunks : Array[Bytes] = []
  let ps = ps_create_stream_raw(
    fn(chunk) {
      ps_chunks.push(chunk)
      0
    },
    20.0,
    30.0,
    status,
  )
  inspect(status.val, content="0")
  inspect(finish_raw(ps), content="0")
  inspect(ps_chunks.length() > 0, content="true")

  let svg_chunks : Array[Bytes] = []
  let svg = svg_create_stream_raw(
    fn(chunk) {
      svg_chunks.push(chunk)
      0
    },
    20.0,
    30.0,
    status,
  )
  inspect(status.val, content="0")
  inspect(finish_raw(svg), content="0")
  inspect(svg_chunks.length() > 0, content="true")

  let png_chunks : Array[Bytes] = []
  let image = image_create_raw(0, 2, 2)
  inspect(
    write_to_png_stream_raw(image, fn(chunk) {
      png_chunks.push(chunk)
      0
    }),
    content="0",
  )
  let png = raw_stream_chunks_to_bytes(png_chunks)
  let offset = Ref(0)
  let decoded = image_create_from_png_stream_raw(
    fn(length) {
      let chunk = raw_stream_bytes_slice(png, offset.val, length)
      offset.val += length
      chunk
    },
    status,
  )
  inspect(status.val, content="0")
  inspect(image_get_width_raw(decoded, status), content="2")
  inspect(status.val, content="0")
  inspect(image_get_height_raw(decoded, status), content="2")
  inspect(status.val, content="0")
  inspect(offset.val == png.length(), content="true")
}
