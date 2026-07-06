///|
fn stream_equivalence_extension(kind : Int) -> String {
  match kind {
    0 => "pdf"
    1 => "ps"
    2 => "svg"
    _ => "out"
  }
}

///|
fn make_stream_equivalence_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 => {
      let surface = @cairoon.Surface::pdf(12.0, 12.0, path=Some(path))
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface
    }
    1 => @cairoon.Surface::ps(12.0, 12.0, path=Some(path))
    2 => {
      let surface = @cairoon.Surface::svg(12.0, 12.0, path=Some(path))
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
      surface
    }
    _ => vector_backend_invalid_surface()
  }
}

///|
fn make_stream_equivalence_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 => {
      let surface = @cairoon.Surface::pdf_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface
    }
    1 =>
      @cairoon.Surface::ps_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 => {
      let surface = @cairoon.Surface::svg_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
      surface
    }
    _ => vector_backend_invalid_surface()
  }
}

///|
fn make_stream_document_feature_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 => @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
    1 => @cairoon.Surface::ps(12.0, 12.0, path=Some(path))
    2 => @cairoon.Surface::svg(12.0, 12.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
}

///|
fn make_stream_document_feature_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 =>
      @cairoon.Surface::pdf_stream(100.0, 100.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
}

///|
fn render_stream_equivalence_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.rectangle(1.0, 1.0, 10.0, 10.0)
  ctx.fill()
  ctx.show_page()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.arc(6.0, 6.0, 4.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.show_page()
  surface.finish()
}

///|
fn render_stream_copy_page_retained_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_vector_oracle_scene(ctx, 31)
  surface.finish()
}

///|
fn render_stream_surface_page_retained_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  draw_surface_page_retained_scene(surface)
  surface.finish()
}

///|
fn render_stream_surface_show_page_cleared_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  draw_surface_show_page_cleared_scene(surface)
  surface.finish()
}

///|
fn render_stream_glyph_vector_scene(
  surface : @cairoon.Surface,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_vector_oracle_scene(ctx, scene)
  surface.finish()
}

///|
fn render_stream_tagged_multipage_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(2.0)

  ctx.set_source_rgb(0.9, 0.95, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/stream'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("stream link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.show_page()

  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("stream document")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()

  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.rectangle(2.0, 2.0, 8.0, 8.0)
  ctx.fill()
  ctx.show_page()
  surface.finish()
}

///|
fn render_stream_wide_multipage_tag_vector_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_wide_multi_page_tag_vector_scene(ctx)
  surface.finish()
}

///|
fn render_stream_mixed_tag_vector_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_mixed_tag_vector_scene(ctx)
  surface.finish()
}

///|
fn render_stream_tagged_show_text_glyphs_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_tagged_show_text_glyphs_scene(ctx)
  surface.finish()
}

///|
fn render_stream_grouped_glyph_tag_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_grouped_glyph_tag_multi_page_scene(ctx)
  surface.finish()
}

///|
fn render_stream_layered_multipage_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  draw_layered_multi_page_scene(ctx)
  surface.finish()
}

///|
fn render_stream_document_feature_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => render_pdf_document_feature_surface(surface)
    1 => render_ps_dsc_multipage_surface(surface)
    2 => render_svg_unit_multipage_surface(surface)
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn stream_equivalence_chunks_to_bytes(chunks : Array[Bytes]) -> Bytes {
  let mut bytes = Bytes::default()
  for chunk in chunks {
    bytes = bytes + chunk
  }
  bytes
}

///|
fn expect_stream_output_markers(
  chunks : Array[Bytes],
  markers : Array[String],
) -> Unit raise {
  inspect(chunks.length() > 0, content="true")
  let output = @utf8.decode_lossy(stream_equivalence_chunks_to_bytes(chunks))
  for marker in markers {
    inspect(output.contains(marker), content="true")
  }
}

///|
fn expect_stream_output_absent(
  chunks : Array[Bytes],
  markers : Array[String],
) -> Unit raise {
  inspect(chunks.length() > 0, content="true")
  let output = @utf8.decode_lossy(stream_equivalence_chunks_to_bytes(chunks))
  for marker in markers {
    inspect(output.contains(marker), content="false")
  }
}
