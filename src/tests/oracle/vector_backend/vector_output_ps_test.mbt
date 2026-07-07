///|
test "ps output contains stable page and drawing markers" {
  let path = "/tmp/cairoon_vector_output.ps"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.ps"
  let surface = @cairoon.Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 1", "0 0 1 rg", "0 0 10 10 rectfill", "%%EOF",
  ])
  expect_vector_oracle_match(1, 0, path, oracle_path)
}

///|
test "ps output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_ps_multipage.ps"
  let surface = @cairoon.Surface::ps(12.0, 12.0, path=Some(path))
  let ctx = @cairoon.Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "0 0 1 rg", "1 0 0 rg",
    "%%EOF",
  ])
}

///|
test "ps output preserves dsc comments across multiple pages" {
  let path = "/tmp/cairoon_vector_ps_dsc_multipage.ps"
  let oracle_path = "/tmp/cairoon_vector_ps_dsc_multipage_oracle.ps"
  let surface = @cairoon.Surface::ps(12.0, 12.0, path=Some(path))
  render_ps_dsc_multipage_surface(surface)
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon PS Combined", "%%IncludeFeature: *MediaColor White",
    "%%IncludeFeature: *PageSize A4", "%%IncludeFeature: *MediaType Plain", "%%Pages: 2",
    "%%Page: 1 1", "%%Page: 2 2", "0 0 1 rg", "1 0 0 rg", "%%EOF",
  ])
  expect_vector_oracle_match(1, 19, path, oracle_path)
}

///|
test "ps link tags are inert for postscript output" {
  let plain_path = "/tmp/cairoon_vector_ps_plain_tag_scene.ps"
  let tagged_path = "/tmp/cairoon_vector_ps_tag_scene.ps"
  let plain = @cairoon.Surface::ps(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(@cairoon.Context::new(plain), false)
  plain.finish()
  let tagged = @cairoon.Surface::ps(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(@cairoon.Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(1, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "/Subtype /Link", "/URI",
  ])
}
