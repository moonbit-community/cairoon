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
| Version helpers | Done | `cairo_version`, `cairo_version_string` |
| Status and error mapping | Partial | `Status`, `CairoError`, `run_cairo`; needs all pycairo exception parity |
| Matrix | Done | Pure value equivalent with field access, transform/translate/scale/rotate/multiply/invert/component tests |
| Image surface basics | Partial | Create, similar-image create, buffer-backed create-for-data, PNG path load/save, status, finish, flush, width/height/stride/format, copied data |
| Context basics | Partial | Creation, status, save/restore, CTM transforms, drawing state, clip APIs, path primitives, source colors, paint/fill/stroke |
| Pattern basics | Partial | Solid/surface pattern constructors, source setting, RGBA, extend/filter/dither/matrix state, and referenced surface return |
| Font faces | Done | Base external object, toy constructor/getters, Context get/set/select, borrowed-return references |
| Font options | Done | External object, copy/merge/equal/hash, all portable state fields, and Surface/Context accessors |
| Scaled fonts | Partial | External object, constructor, matrices/options/font-face getters, text extents, and Context get/set |
| Docs | Partial | README smoke example and AGENTS spec exist; no full reference docs yet |
| Tests | Partial | Native and ASan test runs cover the current migrated slices only |

## Top-Level Functions

| pycairo API | cairoon status | Notes |
|---|---|---|
| `cairo_version()` | Done | Exposed as `cairo_version()` |
| `cairo_version_string()` | Done | Exposed as `cairo_version_string()` |
| `get_include()` | Decision | pycairo-specific C-extension helper; decide whether cairoon needs an equivalent |

## Enums And Constants

| pycairo enum | cairoon status | Notes |
|---|---|---|
| `Antialias` | Done | Constructors use `Antialias*` prefixes |
| `Content` | Done | Cairo bit values preserved |
| `SurfaceType` | Done | Values through Cairo 1.18.4 are listed for `Surface::get_type` |
| `FillRule` | Done | Constructors use `Fill*` prefixes |
| `Format` | Partial | Image formats and `stride_for_width`; `INVALID = -1` is not represented by the enum |
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
| `Status` | Partial | Values through Cairo 1.18.4 are listed; mapping policy needs full parity audit |
| `PDFVersion` | Done | Needed by `PDFSurface` |
| `PSLevel` | Done | Needed by `PSSurface` |
| `PathDataType` | Done | Needed by `Path` iteration |
| `RegionOverlap` | Done | Needed by `Region` |
| `SVGVersion` | Done | Needed by `SVGSurface` |
| `SVGUnit` | Done | Needed by `SVGSurface` |
| `PDFMetadata` | Done | Needed by `PDFSurface` metadata |
| `PDFOutlineFlags` | Done | Cairo bit values preserved |
| `ScriptMode` | Done | Needed by script device |
| `TextClusterFlags` | Done | Cairo bit value preserved |
| `SurfaceObserverMode` | Done | Enum exists; Tee/observer surface APIs remain a product decision |

