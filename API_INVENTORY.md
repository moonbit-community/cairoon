# cairoon API Inventory

This file is the migration ledger for turning pycairo into a MoonBit Cairo
binding. Treat `cairo/__init__.pyi`, `docs/reference/*.rst`, and
`tests/test_*.py` in the parent pycairo repository as the source of truth.

## Legend

- Done: implemented, tested, documented, and included in `pkg.generated.mbti`.
- Partial: some API or behavior exists, but feature parity is not proven.
- Todo: no MoonBit binding yet.
- Decision: product scope or platform policy must be pinned before
  implementation.

## Current Coverage Snapshot

| Area | Status | Evidence |
|---|---|---|
| MoonBit package setup | Done | `moon.mod`, `moon.pkg`, native Cairo link flags, pycairo-style split C stubs |
| Version helpers and module constants | Done | `cairo_version`, `cairo_version_string`, `CAIRO_VERSION*`, `HAS_*`, `MIME_TYPE_*`, tag constants, `PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, and `COLOR_PALETTE_DEFAULT` |
| Status and error mapping | Done | `Status`, `CairoError`, `run_cairo`, and exhaustive status-classification tests; MoonBit intentionally splits invalid-argument statuses into `CairoInvalidArgument` |
| Matrix | Done | Pure value equivalent with field access, transform/translate/scale/rotate/multiply/invert/component tests |
| Image surface basics | Partial | Create, similar-image create, map/unmap to image, buffer-backed create-for-data, PNG path load/save, PNG stream read/write, MIME data, status, finish, flush, width/height/stride/format, copied data, mutable `ImageData` views for image and mapped-image surfaces, and one direct C Cairo oracle pixel comparison |
| Device basics | Done | External object ownership, status/type/equal/hash, finish/flush/acquire/release, scoped acquire helper, `Surface::get_device`, script file/stream devices, and script-backed tests |
| Recording surface | Done | Constructor with optional extents, extents/ink-extents queries, subtype-mismatch checks, and replay through surface patterns |
| PDF surface | Partial | Filename/no-output/stream-writer constructors, supported versions, version strings, version restriction, page size, metadata, custom metadata, page labels, thumbnails, single-flag outline compatibility, typed outline flag sets, stable structural output markers, direct C Cairo oracle comparison for a deterministic PDF 1.4 paint fixture, PDF link-tag annotation markers, and stream callback error mapping; broader normalized vector-output comparison remains |
| PS surface | Partial | Filename/no-output/stream-writer constructors, supported levels, level strings, level restriction, EPS mode, page size, DSC comments, stable page/drawing output markers, direct C Cairo oracle comparison for a simple paint fixture with `CreationDate` normalization, Link tag inertness on PS output, and stream callback output/error mapping; broader normalized vector-output comparison remains |
| SVG surface | Partial | Filename/no-output/stream-writer constructors, supported versions, version strings, version restriction, document units, stable geometry/color output markers, exact direct C Cairo oracle comparison for a simple paint fixture, Link tag inertness on SVG output, and stream callback output/error mapping; broader normalized vector-output comparison remains |
| Context basics | Partial | Creation, status, save/restore, CTM transforms, drawing state including hairline mode, clip APIs, group APIs, tag APIs, path primitives, source colors/surfaces, paint/fill/stroke |
| Pattern basics | Partial | Solid/surface/raster-source/mesh pattern constructors, source setting, RGBA, extend/filter/dither/matrix state, gradient state, raster-source acquire/get-acquire callback APIs, mesh patch lifecycle/query APIs, and referenced surface return |
| Font faces | Done | Base external object, toy constructor/getters, Context get/set/select, borrowed-return references |
| Font options | Done | External object, copy/merge/equal/hash, all portable state fields, and Surface/Context accessors |
| Scaled fonts | Partial | External object, constructor, matrices/options/font-face getters, text extents, and Context get/set |
| Docs | Partial | README smoke example and AGENTS spec exist; no full reference docs yet |
| Tests | Partial | Native and ASan test runs cover the current migrated slices only; vector backends have stable structural output marker checks plus direct C Cairo oracle comparisons for deterministic simple PDF/PS/SVG paint fixtures, PDF link tags have annotation marker checks, PS/SVG link tags have inert-output checks, PDF/PS/SVG, PNG, and script stream callbacks have output/error coverage, PNG stream reading has image round-trip and short-read coverage, image/mapped-image data has mutable-view lifetime and unmap coverage, and image painting has an initial direct C Cairo oracle comparison, but broader normalized/differential comparison remains |

## Top-Level Functions And Module Constants

| pycairo API | cairoon status | Notes |
|---|---|---|
| `cairo_version()` | Done | Exposed as `cairo_version()` |
| `cairo_version_string()` | Done | Exposed as `cairo_version_string()` |
| `CAIRO_VERSION*` constants | Done | Compile-time Cairo version constants exposed and white-box tested against C macros |
| `HAS_*` feature constants | Done | Feature flags exposed as Boolean constants and white-box tested against C macros for this native build |
| `MIME_TYPE_*` constants | Done | Cairo MIME strings exposed and white-box tested against C macros |
| `TAG_*` constants | Done | Cairo tag strings exposed and white-box tested against C macros |
| `PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, `COLOR_PALETTE_DEFAULT` | Done | Numeric constants exposed and white-box tested against C macros |
| `version`, `version_info` | Decision | Resolved out of public API scope: Cairo library version is exposed through `cairo_version*` and package version remains Moon package metadata in `moon.mod` |
| `get_include()` | Decision | Resolved out of public API scope: pycairo uses this for Python C-extension header discovery; cairoon uses `moon.pkg` native link configuration instead |

