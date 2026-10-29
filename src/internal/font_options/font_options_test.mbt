///|
test "raw font options handle preserves state across copy" {
  let options = @font_options.create_raw()
  inspect(@font_options.status_raw(options), content="0")
  inspect(@font_options.set_antialias_value_raw(options, 2), content="0")
  inspect(@font_options.set_subpixel_order_value_raw(options, 1), content="0")
  inspect(@font_options.set_hint_style_value_raw(options, 3), content="0")
  inspect(@font_options.set_hint_metrics_value_raw(options, 2), content="0")
  inspect(@font_options.get_antialias_raw(options), content="2")
  inspect(@font_options.get_subpixel_order_raw(options), content="1")
  inspect(@font_options.get_hint_style_raw(options), content="3")
  inspect(@font_options.get_hint_metrics_raw(options), content="2")

  let status = Ref(-1)
  let copy = @font_options.copy_raw(options, status)
  inspect(status.val, content="0")
  inspect(@font_options.equal_raw(options, copy), content="true")
  inspect(
    @font_options.hash_raw(options) == @font_options.hash_raw(copy),
    content="true",
  )

  inspect(@font_options.set_antialias_raw(copy, 1), content="0")
  inspect(@font_options.get_antialias_raw(options), content="2")
  inspect(@font_options.get_antialias_raw(copy), content="1")
  inspect(@font_options.equal_raw(options, copy), content="false")
}

///|
test "raw font options handle merges non-default state" {
  let options = @font_options.create_raw()
  let overlay = @font_options.create_raw()
  inspect(@font_options.set_antialias_raw(overlay, 3), content="0")
  inspect(@font_options.set_subpixel_order_raw(overlay, 2), content="0")
  inspect(@font_options.set_hint_style_raw(overlay, 4), content="0")
  inspect(@font_options.set_hint_metrics_raw(overlay, 1), content="0")
  inspect(@font_options.merge_raw(options, overlay), content="0")
  inspect(@font_options.get_antialias_raw(options), content="3")
  inspect(@font_options.get_subpixel_order_raw(options), content="2")
  inspect(@font_options.get_hint_style_raw(options), content="4")
  inspect(@font_options.get_hint_metrics_raw(options), content="1")
}