## Value Types

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Matrix` | Done | MoonBit pure-value API returns transformed copies; `component`/`components` cover pycairo indexing/unpacking semantics |
| `Path` | Done | Opaque owned `cairo_path_t *`, status/equality/hash, stringification, segment values, and iteration |
| `Rectangle` | Done | Pure value type with field and component access |
| `RectangleInt` | Done | Pure value type with defaults; needed by region and map-to-image |
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
| `SolidPattern.__init__/get_rgba` | Partial | Exposed as `Pattern::solid_rgb/solid_rgba/get_rgba` |
| `SurfacePattern.__init__` | Partial | Exposed as `Pattern::for_surface`; retains base `Surface` wrapper |
| `SurfacePattern.get_surface` | Done | Returns a referenced `Surface` wrapper and maps non-surface patterns to `PatternTypeMismatch` |
| `Gradient.add_color_stop_*` | Done | Implemented on opaque `Pattern` |
| `Gradient.get_color_stops_rgba` | Done | Returns `Array[(Double, Double, Double, Double, Double)]` |
| `LinearGradient` | Done | Exposed as `Pattern::linear` plus `get_linear_points` |
| `RadialGradient` | Done | Exposed as `Pattern::radial` plus `get_radial_circles` |
| `MeshPattern` | Todo | Patch lifecycle methods and path extraction |
| `RasterSourcePattern` | Decision | Requires callback trampoline and retained MoonBit closures |

## Surface And Device APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `Device` | Todo | Finish/flush/acquire/release and scoped usage |
| `Surface` base methods | Partial | Finish/flush/copy_page/show_page/write_to_png(path), create_similar/create_similar_image, content/type, dirty markers, device offset/scale, fallback resolution, show-text-glyphs support query, and get_font_options exist; device/MIME/metadata/backend APIs remain |
| `ImageSurface` | Partial | Basic creation, buffer-backed creation, PNG path loading, and readback only |
| `ImageSurface.create_for_data` | Partial | Exposed as `Surface::image_for_data` for `FixedArray[Byte]`; retains the MoonBit buffer, validates size/stride, and covers zero-size buffers, but still needs differential coverage and a clean ASan/LSan gate |
| `ImageSurface.create_from_png/write_to_png` | Partial | Filename APIs exposed as `Surface::image_from_png` and `Surface::write_to_png`; stream/file-object callbacks deferred by `AGENTS.md` |
| `Surface.map_to_image/unmap_image` | Todo | Requires mapped-image payload retaining base surface |
| `PDFSurface` | Todo | File/stream output, metadata, outline, versions |
| `PSSurface` | Todo | File/stream output, DSC, EPS, levels |
| `SVGSurface` | Todo | File/stream output, version/unit |
| `RecordingSurface` | Todo | Constructor, extents, ink extents |
| `ScriptDevice` / `ScriptSurface` | Todo | File/stream output and recording replay |
| `TeeSurface` | Decision | Depends on Cairo backend availability and subtype policy |
| `Win32Surface` / `Win32PrintingSurface` | Decision | Platform-specific; cannot be validated on this macOS workspace |
| `XCBSurface` / `XlibSurface` | Decision | Platform-specific; requires X11/XCB headers and test environment |

## Context APIs

| pycairo area | cairoon status | Notes |
|---|---|---|
| Construction and target lifetime | Partial | `Context::new(Surface)` retains target surface; `get_target` returns a referenced `Surface` wrapper |
| Save/restore/status | Partial | Basic behavior and invalid-restore error test exist |
| Paths | Done | move/rel-move/line/rel-line/curve/rel-curve/rectangle/arc/arc-negative, close/new path, current-point queries, and path data copying |
| Painting | Done | `paint`, `paint_with_alpha`, `fill`, `fill_preserve`, `stroke`, `stroke_preserve`, `mask`, and `mask_surface` |
| Sources | Partial | solid colors, explicit `Pattern`, and `get_source` borrowed-return wrapper |
| Transformations | Done | scale, translate, rotate, transform, user/device coordinate conversions |
| Clip APIs | Done | `clip`, `clip_preserve`, `reset_clip`, `clip_extents`, `in_clip`, and `copy_clip_rectangle_list` |
| Stroke/fill state | Done | line width/cap/join, miter limit, fill rule, tolerance, operator, antialias, dash |
| Matrix APIs | Done | get/set/identity/translate/rotate/transform and user/device coordinate conversions |
| Groups | Todo | push/pop group and group target |
| Text and fonts | Partial | font options get/set, font face get/set/select, toy font, font matrix/size/extents, and scaled font basics exist; glyph arrays and Context text APIs remain |
| Path copy/append | Done | `copy_path`, `copy_path_flat`, `append_path`, `Path::segments`, `Path::iter`, and `Path::to_string` |
| Hit testing and extents | Done | `in_clip`, `in_fill`, `in_stroke`, `clip_extents`, `fill_extents`, `stroke_extents`, `path_extents` |
| Tags | Todo | tag begin/end with UTF-8 attributes |
| Page APIs | Done | `copy_page` and `show_page` on `Context` |

## Font And Text APIs

| pycairo API | cairoon status | Notes |
|---|---|---|
| `FontFace` | Done | External object with finalizer, status, pointer equality/hash, and Context get/set |
| `ToyFontFace` | Done | Exposed as `FontFace::toy` plus family/slant/weight accessors on `FontFace` |
| `FontOptions` | Done | External object, copy/merge/equal/hash, variations, color mode/palette/custom colors, antialias, subpixel, hint style, hint metrics |
| `ScaledFont` | Partial | Constructor, status, equality/hash, extents, font face/options, font matrix, ctm, scale matrix, and text extents implemented; glyph extents and text-to-glyphs remain |
| `Glyph` arrays | Todo | `Glyph` value type exists; sequence marshaling still needed |
| `TextCluster` arrays | Todo | `TextCluster` value type exists; sequence marshaling still needed |
| UTF-8 text input | Partial | Toy font family, context font-family inputs, and `ScaledFont::text_extents` encode to UTF-8 and reject embedded NUL; Context text APIs remain |

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
2. Should `get_include()` or an equivalent C embedding header be part of the
   MoonBit product, or is that pycairo C-extension compatibility surface out of
   scope?
3. Should optional `TeeSurface`/observer APIs be part of the portable first
   product when Cairo was compiled with tee support, or should they be deferred
   with other optional backends?

Resolved by `AGENTS.md`: cairoon uses opaque MoonBit owner types with
constructor methods instead of CPython-style inheritance, and filename APIs
come before callback stream APIs.

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