## Enums And Constants

| pycairo enum | cairoon status | Notes |
|---|---|---|
| `Antialias` | Done | Constructors use `Antialias*` prefixes |
| `Content` | Done | Cairo bit values preserved |
| `SurfaceType` | Done | Values through Cairo 1.18.4 are listed for `Surface::get_type` |
| `DeviceType` | Done | Valid non-negative values through Cairo 1.18.4 are listed for `Device::get_type`; `INVALID = -1` is not represented by the enum |
| `FillRule` | Done | Constructors use `Fill*` prefixes |
| `Format` | Done | Valid image formats are represented as non-negative enum constructors; Cairo's `CAIRO_FORMAT_INVALID = -1` is exposed separately as the integer sentinel `FORMAT_INVALID` because MoonBit enum discriminants are non-negative |
| `HintMetrics` | Done | Constructors use `HintMetrics*` prefixes |
| `ColorMode` | Done | Cairo 1.18 font color options |
| `Dither` | Done | Cairo 1.18 pattern dither enum and pattern methods |
| `HintStyle` | Done | Constructors use `HintStyle*` prefixes |
| `SubpixelOrder` | Done | Constructors use `Subpixel*` prefixes |
| `LineCap` | Done | Constructors use `LineCap*` prefixes |
| `LineJoin` | Done | Constructors use `LineJoin*` prefixes |
| `Filter` | Done | Pattern filter implemented |
| `Operator` | Done | Constructors use `Operator*` prefixes |
| `Extend` | Done | Pattern extend implemented; `ExtendNone` is used to avoid colliding with `Option::None` |
| `FontSlant` | Done | Needed by toy font APIs |
| `FontWeight` | Done | Needed by toy font APIs |
| `Status` | Done | Values through Cairo 1.18.4 are listed; exhaustive `CairoError` classification is tested |
| `PDFVersion` | Done | Needed by `PDFSurface` |
| `PSLevel` | Done | Needed by `PSSurface` |
| `PathDataType` | Done | Needed by `Path` iteration |
| `RegionOverlap` | Done | Needed by `Region` |
| `SVGVersion` | Done | Needed by `SVGSurface` |
| `SVGUnit` | Done | Needed by `SVGSurface` |
| `PDFMetadata` | Done | Needed by `PDFSurface` metadata |
| `PDFOutlineFlags`, `PDFOutlineFlagSet` | Done | Cairo bit values preserved; `PDFOutlineFlagSet` provides typed combinations for outline APIs |
| `ScriptMode` | Done | Needed by script device |
| `TextClusterFlags` | Done | Cairo bit value preserved |
| `SurfaceObserverMode` | Done | Enum exists; observer surface APIs remain a product decision |
| Tag and MIME string constants | Done | `TAG_*` and `MIME_TYPE_*` expose Cairo strings and are checked against compile-time C macros |

