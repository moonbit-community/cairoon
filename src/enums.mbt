///|
/// Controls how Cairo antialiases rasterized shapes and text.
pub(all) enum Antialias {
  AntialiasDefault = 0
  AntialiasNone = 1
  AntialiasGray = 2
  AntialiasSubpixel = 3
  AntialiasFast = 4
  AntialiasGood = 5
  AntialiasBest = 6
} derive(Eq, Debug)

///|
/// Describes which color and alpha channels a surface stores.
pub(all) enum Content {
  ContentColor = 0x1000
  ContentAlpha = 0x2000
  ContentColorAlpha = 0x3000
} derive(Eq, Debug)

///|
/// Identifies the backend that owns a Cairo surface.
///
/// Availability of a constructor for a backend depends on the linked Cairo
/// build; this enum can still describe surfaces returned by Cairo.
pub(all) enum SurfaceType {
  SurfaceTypeImage = 0
  SurfaceTypePdf = 1
  SurfaceTypePs = 2
  SurfaceTypeXlib = 3
  SurfaceTypeXcb = 4
  SurfaceTypeGlitz = 5
  SurfaceTypeQuartz = 6
  SurfaceTypeWin32 = 7
  SurfaceTypeBeos = 8
  SurfaceTypeDirectfb = 9
  SurfaceTypeSvg = 10
  SurfaceTypeOs2 = 11
  SurfaceTypeWin32Printing = 12
  SurfaceTypeQuartzImage = 13
  SurfaceTypeScript = 14
  SurfaceTypeQt = 15
  SurfaceTypeRecording = 16
  SurfaceTypeVg = 17
  SurfaceTypeGl = 18
  SurfaceTypeDrm = 19
  SurfaceTypeTee = 20
  SurfaceTypeXml = 21
  SurfaceTypeSkia = 22
  SurfaceTypeSubsurface = 23
  SurfaceTypeCogl = 24
} derive(Eq, Debug)

///|
/// Identifies the backend that owns a Cairo device.
pub(all) enum DeviceType {
  DeviceTypeDrm = 0
  DeviceTypeGl = 1
  DeviceTypeScript = 2
  DeviceTypeXcb = 3
  DeviceTypeXlib = 4
  DeviceTypeXml = 5
  DeviceTypeCogl = 6
  DeviceTypeWin32 = 7
} derive(Eq, Debug)

///|
/// Selects the winding or even-odd rule used to fill a path.
pub(all) enum FillRule {
  FillWinding = 0
  FillEvenOdd = 1
} derive(Eq, Debug)

///|
/// Controls whether font metrics are snapped to the device pixel grid.
pub(all) enum HintMetrics {
  HintMetricsDefault = 0
  HintMetricsOff = 1
  HintMetricsOn = 2
} derive(Eq, Debug)

///|
/// Controls whether color glyph data may be rendered.
///
/// Color-mode support requires Cairo 1.18 or newer.
pub(all) enum ColorMode {
  ColorModeDefault = 0
  ColorModeNoColor = 1
  ColorModeColor = 2
} derive(Eq, Debug)

///|
/// Selects the quality/performance tradeoff for pattern dithering.
///
/// Dither state requires Cairo 1.18 or newer.
pub(all) enum Dither {
  DitherNone = 0
  DitherDefault = 1
  DitherFast = 2
  DitherGood = 3
  DitherBest = 4
} derive(Eq, Debug)

///|
/// Selects the amount of outline adjustment used when hinting fonts.
pub(all) enum HintStyle {
  HintStyleDefault = 0
  HintStyleNone = 1
  HintStyleSlight = 2
  HintStyleMedium = 3
  HintStyleFull = 4
} derive(Eq, Debug)

///|
/// Describes the physical order of subpixels on a display.
pub(all) enum SubpixelOrder {
  SubpixelDefault = 0
  SubpixelRgb = 1
  SubpixelBgr = 2
  SubpixelVrgb = 3
  SubpixelVbgr = 4
} derive(Eq, Debug)

///|
/// Selects the shape drawn at the end of an open stroked subpath.
pub(all) enum LineCap {
  LineCapButt = 0
  LineCapRound = 1
  LineCapSquare = 2
} derive(Eq, Debug)

///|
/// Selects the shape drawn where two stroked path segments meet.
pub(all) enum LineJoin {
  LineJoinMiter = 0
  LineJoinRound = 1
  LineJoinBevel = 2
} derive(Eq, Debug)

///|
/// Selects the sampling filter used when reading from a pattern.
pub(all) enum Filter {
  Fast = 0
  Good = 1
  Best = 2
  Nearest = 3
  Bilinear = 4
  Gaussian = 5
} derive(Eq, Debug)

