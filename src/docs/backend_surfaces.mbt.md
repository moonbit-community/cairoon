# Backend Surfaces And Devices

cairoon exposes Cairo's portable vector and meta backends as constructors and
methods on the shared `Surface` and `Device` owner types. This mirrors
pycairo's backend classes without importing Python's subclass hierarchy into
MoonBit.

The examples in this file are executable tests. They focus on backend-specific
state, stream callbacks, retained owner behavior, and checked error mapping.

## Stream-Backed Vector Surfaces

PDF, PS, and SVG stream constructors receive copied `Bytes` chunks. Returning a
non-success Cairo `Status` from the writer maps back to `CairoIOError`.

```mbt check
///|
fn backend_docs_chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
fn backend_docs_chunks_contain(chunks : Array[Bytes], marker : String) -> Bool {
  backend_docs_chunks_to_string(chunks).contains(marker)
}

///|
fn backend_docs_paint_blue_and_finish(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test "backend docs: stream vector surfaces write backend output" {
  let pdf_chunks : Array[Bytes] = []
  let pdf = Surface::pdf_stream(12.0, 12.0, fn(chunk) {
    pdf_chunks.push(chunk)
    Success
  })
  backend_docs_paint_blue_and_finish(pdf)
  inspect(backend_docs_chunks_contain(pdf_chunks, "%PDF-1."), content="true")
  inspect(backend_docs_chunks_contain(pdf_chunks, "%%EOF"), content="true")

  let ps_chunks : Array[Bytes] = []
  let ps = Surface::ps_stream(12.0, 12.0, fn(chunk) {
    ps_chunks.push(chunk)
    Success
  })
  backend_docs_paint_blue_and_finish(ps)
  inspect(backend_docs_chunks_contain(ps_chunks, "%!PS-Adobe"), content="true")
  inspect(backend_docs_chunks_contain(ps_chunks, "%%EOF"), content="true")

  let svg_chunks : Array[Bytes] = []
  let svg = Surface::svg_stream(12.0, 12.0, fn(chunk) {
    svg_chunks.push(chunk)
    Success
  })
  backend_docs_paint_blue_and_finish(svg)
  inspect(backend_docs_chunks_contain(svg_chunks, "<svg"), content="true")
  inspect(backend_docs_chunks_contain(svg_chunks, "</svg>"), content="true")
}

///|
test "backend docs: stream writer errors raise CairoIOError" {
  let surface = Surface::pdf_stream(12.0, 12.0, fn(_) { WriteError })
  match run_cairo(() => backend_docs_paint_blue_and_finish(surface)) {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from PDF stream writer")
  }
}
```

## PDF Documents

PDF-specific methods include version restriction, metadata, custom metadata,
page labels, thumbnails, and outlines. Prefer typed `PDFVersion`,
`PDFMetadata`, and `PDFOutlineFlagSet` values in new MoonBit code; explicit
`*_raw` helpers accept pycairo's C integers for ported code. Version ids must be
returned by `PDFVersion::supported()`, metadata ids must be in `0..=6`, and
unknown values raise `CairoError(InvalidStatus, _)` before the state-changing
Cairo setter is called. Outline flag bits are preserved exactly, but only mask
`0x07` is portable. Custom metadata requires Cairo 1.17.6; older supported
versions raise `CairoError(InvalidStatus, _)`.