## Value Types

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Matrix` | Done | MoonBit pure-value API returns transformed copies; `component`/`components` cover pycairo indexing/unpacking semantics |
| `Path` | Done | Opaque owned `cairo_path_t *`, status/equality/hash, stringification, segment values, and iteration |
| `Rectangle` | Done | Pure value type with field and component access |
| `RectangleInt` | Done | Pure value type with defaults; needed by region, map-to-image, and raster-source acquire extents |
| `Glyph` | Done | Pure value type with `UInt` index; array marshaling remains separate |
| `TextCluster` | Done | Pure value type; array marshaling remains separate |
| `TextExtents` | Done | Pure value type |
| Font extents tuple | Done | Exposed as named `FontExtents` pure value per `AGENTS.md` |

## Pattern APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Pattern.get_extend/set_extend` | Done | Implemented on opaque `Pattern` |
| `Pattern.get_filter/set_filter` | Done | Implemented on opaque `Pattern` |
| `Pattern.get_matrix/set_matrix` | Done | Primitive-field stub avoids struct layout reliance |
| `Pattern.get_dither/set_dither` | Done | Cairo 1.18 feature implemented on opaque `Pattern` |
| `SolidPattern.__init__/get_rgba` | Done | Exposed as `Pattern::solid_rgb/solid_rgba/get_rgba`; tests cover alpha defaults and RGBA round-trip |
| `SurfacePattern.__init__` | Done | Exposed as `Pattern::for_surface`; retains base `Surface` wrapper and is covered by paint/readback and lifetime tests |
| `SurfacePattern.get_surface` | Done | Returns a referenced `Surface` wrapper and maps non-surface patterns to `PatternTypeMismatch` |
| `Gradient.add_color_stop_*` | Done | Implemented on opaque `Pattern` |
| `Gradient.get_color_stops_rgba` | Done | Returns `Array[(Double, Double, Double, Double, Double)]` |
| `LinearGradient` | Done | Exposed as `Pattern::linear` plus `get_linear_points` |
| `RadialGradient` | Done | Exposed as `Pattern::radial` plus `get_radial_circles` |
| `MeshPattern` | Done | Exposed as `Pattern::mesh` and `Pattern::mesh_*` methods for patch lifecycle, move/line/curve commands, control points, corner colors, patch count, path extraction, and query helpers; tests cover pycairo examples, invalid indexes, lifecycle errors, non-mesh mismatch, and painting smoke |
| `RasterSourcePattern` | Partial | Exposed as `Pattern::raster_source`, `raster_set_acquire`, `raster_get_acquire`, and `raster_clear_acquire`; C callback trampolines retain MoonBit closures and acquired surface wrappers, and tests cover paint output, release callbacks, get-acquire callback identity/optional/clear behavior, data-backed source lifetime, retained-owner stress, and subtype mismatch. Broader finalizer/edge coverage and differential rendering remain. |

