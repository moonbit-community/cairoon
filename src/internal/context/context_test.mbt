///|
test "raw context owns and returns cross-package surface handles" {
  let surface = @surface_impl.image_create_raw(0, 3, 2)
  let ctx = create_raw(surface)
  inspect(status_raw(ctx), content="0")
  inspect(equal_raw(ctx, ctx), content="true")
  inspect(hash_raw(ctx) != 0, content="true")

  let status = Ref(-1)
  let target = get_target_raw(ctx, status)
  inspect(status.val, content="0")
  inspect(@surface_impl.equal_raw(target, surface), content="true")
  let group_target = get_group_target_raw(ctx, status)
  inspect(status.val, content="0")
  inspect(@surface_impl.equal_raw(group_target, surface), content="true")

  let source = @surface_impl.image_create_raw(0, 1, 1)
  inspect(set_source_surface_raw(ctx, source, 0.0, 0.0), content="0")
  inspect(paint_raw(ctx), content="0")
  inspect(mask_surface_raw(ctx, source, 0.0, 0.0), content="0")
}

///|
test "raw context accepts a mapped-image surface handle" {
  let status = Ref(-1)
  let surface = @surface_impl.image_create_raw(0, 2, 2)
  let mapped = @surface_impl.map_to_image_raw(
    surface, false, 0, 0, 0, 0, status,
  )
  inspect(status.val, content="0")
  let ctx = create_for_mapped_image_raw(mapped, status)
  inspect(status.val, content="0")
  inspect(status_raw(ctx), content="0")
  inspect(set_source_rgb_raw(ctx, 1.0, 0.0, 0.0), content="0")
  inspect(paint_raw(ctx), content="0")
  inspect(@surface_impl.mapped_unmap_raw(mapped), content="0")
}

///|
test "raw context owns enum setters and text glyph bridge" {
  let surface = @surface_impl.image_create_raw(0, 8, 8)
  let ctx = create_raw(surface)
  inspect(status_raw(ctx), content="0")

  inspect(set_line_cap_raw(ctx, 2), content="0")
  inspect(get_line_cap_raw(ctx), content="2")
  inspect(set_line_join_raw(ctx, 1), content="0")
  inspect(get_line_join_raw(ctx), content="1")
  inspect(set_fill_rule_raw(ctx, 1), content="0")
  inspect(get_fill_rule_raw(ctx), content="1")
  inspect(set_operator_raw(ctx, 12), content="0")
  inspect(get_operator_raw(ctx), content="12")
  inspect(set_antialias_raw(ctx, 1), content="0")
  inspect(get_antialias_raw(ctx), content="1")

  inspect(select_font_face_raw(ctx, b"Sans", 2, 1), content="0")
  let indices : FixedArray[UInt64] = FixedArray::make(0, 0UL)
  let positions : FixedArray[Double] = FixedArray::make(0, 0.0)
  let clusters : FixedArray[Int] = FixedArray::make(0, 0)
  inspect(
    show_text_glyphs_raw(
      ctx, b"", indices, positions, positions, clusters, clusters, 0,
    ),
    content="0",
  )
}