```mbt check
///|
test "backend docs: PDF metadata page labels and outlines" {
  let version : PDFVersion = PdfVersion1_4
  inspect(PDFVersion::supported().any(item => item == version), content="true")
  inspect(version.to_string().contains("PDF"), content="true")
  inspect(PDFVersion::to_string_raw(0).contains("PDF"), content="true")
  match run_cairo(() => PDFVersion::to_string_raw(99)) {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected an unknown PDF version error")
  }

  let surface = Surface::pdf(24.0, 24.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePdf")
  match run_cairo(() => surface.pdf_restrict_to_version_raw(99)) {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected an unsupported PDF restriction error")
  }
  surface.pdf_restrict_to_version(version)
  surface.pdf_restrict_to_version_raw(0)
  surface.pdf_set_size(30.0, 30.0)
  surface.pdf_set_metadata(PdfMetadataTitle, "cairoon backend docs")
  surface.pdf_set_metadata(PdfMetadataCreateDate, "2026-01-02T03:04:05Z")
  match run_cairo(() => surface.pdf_set_metadata_raw(7, "unknown")) {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected an unknown PDF metadata error")
  }
  surface.pdf_set_metadata_raw(4, "cairoon backend docs raw creator")
  if CAIRO_VERSION >= 11706 {
    surface.pdf_set_custom_metadata("cairoon-key", Some("cairoon-value"))
    surface.pdf_set_custom_metadata("cairoon-key", Some(""))
    surface.pdf_set_custom_metadata("cairoon-key", Some("replacement"))
    surface.pdf_set_custom_metadata("cairoon-key", None)
  } else {
    match
      run_cairo(() => {
        surface.pdf_set_custom_metadata("cairoon-key", Some("cairoon-value"))
      }) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => @test.fail("expected custom metadata to require Cairo 1.17.6")
    }
  }
  surface.pdf_set_page_label("page one")
  surface.pdf_set_thumbnail_size(2, 2)
  surface.pdf_set_thumbnail_size(0, 2)
  surface.pdf_set_thumbnail_size(2, 2)

  let flags = PDFOutlineFlagSet::none().add(PdfOutlineOpen).add(PdfOutlineBold)
  let single_flag = PDFOutlineFlagSet::of(PdfOutlineItalic)
  let raw_flags = PDFOutlineFlagSet::from_bits(0x03)
  inspect(flags.contains(PdfOutlineOpen), content="true")
  inspect(flags.contains(PdfOutlineItalic), content="false")
  inspect(single_flag.bits(), content="4")
  inspect(raw_flags.bits(), content="3")

  let outline_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "chapter",
    "page=1 pos=[1 1]",
    flags,
  )
  inspect(outline_id > PDF_OUTLINE_ROOT, content="true")
  let raw_outline_id = surface.pdf_add_outline_raw(
    outline_id,
    "raw appendix",
    "page=1 pos=[2 2]",
    raw_flags.bits(),
  )
  inspect(raw_outline_id > outline_id, content="true")
  let typed_outline_id = surface.pdf_add_outline(
    raw_outline_id,
    "typed detail",
    "page=1 pos=[3 3]",
    PdfOutlineItalic,
  )
  inspect(typed_outline_id > raw_outline_id, content="true")
  backend_docs_paint_blue_and_finish(surface)
}
```

## PostScript And SVG Settings

PS pages are point-sized. Restrict the language level before document drawing,
set EPS mode before drawing the current page, and change page size only before
that page begins. EPS output must remain single-page. DSC comments move from
Header to Setup to PageSetup; comments must begin with `%`, fit in 255 UTF-8
bytes, and contain no newline. The tested raw level sentinel `99` is a no-op on
exact Cairo 1.15.10 and 1.18.4; other out-of-range levels are unsupported.

SVG surfaces also use point-sized pages, must be version-restricted before
drawing, and can label the root width/height with a document unit without
rescaling drawing coordinates. Document-unit APIs require cairoon's Cairo
1.15.10 compatibility floor or Cairo 1.16 and newer. Historical defaults vary
between user units and points, so portable output sets the unit explicitly. As
with PDF, raw helpers preserve pycairo-compatible integer enum paths. The tested
positive sentinel `99` is a no-op on exact Cairo 1.15.10 and 1.18.4; other
out-of-range SVG restriction/unit integers are unsupported.