## Surface And Device APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Device` | Done | Exposed as opaque `Device` with script constructor, status/type/equal/hash, finish/flush/acquire/release, and `with_acquired`; tests cover pycairo device reference/equality behavior and `DeviceFinished` after finish |
| `Surface` base methods | Partial | Finish/flush/copy_page/show_page/write_to_png(path/stream), create_similar/create_similar_image/create_for_rectangle, content/type, get_device, dirty markers, device offset/scale, fallback resolution, show-text-glyphs support query, MIME data, and get_font_options exist; metadata/backend APIs remain. `create_for_rectangle` retains its parent wrapper and is covered through parent-surface clipping/translation rather than backend-dependent surface type. |
| `ImageSurface` | Partial | Basic creation, buffer-backed creation, PNG path/stream loading, copied readback, and retained mutable `ImageData` view |
| `ImageSurface.create_for_data` | Partial | Exposed as `Surface::image_for_data` for `FixedArray[Byte]`; retains the MoonBit buffer, validates size/stride, covers zero-size buffers, and shares storage with `ImageData`, but still needs broader differential coverage and a clean ASan/LSan gate |
| `ImageSurface.create_from_png/write_to_png` | Partial | Filename APIs exposed as `Surface::image_from_png` and `Surface::write_to_png`; PNG stream APIs are exposed as `Surface::image_from_png_stream` and `Surface::write_to_png_stream`. Writers use copied-byte callbacks and map `WriteError`; readers require exact-length chunks and map short/null reads to `ReadError`/`PngError`. File-object callbacks remain deferred by `AGENTS.md` |
| `Surface.map_to_image/unmap_image` | Partial | `MappedImageSurface` has a dedicated payload retaining the base `Surface`, explicit and finalizer unmap support, extent mapping, Context construction, mutable `ImageData` view with post-unmap `SurfaceFinished` checks, double/wrong-base checks, and retained-owner stress. Clean ASan/LSan remains blocked by the macOS font/text leak report. |
| `Surface.get_mime_data/set_mime_data/supports_mime_type` | Partial | Exposed on `Surface`; data is copied into C-owned storage on set and copied back into MoonBit `Bytes` on get. This intentionally does not preserve pycairo's Python object identity for data set through the binding. Backend-specific support/output behavior still needs differential vector-output tests. |
| `PDFSurface` | Partial | Exposed as `Surface::pdf`, `Surface::pdf_stream`, `PDFVersion::supported`, `PDFVersion::to_string`, `Surface::pdf_restrict_to_version`, size, metadata, custom metadata, page label, thumbnail, single-flag outline compatibility, and typed outline flag sets. Filename/no-output/stream constructors, PDF structural markers, direct C oracle comparison for a deterministic PDF 1.4 paint fixture, PDF 1.4 link-tag annotation markers, and stream `WriteError` mapping are covered; broader normalized/differential PDF output tests remain. |
| `PSSurface` | Partial | Exposed as `Surface::ps`, `Surface::ps_stream`, `PSLevel::supported`, `PSLevel::to_string`, `Surface::ps_restrict_to_level`, EPS get/set, size, and DSC helpers. Filename/no-output/stream constructors plus PS page/drawing markers, direct C oracle comparison for a simple paint fixture with `CreationDate` normalization, Link tag inertness checks, and stream `WriteError` mapping are covered; broader normalized/differential PS output tests remain. |
| `SVGSurface` | Partial | Exposed as `Surface::svg`, `Surface::svg_stream`, `SVGVersion::supported`, `SVGVersion::to_string`, `Surface::svg_restrict_to_version`, and document-unit get/set. Filename/no-output/stream constructors plus SVG geometry/color markers, exact direct C oracle comparison for a simple paint fixture, Link tag inertness checks, and stream output tests are covered; broader normalized/differential SVG output tests remain. |
| `RecordingSurface` | Done | Exposed as `Surface::recording`, `Surface::recording_get_extents`, and `Surface::recording_ink_extents`; tests cover bounded/unbounded extents, replay through `Pattern::for_surface`, and `SurfaceTypeMismatch` for non-recording surfaces |
| `ScriptDevice` / `ScriptSurface` | Partial | File-path and stream `Device::script` constructors exist as `Device::script` and `Device::script_stream`; mode, comments, recording replay, `Surface::script`, and `Surface::script_for_target` exist; stream output/error callbacks are covered, while file-object callbacks remain deferred by `AGENTS.md` |
| `TeeSurface` | Done | Exposed as `Surface::tee`, `Surface::tee_add`, `Surface::tee_remove`, and `Surface::tee_index`; tests cover mirrored drawing, index wrappers, subtype errors, negative index handling, and retained primary/target wrappers on this `HAS_TEE_SURFACE` build |
| `Win32Surface` / `Win32PrintingSurface` | Decision | Platform-specific; cannot be validated on this macOS workspace |
| `XCBSurface` / `XlibSurface` | Decision | Platform-specific; requires X11/XCB headers and test environment |

## Context APIs

