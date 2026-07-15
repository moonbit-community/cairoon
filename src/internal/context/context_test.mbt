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
