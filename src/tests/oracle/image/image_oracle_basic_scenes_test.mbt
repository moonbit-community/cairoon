///|
fn draw_image_oracle_basic_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    0 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
    }
    1 => {
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.move_to(2.5, 2.5)
      ctx.line_to(13.5, 13.5)
      ctx.stroke()
    }
    2 => {
      ctx.rectangle(2.0, 2.0, 10.0, 10.0)
      ctx.set_source_rgba(0.0, 1.0, 0.0, 0.75)
      ctx.fill_preserve()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.stroke()
    }
    3 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.move_to(2.0, 14.0)
      ctx.curve_to(5.0, 1.0, 11.0, 15.0, 14.0, 2.0)
      ctx.stroke()
    }
    4 => {
      ctx.translate(8.0, 8.0)
      ctx.rotate(0.25)
      ctx.scale(1.2, 0.8)
      ctx.rectangle(-4.0, -3.0, 8.0, 6.0)
      ctx.set_source_rgb(1.0, 0.5, 0.0)
      ctx.fill()
    }
    5 => {
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
      ctx.paint()
    }
    6 => {
      let pattern = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    7 => {
      let pattern = @cairoon.Pattern::radial(8.0, 8.0, 1.0, 8.0, 8.0, 8.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    8 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(8.0)
      ctx.move_to(2.0, 10.0)
      ctx.text_path("Hi")
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.fill()
    }
    9 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(8.0)
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.move_to(2.0, 10.0)
      ctx.show_text("Hi")
    }
    10 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.glyph_path([@cairoon.Glyph::new(0UL, 2.0, 12.0)])
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.fill()
    }
    11 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.show_glyphs([@cairoon.Glyph::new(0UL, 2.0, 12.0)])
    }
    12 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
      ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
    }
    13 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      ctx.set_source_surface(source, x=7.0, y=6.0)
      ctx.paint()
    }
    14 => {
      let mask = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      let mask_ctx = @cairoon.Context::new(mask)
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
      mask_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.5)
      mask_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
      mask_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.mask_surface(mask, x=7.0, y=6.0)
    }
    15 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::raster_source(
        @cairoon.ContentColorAlpha,
        2,
        2,
      )
      pattern.raster_set_acquire(
        fn(_, _) { source },
        release=Some(fn(_) { () }),
      )
      pattern.set_extend(@cairoon.Repeat)
      pattern.set_filter(@cairoon.Nearest)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    16 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.set_line_cap(@cairoon.LineCapRound)
      ctx.set_dash([2.0, 2.0], offset=0.0)
      ctx.move_to(2.0, 8.0)
      ctx.line_to(14.0, 8.0)
      ctx.stroke()
    }
    17 => {
      ctx.rectangle(4.0, 4.0, 8.0, 8.0)
      ctx.clip()
      ctx.set_source_rgb(0.0, 1.0, 0.0)
      ctx.paint()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.rectangle(4.0, 4.0, 4.0, 4.0)
      ctx.fill()
    }
    18 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorClear)
      ctx.rectangle(4.0, 4.0, 8.0, 8.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
      ctx.rectangle(0.0, 0.0, 8.0, 8.0)
      ctx.fill()
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}