| pycairo area | cairoon status | Notes |
|---|---|---|
| Construction and target lifetime | Partial | `Context::new(Surface)` retains target surface; `Context::new_for_mapped_image(MappedImageSurface)` retains mapped image wrappers; `get_target` and `get_group_target` return referenced `Surface` wrappers that retain the context target wrapper when needed. Stress + ASan caught and fixed a mapped-image returned-target use-after-free; clean ASan/LSan remains blocked by the macOS font/text leak report. |
| Save/restore/status | Done | Save/restore state behavior, initial `Success` status, sticky `InvalidRestore` status, and error mapping are tested |
| Paths | Done | move/rel-move/line/rel-line/curve/rel-curve/rectangle/arc/arc-negative, close/new path, current-point queries, and path data copying |
| Painting | Done | `paint`, `paint_with_alpha`, `fill`, `fill_preserve`, `stroke`, `stroke_preserve`, `mask`, and `mask_surface` |
| Sources | Partial | solid colors, explicit `Pattern`, `set_source_surface`, and `get_source` borrowed-return wrapper; tests cover source-surface pixel sampling, invalid context errors, and source surface lifetime after the original wrapper scope exits |
| Transformations | Done | scale, translate, rotate, transform, user/device coordinate conversions |
| Clip APIs | Done | `clip`, `clip_preserve`, `reset_clip`, `clip_extents`, `in_clip`, and `copy_clip_rectangle_list` |
| Stroke/fill state | Done | line width/cap/join, miter limit, fill rule, tolerance, operator, antialias, dash, hairline mode |
| Matrix APIs | Done | get/set/identity/translate/rotate/transform and user/device coordinate conversions |
| Groups | Done | `push_group`, `push_group_with_content`, `pop_group`, `pop_group_to_source`, and `get_group_target` with pixel and unmatched-pop tests |
| Text and fonts | Partial | font options get/set, font face get/set/select, toy font, font matrix/size/extents, toy text APIs, glyph arrays, `text_to_glyphs`, and `show_text_glyphs` exist; PDF link-tag text output has marker coverage, while broader tag-aware vector-output coverage remains |
| Path copy/append | Done | `copy_path`, `copy_path_flat`, `append_path`, `Path::segments`, `Path::iter`, and `Path::to_string` |
| Hit testing and extents | Done | `in_clip`, `in_fill`, `in_stroke`, `clip_extents`, `fill_extents`, `stroke_extents`, `path_extents` |
| Tags | Partial | `tag_begin`/`tag_end` exist with UTF-8/NUL validation, tag constants, context-error propagation tests, unmatched/mismatched nesting `TagError` coverage, PDF 1.4 link-tag annotation marker coverage, and PS/SVG Link tag inertness checks; broader tag-aware normalized vector-output assertions remain |
| Page APIs | Done | `copy_page` and `show_page` on `Context` |

## Font And Text APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `FontFace` | Done | External object with finalizer, status, pointer equality/hash, and Context get/set |
| `ToyFontFace` | Done | Exposed as `FontFace::toy` plus family/slant/weight accessors on `FontFace` |
| `FontOptions` | Done | External object, copy/merge/equal/hash, variations, color mode/palette/custom colors, antialias, subpixel, hint style, hint metrics |
| `ScaledFont` | Partial | Constructor, status, equality/hash, extents, font face/options, font matrix, ctm, scale matrix, text extents, glyph extents, and text-to-glyphs implemented; differential coverage and clean ASan remain |
| `Glyph` arrays | Done | `ArrayView[Glyph]` marshaling exists for `Context::glyph_extents`, `Context::glyph_path`, `Context::show_glyphs`, `Context::show_text_glyphs`, `ScaledFont::glyph_extents`, and `ScaledFont::text_to_glyphs` output |
| `TextCluster` arrays | Done | `ArrayView[TextCluster]` marshaling exists for `Context::show_text_glyphs`; `ScaledFont::text_to_glyphs` returns copied `TextCluster` values |
| UTF-8 text input | Partial | Toy font family, context font-family inputs, `Context::show_text/text_extents/text_path/show_text_glyphs`, and `ScaledFont::text_extents/text_to_glyphs` encode to UTF-8 and reject embedded NUL |

## Region APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Region` | Done | External object, empty/single/multi-rectangle constructors, copy, extents, rectangle access, predicates, equality, and translate |
| Region boolean ops | Done | intersect/subtract/union/xor implemented for region and rectangle operands |
| `RegionOverlap` | Done | Enum implemented |

## Product Decisions Required

These are not safe to guess if the goal is a full product.

1. Should cairoon include platform-specific pycairo APIs (`Win32Surface`,
   `XCBSurface`, `XlibSurface`) behind conditional builds, or should the first
   full product target only portable Cairo backends?
2. Should observer APIs be part of the portable first product when Cairo was
   compiled with observer support, or should they be deferred with other
   optional backends?

Resolved by `AGENTS.md`: cairoon uses opaque MoonBit owner types with
constructor methods instead of CPython-style inheritance, and filename APIs
come before callback stream APIs.
Resolved here: pycairo's `version`, `version_info`, and `get_include()`
packaging/C-extension helpers are out of cairoon's public runtime API.

## Reliability Gates

Detailed execution rules live in `TESTING.md`.

- Every row above must move to Done or an explicit documented Decision before a
  full-product claim.
- Each Done row must have black-box MoonBit tests and, where rendering is
  involved, deterministic pixel or vector-output assertions.
- Rendering APIs must gain differential tests against pycairo or Cairo C
  golden output before being called complete.
- Every C-owned object must have an ASan/LSan run that exercises construction,
  normal use, error paths, and finalization.
- Public API changes must regenerate and review `pkg.generated.mbti`.