```mbt check
///|
test "backend docs: PS level EPS DSC and SVG document units" {
  let level : PSLevel = PsLevel3
  inspect(PSLevel::supported().any(item => item == level), content="true")
  inspect(level.to_string().contains("PS"), content="true")
  inspect(PSLevel::to_string_raw(0).contains("PS"), content="true")

  let ps = Surface::ps(24.0, 24.0)
  debug_inspect(ps.get_type(), content="SurfaceTypePs")
  ps.ps_restrict_to_level_raw(99)
  debug_inspect(ps.status(), content="Success")
  ps.ps_restrict_to_level(PsLevel2)
  ps.ps_restrict_to_level_raw(0)
  ps.ps_set_eps(true)
  inspect(ps.ps_get_eps(), content="true")
  ps.ps_set_size(30.0, 30.0)
  ps.ps_dsc_comment("%%Title: cairoon backend docs")
  ps.ps_dsc_begin_setup()
  ps.ps_dsc_comment("%%IncludeFeature: *MediaColor White")
  ps.ps_dsc_begin_page_setup()
  ps.ps_dsc_comment("%%IncludeFeature: *PageSize A4")
  backend_docs_paint_blue_and_finish(ps)

  let version : SVGVersion = SvgVersion1_2
  inspect(SVGVersion::supported().any(item => item == version), content="true")
  inspect(version.to_string().contains("SVG"), content="true")
  inspect(SVGVersion::to_string_raw(0).contains("SVG"), content="true")

  let svg = Surface::svg(24.0, 24.0)
  debug_inspect(svg.get_type(), content="SurfaceTypeSvg")
  svg.svg_restrict_to_version(version)
  svg.svg_restrict_to_version_raw(1)
  svg.svg_set_document_unit(SvgUnitPx)
  svg.svg_set_document_unit_raw(3)
  inspect(svg.svg_get_document_unit_raw(), content="3")
  debug_inspect(svg.svg_get_document_unit(), content="SvgUnitPx")
  svg.svg_set_document_unit_raw(99)
  inspect(svg.svg_get_document_unit_raw(), content="3")
  svg.svg_restrict_to_version_raw(99)
  debug_inspect(svg.status(), content="Success")
  backend_docs_paint_blue_and_finish(svg)
}
```

## Recording And Tee Surfaces

Recording surfaces snapshot the paths, patterns, and other Cairo state needed
to replay high-level drawing operations. Optional extents are expressed in
recording-surface pixels; omitting them creates an unbounded recording.
`Surface::recording_raw` mirrors pycairo's C-int `Content` constructor argument.
The configured extents remain queryable after `finish`, while ink measurement
follows cairoon's terminal-surface rule and raises `SurfaceFinished`. Recording
surfaces require Cairo 1.10 or newer.

Tee surfaces fan drawing out to a primary surface and all added replicas. The
primary is always index zero and supplies queried surface properties. Cairoon
retains primary and replica wrappers while the tee needs them; an indexed
result owns an independent native reference and survives later removal. An
invalid removal poisons the tee with Cairo's sticky `InvalidIndex`; self-add or
self-remove is rejected with `InvalidStatus` to avoid an ownership cycle. Tee
surfaces require a Cairo build with `CAIRO_HAS_TEE_SURFACE` (Cairo 1.10 or
newer).

```mbt check
///|
fn backend_docs_expect_pixel(
  bytes : Bytes,
  expected : Array[Int],
) -> Unit raise {
  inspect(bytes.length(), content="\{expected.length()}")
  for index in 0..<expected.length() {
    inspect(bytes[index].to_int(), content="\{expected[index]}")
  }
}

///|
test "backend docs: recording replay and tee fanout" {
  let recording = Surface::recording_raw(
    0x3000,
    extents=Some(Rectangle::new(0.0, 0.0, 1.0, 1.0)),
  )
  debug_inspect(recording.get_type(), content="SurfaceTypeRecording")
  inspect(recording.get_content_raw(), content="12288")
  match recording.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(0, 0, 1, 1)")
    None => @test.fail("expected recording extents")
  }
  let recorder = Context::new(recording)
  recorder.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  recorder.rectangle(0.0, 0.0, 1.0, 1.0)
  recorder.fill()
  debug_inspect(
    recording.recording_ink_extents().components(),
    content="(0, 0, 1, 1)",
  )

  let replay = Surface::image(Argb32, 1, 1)
  let replay_ctx = Context::new(replay)
  replay_ctx.set_source(Pattern::for_surface(recording))
  replay_ctx.paint()
  backend_docs_expect_pixel(replay.copy_data(), [0, 0, 255, 255])

  let primary = Surface::image(Argb32, 1, 1)
  let target = Surface::image(Argb32, 1, 1)
  let tee = Surface::tee(primary)
  debug_inspect(tee.get_type(), content="SurfaceTypeTee")
  tee.tee_add(target)
  let tee_ctx = Context::new(tee)
  tee_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  tee_ctx.paint()
  backend_docs_expect_pixel(primary.copy_data(), [0, 255, 0, 255])
  backend_docs_expect_pixel(target.copy_data(), [0, 255, 0, 255])
  let indexed_target = tee.tee_index(1)
  backend_docs_expect_pixel(indexed_target.copy_data(), [0, 255, 0, 255])
  tee.tee_remove(target)
  backend_docs_expect_pixel(indexed_target.copy_data(), [0, 255, 0, 255])

  recording.finish()
  match recording.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(0, 0, 1, 1)")
    None => @test.fail("expected recording extents after finish")
  }

  tee.finish()
  match run_cairo(() => tee.tee_index(0)) {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected finished tee error")
  }
}
```