///|
/// Selects the Porter-Duff or blend operator used for compositing.
pub(all) enum Operator {
  OperatorClear = 0
  OperatorSource = 1
  OperatorOver = 2
  OperatorIn = 3
  OperatorOut = 4
  OperatorAtop = 5
  OperatorDest = 6
  OperatorDestOver = 7
  OperatorDestIn = 8
  OperatorDestOut = 9
  OperatorDestAtop = 10
  OperatorXor = 11
  OperatorAdd = 12
  OperatorSaturate = 13
  OperatorMultiply = 14
  OperatorScreen = 15
  OperatorOverlay = 16
  OperatorDarken = 17
  OperatorLighten = 18
  OperatorColorDodge = 19
  OperatorColorBurn = 20
  OperatorHardLight = 21
  OperatorSoftLight = 22
  OperatorDifference = 23
  OperatorExclusion = 24
  OperatorHslHue = 25
  OperatorHslSaturation = 26
  OperatorHslColor = 27
  OperatorHslLuminosity = 28
} derive(Eq, Debug)

///|
/// Controls how a pattern samples outside its natural bounds.
pub(all) enum Extend {
  ExtendNone = 0
  Repeat = 1
  Reflect = 2
  Pad = 3
} derive(Eq, Debug)

///|
/// Selects the slant requested from Cairo's toy font API.
pub(all) enum FontSlant {
  FontSlantNormal = 0
  FontSlantItalic = 1
  FontSlantOblique = 2
} derive(Eq, Debug)

///|
/// Selects the weight requested from Cairo's toy font API.
pub(all) enum FontWeight {
  FontWeightNormal = 0
  FontWeightBold = 1
} derive(Eq, Debug)

///|
/// A PDF language version supported by a Cairo PDF surface.
pub(all) enum PDFVersion {
  PdfVersion1_4 = 0
  PdfVersion1_5 = 1
  PdfVersion1_6 = 2
  PdfVersion1_7 = 3
} derive(Eq, Debug)

///|
/// A PostScript language level supported by a Cairo PS surface.
pub(all) enum PSLevel {
  PsLevel2 = 0
  PsLevel3 = 1
} derive(Eq, Debug)

///|
/// Identifies the command stored in a copied Cairo path segment.
pub(all) enum PathDataType {
  PathMoveTo = 0
  PathLineTo = 1
  PathCurveTo = 2
  PathClosePath = 3
} derive(Eq, Debug)

///|
/// Describes whether a rectangle lies inside, outside, or partly in a region.
pub(all) enum RegionOverlap {
  RegionOverlapIn = 0
  RegionOverlapOut = 1
  RegionOverlapPart = 2
} derive(Eq, Debug)

///|
/// An SVG language version supported by a Cairo SVG surface.
pub(all) enum SVGVersion {
  SvgVersion1_1 = 0
  SvgVersion1_2 = 1
} derive(Eq, Debug)

///|
/// Selects the unit used for a Cairo SVG document's width and height.
pub(all) enum SVGUnit {
  SvgUnitUser = 0
  SvgUnitEm = 1
  SvgUnitEx = 2
  SvgUnitPx = 3
  SvgUnitIn = 4
  SvgUnitCm = 5
  SvgUnitMm = 6
  SvgUnitPt = 7
  SvgUnitPc = 8
  SvgUnitPercent = 9
} derive(Eq, Debug)

///|
/// Selects a standard metadata field on a Cairo PDF surface.
pub(all) enum PDFMetadata {
  PdfMetadataTitle = 0
  PdfMetadataAuthor = 1
  PdfMetadataSubject = 2
  PdfMetadataKeywords = 3
  PdfMetadataCreator = 4
  PdfMetadataCreateDate = 5
  PdfMetadataModDate = 6
} derive(Eq, Debug)

///|
/// A single PDF outline style flag.
///
/// Pass multiple flags with the array-based outline API; raw bitsets are also
/// available for pycairo compatibility.
pub(all) enum PDFOutlineFlags {
  PdfOutlineOpen = 0x1
  PdfOutlineBold = 0x2
  PdfOutlineItalic = 0x4
} derive(Eq, Debug)

///|
/// Selects human-readable or compact binary Cairo script output.
pub(all) enum ScriptMode {
  ScriptModeAscii = 0
  ScriptModeBinary = 1
} derive(Eq, Debug)

///|
/// Describes the byte order represented by text-to-glyph clusters.
pub(all) enum TextClusterFlags {
  TextClusterNone = 0
  TextClusterBackward = 0x00000001
} derive(Eq, Debug)

///|
/// The observer-surface mode values exposed by pycairo.
///
/// Cairoon's pycairo-compatibility surface currently exposes this enum only;
/// Cairo's native observer-surface extension is outside the portable API.
pub(all) enum SurfaceObserverMode {
  SurfaceObserverNormal = 0
  SurfaceObserverRecordOperations = 0x1
} derive(Eq, Debug)
