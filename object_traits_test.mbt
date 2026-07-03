///|
test "external object Eq and Hash traits follow existing cairoon equality" {
  let surface = Surface::image(Argb32, 2, 2)
  let ctx = Context::new(surface)
  let target = ctx.get_target()
  inspect(target == surface, content="true")
  inspect(Hash::hash(target) == Hash::hash(surface), content="true")
  let surface_map : Map[Surface, Int] = {}
  surface_map[surface] = 42
  inspect(surface_map[target], content="42")

  let other_surface = Surface::image(Argb32, 2, 2)
  inspect(surface == other_surface, content="false")
  inspect(ctx == ctx, content="true")
  inspect(ctx == Context::new(surface), content="false")

  let solid = Pattern::solid_rgba(0.25, 0.5, 0.75, 1.0)
  inspect(solid == solid, content="true")
  inspect(solid == Pattern::solid_rgba(0.25, 0.5, 0.75, 1.0), content="false")
  inspect(Hash::hash(solid) == Hash::hash(solid), content="true")

  let device = Device::script_stream(_bytes => Success)
  inspect(device == device, content="true")
  inspect(Hash::hash(device) == Hash::hash(device), content="true")
}

///|
test "font and region traits preserve cairo equality semantics" {
  let options = FontOptions::new()
  options.set_hint_metrics(HintMetricsDefault)
  let copied_options = options.copy()
  inspect(options == copied_options, content="true")
  inspect(Hash::hash(options) == Hash::hash(copied_options), content="true")
  copied_options.set_hint_metrics(HintMetricsOn)
  inspect(options == copied_options, content="false")

  let surface = Surface::image(Rgb24, 4, 4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif", slant=FontSlantItalic)
  let first_face = ctx.get_font_face()
  let second_face = ctx.get_font_face()
  inspect(first_face == second_face, content="true")
  inspect(Hash::hash(first_face) == Hash::hash(second_face), content="true")

  ctx.set_font_size(14.0)
  let first_scaled = ctx.get_scaled_font()
  let second_scaled = ctx.get_scaled_font()
  inspect(first_scaled == second_scaled, content="true")
  inspect(Hash::hash(first_scaled) == Hash::hash(second_scaled), content="true")

  let empty = Region::new()
  let other_empty = Region::new()
  let filled = Region::from_rectangle(RectangleInt::new(width=1, height=1))
  inspect(empty == other_empty, content="true")
  inspect(empty == filled, content="false")
}

///|
test "path comparison traits mirror pycairo self comparison behavior" {
  let ctx = Context::new(Surface::image(Argb32, 4, 4))
  ctx.line_to(1.0, 2.0)
  let path = ctx.copy_path()
  inspect(path == path, content="true")
  inspect(path != path, content="false")
  inspect(path < path, content="false")
  inspect(path <= path, content="true")
  inspect(path >= path, content="true")
  inspect(path > path, content="false")
  inspect(Hash::hash(path) == Hash::hash(path), content="true")
}