## Script Devices And Script Surfaces

Script devices are `Device` objects. They can be file-backed or stream-backed.
`Device::with_finished` mirrors pycairo's `with device:` cleanup behavior, and
`Surface::script_raw` mirrors pycairo's C-int `Content` constructor argument.
`Surface::script_for_target` proxies drawing onto an existing target.

```mbt check
///|
test "backend docs: script devices retain surfaces and write chunks" {
  let chunks : Array[Bytes] = []
  let device = Device::script_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  debug_inspect(device.get_type(), content="DeviceTypeScript")
  debug_inspect(device.script_get_mode(), content="ScriptModeAscii")
  device.script_set_mode(ScriptModeBinary)
  debug_inspect(device.script_get_mode(), content="ScriptModeBinary")
  device.script_set_mode(ScriptModeAscii)
  device.script_write_comment("cairoon backend docs")

  let surface = Surface::script_raw(device, 0x3000, 4.0, 4.0)
  debug_inspect(surface.get_type(), content="SurfaceTypeScript")
  inspect(surface.get_content_raw(), content="12288")
  match surface.get_device() {
    Some(other) => inspect(device.equal(other), content="true")
    None => @test.fail("expected script surface device")
  }
  backend_docs_paint_blue_and_finish(surface)
  device.finish()

  inspect(chunks.length() > 0, content="true")
  inspect(
    backend_docs_chunks_to_string(chunks).contains("cairoon backend docs"),
    content="true",
  )
}

///|
test "backend docs: script device scoped finish" {
  let chunks : Array[Bytes] = []
  let device = Device::script_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  let type_ = device.with_finished(() => {
    device.script_write_comment("cairoon scoped script device")
    device.get_type()
  })
  debug_inspect(type_, content="DeviceTypeScript")
  match run_cairo(() => device.acquire()) {
    Err(CairoError(DeviceFinished, _)) => ()
    _ => @test.fail("expected DeviceFinished")
  }
  inspect(
    backend_docs_chunks_to_string(chunks).contains(
      "cairoon scoped script device",
    ),
    content="true",
  )
}

///|
test "backend docs: script_for_target proxies drawing to target" {
  let device = Device::script("/tmp/cairoon_backend_docs_script_target.cs")
  let target = Surface::image(Argb32, 1, 1)
  let surface = Surface::script_for_target(device, target)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  device.finish()
  backend_docs_expect_pixel(target.copy_data(), [0, 0, 255, 255])
}
```

## Checked Backend Errors

Backend-only methods map non-matching surface/device families and invalid
strings to checked Cairo errors.

```mbt check
///|
test "backend docs: backend-specific methods report checked errors" {
  let image = Surface::image(Argb32, 1, 1)

  match run_cairo(() => image.pdf_set_metadata(PdfMetadataTitle, "nope")) {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected PDF SurfaceTypeMismatch")
  }

  match run_cairo(() => image.ps_dsc_comment("%%Title: nope")) {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected PS SurfaceTypeMismatch")
  }

  match
    run_cairo(() => {
      let _ = image.svg_get_document_unit()
      ()
    }) {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SVG SurfaceTypeMismatch")
  }

  let tee = Surface::tee(image)
  match run_cairo(() => tee.tee_index(-1)) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected tee InvalidIndex")
  }

  match run_cairo(() => Device::script("/tmp/cairoon\u{0}bad.cs")) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected script path InvalidString")
  }
}
```
