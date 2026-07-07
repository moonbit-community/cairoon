///|
test "svg output contains stable geometry and color markers" {
  let path = "/tmp/cairoon_vector_output.svg"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.svg"
  let surface = @cairoon.Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"10\" height=\"10\"", "fill=\"rgb(0%, 0%, 100%)\"",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 0, path, oracle_path)
}

///|
test "svg output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_svg_multipage.svg"
  let surface = @cairoon.Surface::svg(12.0, 12.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"12\" height=\"12\"", "<pageSet>", "<page>",
    "fill=\"rgb(0%, 0%, 100%)\"", "fill=\"rgb(100%, 0%, 0%)\"", "</pageSet>", "</svg>",
  ])
}

///|
test "svg output preserves version unit and page markers" {
  let path = "/tmp/cairoon_vector_svg_unit_multipage.svg"
  let oracle_path = "/tmp/cairoon_vector_svg_unit_multipage_oracle.svg"
  let surface = @cairoon.Surface::svg(12.0, 12.0, path=Some(path))
  render_svg_unit_multipage_surface(surface)
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"12px\" height=\"12px\"", "<pageSet>",
    "<page>", "fill=\"rgb(0%, 0%, 100%)\"", "fill=\"rgb(100%, 0%, 0%)\"", "</pageSet>",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 20, path, oracle_path)
}
