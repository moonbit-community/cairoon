# Migration Audit History, Part 6

Historical snapshot of `AUDIT.md` lines 2654-3221 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

  The later pycairo append-path string equivalence slice added one black-box
  Context path test proving `append_path` preserves the copied path's
  pycairo-style string after the source context has been cleared. This raised
  `context_path_test.mbt` to 10 tests and the full native suite to 360 tests.
  The later PDF/PS stream target lifetime slice added one black-box Context
  lifetime test proving `Context::new` keeps vector stream targets alive after
  the original surface wrapper leaves scope, and added `context_lifetime_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_lifetime_test.mbt` to 9 tests and the full native suite to 361 tests.
  The later TeeSurface positive out-of-range status slice added one black-box
  test proving a valid tee surface preserves Cairo's positive out-of-range
  `NoMemory` status as `CairoMemoryError(NoMemory, _)`, matching pycairo's
  `MemoryError` path, and added `surface_tee_test.mbt` to the normal and ASan
  verification gates. This raised `surface_tee_test.mbt` to 4 tests and the
  full native suite to 362 tests.
  The later mapped-image scoped-error upload slice added one black-box test
  proving `MappedImageSurface::with_unmapped` uploads painted data before
  propagating a Cairo error, and added `surface_mapped_test.mbt` to the normal
  and ASan verification gates. This raised `surface_mapped_test.mbt` to 6 tests
  and the full native suite to 363 tests.
  The later pycairo polygon fill-extents slice added one black-box Context
  extents test proving Cairo's line-to-created polygon fill bounds match
  pycairo's `(0, 0, 1, 1)` expectation, and added context state/matrix/extents
  tests to the normal and ASan verification gates. This raised
  `context_extents_test.mbt` to 5 tests and the full native suite to 364 tests.
  The later pycairo mesh curve-first patch slice added one black-box
  MeshPattern test proving a patch can start with `curve_to` before any
  explicit `move_to`, added the missing `set_corner_color_rgb` construction
  error check, and added gradient/mesh pattern tests to the normal and ASan
  verification gates. This raised `pattern_mesh_test.mbt` to 6 tests and the
  full native suite to 365 tests.
  The later pycairo empty-path clip slice added one black-box Context clip
  test proving `clip()` with no current path makes `in_clip` false until
  `reset_clip()` restores the surface clip, and added `context_clip_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_clip_test.mbt` to 6 tests and the full native suite to 366 tests.
  The later pycairo source RGBA round-trip slice added one black-box Context
  painting test proving `set_source_rgb/rgba` installs a solid pattern whose
  RGBA values are visible through `get_source().get_rgba()`, and added
  `context_painting_test.mbt` to the normal and ASan verification gates. This
  raised `context_painting_test.mbt` to 7 tests and the full native suite to
  367 tests.
  The later pycairo rectangle path-extents slice added one black-box Context
  path test proving `rectangle(1, 2, 4, 5)` yields path extents
  `(1, 2, 5, 7)`, and added `context_path_test.mbt` to the normal and ASan
  verification gates. This raised `context_path_test.mbt` to 11 tests and the
  full native suite to 368 tests.
  The later pycairo group-target stack-restoration slice added one black-box
  Context group test proving `get_group_target()` switches away from the
  original target inside `push_group()` and restores to the original target
  after both `pop_group()` and `pop_group_to_source()`, and added
  `context_group_test.mbt` to the normal and ASan verification gates. This
  raised `context_group_test.mbt` to 4 tests and the full native suite to 369
  tests.
  The later pycairo context font-extents parity slice added one black-box
  Context text test proving `Context::font_extents()` matches the current
  `ScaledFont::extents()`, and added `context_text_test.mbt` and
  `glyph_array_test.mbt` to the normal and ASan verification gates. This raised
  `context_text_test.mbt` to 6 tests and the full native suite to 370 tests.
  The later ScaledFont returned-object lifetime slice added one black-box test
  proving `ScaledFont::get_font_face()` and `get_font_options()` remain usable
  after the source scaled-font scope exits, and added `font_options_test.mbt`,
  `font_face_test.mbt`, `scaled_font_test.mbt`, and `lifetime_stress_test.mbt`
  to the normal and ASan verification gates. This raised
  `scaled_font_test.mbt` to 8 tests and the full native suite to 371 tests.
  The later Path/Region lifetime gate slice added black-box tests proving a
  copied `Path` remains usable after its source `Context` scope exits and a
  copied `Region` remains usable after its source `Region` scope exits, then
  added `path_test.mbt` and `region_test.mbt` to the normal and ASan
  verification gates. This raised `path_test.mbt` to 7 tests,
  `region_test.mbt` to 10 tests, and the full native suite to 373 tests.
  The later Surface/Device targeted gate slice refactored `scripts/verify.sh`
  to drive the normal and ASan target lists from one shared array, then added
  `surface_context_test.mbt`, `image_data_test.mbt`,
  `surface_subsurface_test.mbt`, `surface_recording_test.mbt`,
  `surface_mime_test.mbt`, `surface_pdf_test.mbt`, `surface_ps_test.mbt`,
  `surface_svg_test.mbt`, `device_test.mbt`, and `object_traits_test.mbt` to
  both gates. This did not add public API or new tests; it makes the existing
  67 surface/device/object-trait tests part of the routine ASan reliability
  sweep.
  The later raw FFI split slice moved the `FontOptions`, `FontFace`,
  `ScaledFont`, and text-to-glyphs extern declarations from the 2580-line
  `ffi.mbt` into `ffi_font.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 2226 lines. This did not change public API or test
  count.
  The later Font raw FFI family split slice moved FontOptions, FontFace,
  ScaledFont, and text-to-glyphs result extern declarations from the 353-line
  `ffi_font.mbt` into `ffi_font_options.mbt`, `ffi_font_face.mbt`,
  `ffi_scaled_font.mbt`, and `ffi_text_to_glyphs.mbt`, added all four files to
  the native target list, and removed the now-empty aggregate `ffi_font.mbt`.
  This did not change public API or test count.
  The later pattern raw FFI split slice moved raw `Pattern`, mesh-pattern, and
  raster-source-pattern extern declarations from `ffi.mbt` into
  `ffi_pattern.mbt`, added that file to the native target list, and reduced
  `ffi.mbt` to 1866 lines. This did not change public API or test count.
  The later Pattern raw FFI family split slice moved mesh-pattern and
  raster-source-pattern extern declarations from the 359-line
  `ffi_pattern.mbt` into `ffi_pattern_mesh.mbt` and
  `ffi_pattern_raster_source.mbt`, added both files to the native target list,
  and left `ffi_pattern.mbt` as the 184-line base/surface/solid/gradient extern
  file. This did not change public API or test count.
  The later Path/Region raw FFI split slice moved raw `Path` and `Region`
  extern declarations from `ffi.mbt` into `ffi_path.mbt` and
  `ffi_region.mbt`, added both files to the native target list, and reduced
  `ffi.mbt` to 1683 lines. This did not change public API or test count.
  The later Device raw FFI split slice moved raw `Device`, script-device,
  script-surface, and surface-get-device extern declarations from `ffi.mbt`
  into `ffi_device.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 1578 lines. This did not change public API or test
  count.
  The later PDF surface raw FFI split slice moved raw PDF surface extern
  declarations from `ffi.mbt` into `ffi_pdf_surface.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 1481 lines. This did not
  change public API or test count.
  The later PostScript surface raw FFI split slice moved raw PostScript surface
  extern declarations from `ffi.mbt` into `ffi_ps_surface.mbt`, added that file
  to the native target list, and reduced `ffi.mbt` to 1404 lines. This did not
  change public API or test count.
  The later SVG surface raw FFI split slice moved raw SVG surface extern
  declarations from `ffi.mbt` into `ffi_svg_surface.mbt`, added that file to the
  native target list, and reduced `ffi.mbt` to 1344 lines. This did not change
  public API or test count.
  The later Tee surface raw FFI split slice moved raw Tee surface extern
  declarations from `ffi.mbt` into `ffi_tee_surface.mbt`, added that file to the
  native target list, and reduced `ffi.mbt` to 1315 lines. This did not change
  public API or test count.
  The later ImageData raw FFI split slice moved raw `ImageData` and image/mapped
  get-data extern declarations from `ffi.mbt` into `ffi_image_data.mbt`, added
  that file to the native target list, and reduced `ffi.mbt` to 1270 lines. This
  did not change public API or test count.
  The later surface raw FFI split slice moved raw image, recording, base
  surface, mapped-image-surface, PNG stream, MIME-data, and surface
  font-options extern declarations from `ffi.mbt` into `ffi_surface.mbt`, added
  that file to the native target list, and reduced `ffi.mbt` to 906 lines. This
  did not change public API or test count.
  The later Surface raw FFI family split slice moved image, mapped-image,
  recording, PNG, MIME, state/page, and surface font-options extern
  declarations from the 363-line `ffi_surface.mbt` into
  `ffi_image_surface.mbt`, `ffi_mapped_image_surface.mbt`,
  `ffi_recording_surface.mbt`, `ffi_surface_png.mbt`,
  `ffi_surface_mime.mbt`, `ffi_surface_state.mbt`, and
  `ffi_surface_font_options.mbt`, added all seven files to the native target
  list, and left `ffi_surface.mbt` as the 54-line base-surface extern file.
  This did not change public API or test count.
  The later Context core raw FFI split slice moved raw context construction,
  status, identity, save/restore, tag, target/source, and group extern
  declarations from `ffi.mbt` into `ffi_context_core.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 820 lines. This did not
  change public API or test count.
  The later Context font/text raw FFI split slice moved raw context
  font-options, font-face, toy-font selection, font-matrix, text, glyph,
  show-text-glyphs, and scaled-font extern declarations from `ffi.mbt` into
  `ffi_context_font_text.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 659 lines. This did not change public API or test count.
  The later Context matrix raw FFI split slice moved raw context transform,
  CTM, identity-matrix, and user/device coordinate-conversion extern
  declarations from `ffi.mbt` into `ffi_context_matrix.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 559 lines. This did not
  change public API or test count.
  The later Context drawing-state raw FFI split slice moved raw context
  line-style, hairline, fill/operator/antialias/tolerance, miter, and dash
  extern declarations from `ffi.mbt` into `ffi_context_state.mbt`, added that
  file to the native target list, and reduced `ffi.mbt` to 444 lines. This did
  not change public API or test count.
  The later Context path raw FFI split slice moved raw context path
  construction, current-point, copy-path, and append-path extern declarations
  from `ffi.mbt` into `ffi_context_path.mbt`, added that file to the native
  target list, and reduced `ffi.mbt` to 311 lines. This did not change public
  API or test count.
  The later Context clip/extents raw FFI split slice moved raw context clip,
  clip-rectangle-list, fill/stroke/path extents, and hit-testing extern
  declarations from `ffi.mbt` into `ffi_context_clip_extents.mbt`, added that
  file to the native target list, and reduced `ffi.mbt` to 225 lines. This did
  not change public API or test count.
  The later Context paint raw FFI split slice moved raw context source,
  paint/mask/fill/stroke, and page-operation extern declarations from
  `ffi.mbt` into `ffi_context_paint.mbt`, added that file to the native target
  list, and reduced `ffi.mbt` to 142 lines. This did not change public API or
  test count.
  The later Context wrapper split slice moved public `Context` font/text,
  transform, drawing-state, path, clip/extents/hit-test, and source/paint/page
  wrappers from the 1000-line `context.mbt` into six family files matching the
  raw FFI split, leaving `context.mbt` as the 117-line core wrapper file. This
  did not change public API or test count.
  The later Context C glue split slice moved context font/text,
  matrix/coordinate-conversion, drawing-state/line-style/dash, path
  construction/copy, clip/extents/hit-test, and source/paint/page C stubs from
  the 1518-line `cairoon_context.c` into six family C files matching the raw
  FFI and wrapper splits, leaving `cairoon_context.c` as the 195-line core
  construction/status/tag/target/source/group glue file. This did not change
  public API or test count.
  The later Surface C glue split slice moved image surface constructors,
  PNG-read helpers, image queries/copy-data, mapped-image lifecycle/queries,
  and recording-surface constructors/extents from the 975-line
  `cairoon_surface.c` into `cairoon_image_surface.c`,
  `cairoon_mapped_image_surface.c`, and `cairoon_recording_surface.c`, leaving
  `cairoon_surface.c` as the 516-line base surface glue file. This did not
  change public API or test count.
  The later base Surface C glue split slice moved PNG writers, MIME helpers,
  state/page helpers, and surface font-options from the 516-line
  `cairoon_surface.c` into `cairoon_surface_png.c`,
  `cairoon_surface_mime.c`, `cairoon_surface_state.c`, and
  `cairoon_surface_font_options.c`, leaving `cairoon_surface.c` as the
  161-line base creation/status/equality/hash/type/finish glue file. This did
  not change public API or test count.
  The later Surface wrapper split slice moved image, PNG, MIME, recording,
  TeeSurface, state/page, and surface font-options public wrapper methods from
  the 496-line `surface.mbt` into `image_surface.mbt`, `surface_png.mbt`,
  `surface_mime.mbt`, `recording_surface.mbt`, `tee_surface.mbt`,
  `surface_state.mbt`, and `surface_font_options.mbt`, leaving `surface.mbt`
  as the 122-line core helper/constructor/status/device/finish wrapper file.
  This did not change public API or test count.
  The later Pattern C glue split slice moved mesh-pattern operations and
  raster-source callback/owner lifecycle glue from the 921-line
  `cairoon_pattern.c` into `cairoon_mesh_pattern.c` and
  `cairoon_raster_source_pattern.c`, leaving `cairoon_pattern.c` as the
  283-line base/surface/solid/gradient state glue file. This did not change
  public API or test count.
  The later raster-source callback C glue split slice moved retained callback
  state, acquired-surface owner tracking, Cairo acquire/release trampolines,
  and the owner-count test probe from the 417-line
  `cairoon_raster_source_pattern.c` into
  `cairoon_raster_source_callbacks.c`, leaving
  `cairoon_raster_source_pattern.c` as the 125-line public raster-source
  constructor/callback-accessor export file. This did not change public API or
  test count.
  The later Pattern wrapper split slice moved gradient, mesh, and raster-source
  public wrapper methods from the 514-line `pattern.mbt` into
  `pattern_gradient.mbt`, `pattern_mesh.mbt`, and
  `pattern_raster_source.mbt`, leaving `pattern.mbt` as the 136-line
  solid/surface/common-state wrapper file. This did not change public API or
  test count.
  The later Pattern black-box test split slice moved the raster-source
  callback/lifetime/error tests from the 682-line `pattern_test.mbt` into
  `pattern_raster_source_test.mbt`, leaving `pattern_test.mbt` focused on
  solid/surface/common-state behavior. This did not change public API or test
  count.
  The later raster-source black-box test split slice moved deterministic
  callback fuzz and callback getter/state tests from the 515-line
  `pattern_raster_source_test.mbt` into
  `pattern_raster_source_fuzz_test.mbt` and
  `pattern_raster_source_state_test.mbt`, leaving
  `pattern_raster_source_test.mbt` as the 246-line core raster-source
  render/error/lifetime test file. This did not change public API or test
  count.
  The later Font C glue split slice moved font-options, toy-font-face,
  scaled-font, and scaled-font oracle stubs from the 772-line
  `cairoon_font.c` into `cairoon_font_options.c`,
  `cairoon_font_face.c`, `cairoon_scaled_font.c`, and
  `cairoon_scaled_font_oracle.c`. This did not change public API or test
  count.
  The later test-vector C glue split slice moved shared vector scene ids and
  prototypes into `cairoon_test_vector_private.h`, common vector scene drawing
  into `cairoon_test_vector_scenes.c`, and backend-specific feature renderers
  into `cairoon_test_pdf_vector.c`, `cairoon_test_ps_vector.c`, and
  `cairoon_test_svg_vector.c`, leaving `cairoon_test_vector.c` as the 92-line
  exported oracle entry file. This did not change public API or test count.
  The later test-vector tag scene C glue split slice moved direct-C
  URI/destination/structure tag, text-tag, mixed tag/vector, layered multi-page,
  and wide multi-page tag scene fixtures from the 452-line
  `cairoon_test_vector_scenes.c` into
  `cairoon_test_vector_tag_scenes.c`, leaving
  `cairoon_test_vector_scenes.c` as the 135-line primitive scene dispatcher
  file. This did not change public API or test count.
  The later layered multi-page vector/tag oracle slice added scene 27, a
  three-page PDF/PS/SVG direct C oracle combining clip, dash, surface pattern,
  mask surface, URI link tags, Document/Sect/P structure tags, and toy-font
  text. It also added PDF combined marker assertions and PS/SVG negative
  PDF-metadata marker assertions for that scene. This raised
  `vector_output_wbtest.mbt` to 34 tests and the full native suite to 376
  tests.
  The later tagged multi-page stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for a three-page URI-link and
  Document/Sect/P text-tag scene. This raised `surface_stream_wbtest.mbt` to 2
  tests and the full native suite to 377 tests.
  The later raster-source failed-acquire owner-count fuzz slice added one
  white-box test alternating finished-surface acquire failures with successful
  callback replacements while asserting cairoon's retained owner counts return
  to zero after each paint. This raised `pattern_raster_owner_wbtest.mbt` to 4
  tests and the full native suite to 378 tests.
  The later wide multi-page vector/tag oracle slice added scene 28, a
  three-page PDF/PS/SVG direct C oracle combining URI link tags, destination
  links, named destinations, Document/Sect/P structure tags, toy-font text, and
  surface-pattern vector drawing. It also added PDF combined marker assertions
  and PS/SVG negative PDF-metadata marker assertions for that scene. This raised
  `vector_output_wbtest.mbt` to 37 tests and the full native suite to 381 tests.
  The later wide multi-page stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for the wide three-page URI/
  destination/Document/Sect/P tag/vector scene. This raised
  `surface_stream_wbtest.mbt` to 3 tests and the full native suite to 382 tests.
  The later vector stream invalid-status fallback slice expanded
  `surface_stream_test.mbt` to cover PDF/PS/SVG writer `WriteError` mapping and
  `LastStatus` callback-return normalization to `WriteError`. This raised
  `surface_stream_test.mbt` to 9 tests and the full native suite to 383 tests.
  The later PNG/script stream invalid-status fallback slice added one PNG
  writer `LastStatus` fallback test and one script stream writer `LastStatus`
  fallback test, proving the shared copied-byte writer trampoline normalizes
  invalid callback statuses to `WriteError` beyond vector surfaces. This raised
  `surface_stream_test.mbt` to 10 tests, `device_test.mbt` to 9 tests, and the
  full native suite to 385 tests.
  The later callback invocation reference-balance slice made `cairoon_stream`
  and raster-source callback glue incref C-held MoonBit arguments before
  invoking MoonBit callbacks, and made the PDF/PS/SVG, PNG, and script public
  stream writer wrappers copy C-provided chunks before invoking user writers.
  Stored stream chunks now remain valid after the callback returns. It added
  one black-box test that stores chunks across all stream writer families and
  checks them after allocation pressure. This raises `surface_stream_test.mbt`
  to 11 tests and the expected full native suite to 435 tests.
  The later mixed/layered stream equivalence slice added two
  `surface_stream_wbtest.mbt` cases proving PDF/PS/SVG stream-writer output
  matches file output after normalization for the single-page mixed
  URI/destination/Document/Sect/P vector/text scene and the layered three-page
  clip/dash/surface-pattern/mask/tag/text scene. This raised
  `surface_stream_wbtest.mbt` to 5 tests and the full native suite to 387
  tests.
  The later document-feature stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for backend-specific document
  features: PDF metadata/custom metadata/page labels/outlines/tags, PS DSC
  comments, and SVG version/document-unit output. This raised
  `surface_stream_wbtest.mbt` to 6 tests and the full native suite to 388
  tests.
  The later vector output white-box split slice moved shared marker/oracle
  helpers into `vector_output_common_wbtest.mbt`, scene rendering helpers into
  `vector_output_scenes_wbtest.mbt`, and left the 37 executable tests in
  `vector_output_wbtest.mbt`. This reduced the main vector-output test file
  from 1292 lines to 623 lines without changing public API or test count.
  The later vector output marker/oracle test split slice moved the direct C
  oracle, cross-backend tag, and late combined marker tests from the 623-line
  `vector_output_wbtest.mbt` into `vector_output_oracle_wbtest.mbt`, leaving
  `vector_output_wbtest.mbt` focused on structural output markers. This did
  not change public API or test count.
  The later vector output scene helper split slice moved pattern, surface,
  mask, mesh, and tag-heavy scene helpers from the 525-line
  `vector_output_scenes_wbtest.mbt` into
  `vector_output_pattern_scenes_wbtest.mbt` and
  `vector_output_tag_scenes_wbtest.mbt`, leaving
  `vector_output_scenes_wbtest.mbt` as the 192-line scene dispatcher and
  document-feature renderer file. This did not change public API or test
  count.
  The later lifetime stress test split moved external value-wrapper stress,
  image-data view stress, and backend stream callback stress into
  `lifetime_value_stress_test.mbt`, `lifetime_image_data_stress_test.mbt`, and
  `lifetime_stream_stress_test.mbt`, leaving `lifetime_stress_test.mbt`
  focused on mapped-image lifetime and retained owner graph stress. This did
  not change public API or test count.
  The later backend stream callback multi-seed fuzz slice added a second
  `lifetime_stream_stress_test.mbt` test with four seeds and 96 deterministic
  transitions covering PDF/PS/SVG writers, PNG writer, script writer, PNG
  reader exact and short reads, `WriteError`, invalid-status fallback, and
  reader-error paths. This raises the expected full native suite to 449 tests
  and keeps the file in the targeted normal/ASan verify gate.
  The later finalizer graph multi-seed fuzz slice added
  `lifetime_finalizer_fuzz_test.mbt` with four seeds and 160 deterministic
  transitions covering surface/context/pattern/font/path/region/mapped-image/
  raster-source/script-device owner graphs, explicit and implicit mapped-image
  cleanup edges, expected Cairo errors, callback clearing, and allocation
  pressure. This raises the expected full native suite to 450 tests and adds
  the file to the targeted normal/ASan verify gate.
  The later raster-source callback state-machine fuzz slice added
  `pattern_raster_state_wbtest.mbt` with a 72-step deterministic transition
  test covering clear, release-only, acquire-only, acquire+release, failed
  acquire, dynamic compatible-source, callback-introspection, and owner-count
  balance paths. This raised the full native suite to 393 tests and added the
  file to the targeted normal and ASan verification gate.
  The later raster-source manual callback fuzz slice added
  `pattern_raster_manual_wbtest.mbt` with three deterministic seeds over 144
  total callback transitions. It covers `raster_get_callbacks()` manual
  acquire/release calls, release-only callbacks, acquire-only callbacks,
  acquire+release callbacks, failed finished-surface acquire returns, dynamic
  compatible-source acquire returns, pixel readback, and owner-count balance
  after every transition. This raises the expected full native suite to 424
  tests and adds the file to the targeted normal and ASan verification gate.
  The later tagged `show_text_glyphs` vector-output slice added a
  cross-backend scene rendered by MoonBit from `ScaledFont::text_to_glyphs`
  output and by direct C Cairo through `cairo_scaled_font_text_to_glyphs` and
  `cairo_show_text_glyphs`, plus a PDF Link/structure marker check. This raised
  the full native suite to 395 tests and expanded the vector white-box target to
  39 tests.
  The later tagged `show_text_glyphs` stream/inert-marker slice added PS/SVG
  negative marker checks for the same scene and a PDF/PS/SVG stream-vs-file
  normalized equality test for the text-glyph tag path. This raised the full
  native suite to 397 tests, the vector white-box target to 40 tests, and the
  surface stream white-box target to 7 tests.
  The later grouped glyph/tag vector-output slice added scene 30, combining
  group-pattern painting, a linear gradient, alpha compositing, multi-page
  URI/destination/Document/Sect/P tags, and two `show_text_glyphs` calls. It
  added direct C oracle coverage, PDF structure marker checks, PS/SVG inert-tag
  negative marker checks, and PDF/PS/SVG stream-vs-file normalized equality
  coverage. This raised the full native suite to 401 tests, the vector
  white-box target to 43 tests, and the surface stream white-box target to 8
  tests.
  The later copy_page retained vector-output slice added scene 31, using
  `copy_page` to emit a first vector page while retaining its drawing state for
  a second page with additional geometry. It added PDF/PS/SVG direct C oracle
  coverage, a PDF two-page marker check, and PDF/PS/SVG stream-vs-file
  normalized equality coverage. This raised the full native suite to 404 tests,
  the vector white-box target to 45 tests, and the surface stream white-box
  target to 9 tests.
  The later Surface page primitive slice added a dedicated C oracle that calls
  `cairo_surface_copy_page`/`cairo_surface_show_page` directly and compared it
  with MoonBit `Surface::copy_page`/`Surface::show_page` output for PDF/PS/SVG.
  It also added a PDF two-page marker check and PDF/PS/SVG stream-vs-file
  normalized equality coverage for the Surface primitive path. This raised the
  full native suite to 407 tests, the vector white-box target to 47 tests, and
  the surface stream white-box target to 10 tests.
  The later Surface show-page cleared slice added a dedicated C oracle that
  calls `cairo_surface_show_page` for both pages and compared it with MoonBit
  `Surface::show_page` output for PDF/PS/SVG. It also added a PDF two-page
  marker check and PDF/PS/SVG stream-vs-file normalized equality coverage for
  the cleared-page primitive path. This raised the full native suite to 410
  tests, the vector white-box target to 49 tests, and the surface stream
  white-box target to 11 tests.
  The later glyph vector backend oracle slice added scenes 32 and 33 covering
  `glyph_path` and `show_glyphs` on PDF/PS/SVG, with direct C oracle coverage
  and stream-vs-file normalized equality. This raised the full native suite to
  412 tests, the vector white-box target to 50 tests, and the surface stream
  white-box target to 12 tests.
  The later PDF JPEG MIME direct C oracle slice added a PDF-only oracle that
  paints an image surface with JPEG MIME data and compares the complete PDF
  output against the MoonBit wrapper path. This raised the full native suite to
  413 tests and the vector white-box target to 51 tests; the surface stream
  white-box target remained at 12 tests.
  The later PDF thumbnail direct C oracle slice upgraded
  `Surface::pdf_set_thumbnail_size` from marker-only coverage to a PDF-only
  direct C oracle comparison with fixed metadata dates. This raised the full
  native suite to 414 tests and the vector white-box target to 52 tests; the
  surface stream white-box target remained at 12 tests.
  The later PDF thumbnail stream-equivalence slice added a PDF-only
  file-vs-stream output equality check for `Surface::pdf_set_thumbnail_size`.
  This raised the full native suite to 415 tests and the surface stream
  white-box target to 13 tests; the vector white-box target remained at 52
  tests.
  The later PDF JPEG MIME stream-equivalence slice added a PDF-only
  file-vs-stream output equality check for JPEG MIME payload embedding. This
  raised the full native suite to 416 tests and the surface stream white-box
  target to 14 tests; the vector white-box target remained at 52 tests.
  The later PDF text document-feature stream-equivalence slice added a
  PDF-only file-vs-stream output equality check for the combined text,
  metadata, page-label, outline, URI-link, named-destination, and structure-tag
  scene. This raised the full native suite to 417 tests and the surface stream
  white-box target to 15 tests; the vector white-box target remained at 52
  tests.
  The later non-text primitive vector stream-equivalence slice added a
  cross-backend PDF/PS/SVG file-vs-stream output equality check for all
  non-text primitive vector scenes covering paint, stroke, fill, paths,
  transforms, gradients, multi-page, clip, dash, surface-pattern, mask-surface,
  and mesh-pattern rendering. This raised the full native suite to 418 tests
  and the then-combined surface stream white-box target to 16 tests; the vector
  white-box target remained at 52 tests.
  The later single-page tag stream-equivalence slice added a separate
  `surface_stream_tag_wbtest.mbt` case proving PDF/PS/SVG file-vs-stream
  normalized equality for URI-link, named-destination, and document-structure
  rectangle/text tag scenes. This raised the full native suite to 419 tests;
  the then-combined `surface_stream_wbtest.mbt` target remained at 16 tests and
  the vector white-box target remained at 52 tests.
  The later stream-equivalence organization slice split the 17 stream
  equivalence tests across `surface_stream_wbtest.mbt` (6 base/vector tests),
  `surface_stream_backend_wbtest.mbt` (4 backend feature tests), and
  `surface_stream_tag_wbtest.mbt` (7 tag-heavy tests), with shared helpers in
  `surface_stream_helpers_wbtest.mbt`. This preserved the full native suite at
  419 tests and changed no public API.
  The later PDF page-operation document-feature differential slice added
  scene 34: a PDF-only direct C oracle, stable marker test, and file-vs-stream
  normalized equality for a `Context::copy_page` retained-page document that
  combines metadata, custom metadata, page labels, outlines, URI links, named
  destinations, document-structure tags, and retained text drawing. This
  raises the expected full native suite to 422 tests, the vector white-box
  target to 54 tests, the backend stream target to 5 tests, and the combined
  split stream-equivalence targets to 18 tests.
  The later standalone text stream-equivalence slice added a PDF/PS/SVG
  file-vs-stream normalized equality check for the toy-font `text_path` and
  `show_text` vector scenes. This raises the expected full native suite to 423
  tests, the base stream white-box target to 7 tests, and the combined split
  stream-equivalence targets to 19 tests.
  The later backend feature/tag stream-combo slice added
  `surface_stream_combo_wbtest.mbt`, a cross-backend file-vs-stream normalized
  equality test for one three-page scene combining backend document features
  (PDF metadata/page labels/outlines, PS DSC, SVG version/unit), URI and named
  destination tags, document-structure tags, surface patterns, toy text, and
  `show_text_glyphs`. A follow-up upgraded that file with a scene 35 direct C
  Cairo oracle and stable PDF/PS/SVG marker checks for the same combo scene.
  A later negative-marker slice added PS/SVG checks proving that combo tags do
  not emit PDF annotation, destination, URI, or structure-tree metadata on
  those backends. A later tagged multi-page negative-marker slice added PS/SVG
  checks proving the two-page Link/Dest/Document/Sect/P text scene stays inert
  on those backends. A later PDF rectangle tag marker slice added marker
  checks for the direct-C rectangle URI-link, named-destination, and
  Document/Sect/H1/P scenes. A later PDF text tag marker slice tightened the
  direct-C text-tag fixtures, added marker checks for the URI-link,
  named-destination, and Document/Sect/H1/P text scenes, and extended PS/SVG
  negative metadata checks to the URI-link text scene. A later PDF direct
  document-feature marker slice added stable checks for the direct-C combined
  metadata/page-label/outline/URI/destination/structure scene. A later backend
  document-feature stream marker slice added stable checks for PDF/PS/SVG
  document-feature stream output, covering PDF metadata/custom metadata/page
  labels/outlines/tags, PS DSC/page markers, and SVG document-unit/page
  markers. A later backend-combo stream inertness slice added PS/SVG stream
  checks proving that the three-page backend feature/tag scene does not emit
  PDF annotation, destination, URI, or structure-tree metadata on those stream
  backends. A later deep-structure slice broadened the same scene with a third
  PDF outline and nested Document/Sect/H1/P/Span tags while preserving the
  direct C oracle, file-vs-stream equality, marker checks, and PS/SVG inertness
  checks. This raises the expected full native suite to 435 tests and leaves
  the combined split backend/stream output targets at 25 tests. A later
  Context drawing-state enum slice added a pycairo-derived black-box test that
  round-trips every typed Antialias, FillRule, LineCap, LineJoin, and Operator
  value through the public Context setters/getters. This raises the expected
  full native suite to 436 tests and raises `context_state_test.mbt` to 7 tests.
  A later backend surface-page feature/tag combo slice added scene 36 plus
  `surface_stream_page_combo_wbtest.mbt`, covering `Surface::copy_page` and
  `Surface::show_page` across PDF/PS/SVG file-vs-stream output, direct C Cairo
  oracle output, stable backend markers, and PS/SVG negative PDF-metadata
  checks. This raises the expected full native suite to 440 tests and raises
  the combined split backend/stream output targets to 29 tests.
  A later backend nested tag/page sequence slice added scene 37 plus
  `surface_stream_nested_tag_wbtest.mbt`, covering deeper document-structure
  nesting, URI/destination links, retained-page `Surface::copy_page`,
  `Surface::show_page`, nested PDF outlines, richer metadata/custom metadata,
  page labels, PS DSC, and SVG document units across PDF/PS/SVG
  file-vs-stream output, direct C Cairo oracle output, stable backend markers,
  and PS/SVG negative PDF-metadata checks. This raises the expected full native
  suite to 444 tests and raises the combined split backend/stream output targets
  to 33 tests.
  A later resized page-sequence combo slice added scene 38 plus
  `surface_stream_page_sequence_wbtest.mbt`, covering alternating
  `Surface::copy_page`/`Surface::show_page`, PDF/PS page-size changes,
  PDF metadata/custom-metadata overwrite/removal, page labels, outline
  parent/child mixtures, URI/destination links, document-structure tags, PS
  DSC, and SVG document units across PDF/PS/SVG file-vs-stream output, direct
  C Cairo oracle output, stable backend markers, and PS/SVG negative
  PDF-metadata checks. This raises the expected full native suite to 448 tests
  and raises the combined split backend/stream output targets to 37 tests.
  A later backend tag-matrix differential slice added scene 39 plus
  `surface_stream_tag_matrix_wbtest.mbt`, crossing the deep tag-nesting
  coverage from scene 37 with the resized page-sequence and metadata
  overwrite/removal coverage from scene 38. It covers four PDF/PS/SVG pages,
  retained and cleared page operations, nested document-structure tags,
  URI/destination links, `show_text_glyphs`, PDF metadata/custom metadata,
  page labels, outline parent/child mixtures, PDF/PS page-size changes, PS
  DSC, and SVG document units across file-vs-stream output, direct C Cairo
  oracle output, stable backend markers, and PS/SVG negative PDF-metadata
  checks. This raises the expected full native suite to 454 tests and raises
  the combined split backend/stream output targets to 41 tests.
  A later backend lifecycle-matrix differential slice added scene 40 plus
  `surface_stream_lifecycle_wbtest.mbt`, extending the cross-backend direct-C
  fixtures to a five-page sequence with consecutive retained `Surface::copy_page`
  output, later cleared/fresh pages, PDF/PS page-size changes, PDF metadata
  and custom-metadata overwrite/removal, page labels, outline parent/child/
  grandchild mixtures, URI/destination links, deeper list/table/document
  structure tags, `show_text_glyphs`, PS Level 2 DSC markers, and SVG
  millimeter document units across file-vs-stream output, direct C Cairo oracle
  output, stable backend markers, and PS/SVG negative PDF-metadata checks. This
  raises the expected full native suite to 461 tests and raises the combined
  split backend/stream output targets to 45 tests.
  A later Context pycairo parity slice added
  `context_pycairo_parity_test.mbt`, covering pycairo's 42x42 default
  clip-extents fixture and zero-radius `arc`/`arc_negative` non-empty path
  behavior. It is included in the targeted normal and ASan verification gates
  and raises the expected full native suite to 456 tests.
  A later Context raw-operator parity slice added
  `Context::set_operator_raw`/`Context::get_operator_raw`, covering pycairo's
  C-int operator passthrough for `-1`, `0`, `INT_MAX`, and `INT_MIN` without
  forcing unknown values through the typed `Operator` API. It raises the
  expected full native suite to 457 tests and raises `context_state_test.mbt`
  to 8 tests.
