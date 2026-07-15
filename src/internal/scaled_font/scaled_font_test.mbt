///|
fn make_raw_scaled_font() -> RawScaledFont raise {
  let face = @font_face_impl.toy_create_raw(b"serif", 0, 0)
  inspect(@font_face_impl.status_raw(face), content="0")
  let options = @font_options_impl.create_raw()
  inspect(@font_options_impl.status_raw(options), content="0")
  let scaled_font = create_raw(
    face, 12.0, 0.0, 0.0, 12.0, 0.0, 0.0, 2.0, 0.0, 0.0, 3.0, 5.0, 7.0, options,
  )
  inspect(status_raw(scaled_font), content="0")
  scaled_font
}

///|
test "raw scaled font preserves identity, owners, and matrices" {
  let scaled_font = make_raw_scaled_font()
  inspect(equal_raw(scaled_font, scaled_font), content="true")
  inspect(hash_raw(scaled_font) != 0, content="true")

  let status = Ref(-1)
  let face = get_font_face_raw(scaled_font, status)
  inspect(status.val, content="0")
  inspect(@font_face_impl.status_raw(face), content="0")
  let options = get_font_options_raw(scaled_font, status)
  inspect(status.val, content="0")
  inspect(@font_options_impl.status_raw(options), content="0")

  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  inspect(get_font_matrix_raw(scaled_font, xx, yx, xy, yy, x0, y0), content="0")
  inspect(xx.val, content="12")
  inspect(yy.val, content="12")
  inspect(get_ctm_raw(scaled_font, xx, yx, xy, yy, x0, y0), content="0")
  inspect(xx.val, content="2")
  inspect(yy.val, content="3")
  inspect(x0.val, content="0")
  inspect(y0.val, content="0")
  inspect(
    get_scale_matrix_raw(scaled_font, xx, yx, xy, yy, x0, y0),
    content="0",
  )
  inspect(xx.val, content="24")
  inspect(yy.val, content="36")
}

///|
test "raw scaled font copies text-to-glyph arrays" {
  let scaled_font = make_raw_scaled_font()
  let x_bearing = Ref(0.0)
  let y_bearing = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  let x_advance = Ref(0.0)
  let y_advance = Ref(0.0)
  inspect(
    text_extents_raw(
      scaled_font, b"Hi", x_bearing, y_bearing, width, height, x_advance, y_advance,
    ),
    content="0",
  )
  inspect(x_advance.val > 0.0, content="true")

  let result = text_to_glyphs_raw(scaled_font, 1.0, 2.0, b"Hi")
  inspect(text_to_glyphs_status_raw(result), content="0")
  let indices = text_to_glyphs_indices_raw(result)
  let positions = text_to_glyphs_positions_raw(result)
  let clusters = text_to_glyphs_clusters_raw(result)
  inspect(indices.length() > 0, content="true")
  inspect(positions.length() == indices.length() * 2, content="true")
  inspect(clusters.length() % 2, content="0")
  inspect(text_to_glyphs_flags_raw(result), content="0")
}
