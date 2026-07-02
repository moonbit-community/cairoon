///|
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
pub(all) enum Content {
  ContentColor = 0x1000
  ContentAlpha = 0x2000
  ContentColorAlpha = 0x3000
} derive(Eq, Debug)

///|
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
pub(all) enum FillRule {
  FillWinding = 0
  FillEvenOdd = 1
} derive(Eq, Debug)

///|
pub(all) enum HintMetrics {
  HintMetricsDefault = 0
  HintMetricsOff = 1
  HintMetricsOn = 2
} derive(Eq, Debug)

///|
pub(all) enum ColorMode {
  ColorModeDefault = 0
  ColorModeNoColor = 1
  ColorModeColor = 2
} derive(Eq, Debug)

///|
pub(all) enum Dither {
  DitherNone = 0
  DitherDefault = 1
  DitherFast = 2
  DitherGood = 3
  DitherBest = 4
} derive(Eq, Debug)

///|
pub(all) enum HintStyle {
  HintStyleDefault = 0
  HintStyleNone = 1
  HintStyleSlight = 2
  HintStyleMedium = 3
  HintStyleFull = 4
} derive(Eq, Debug)

///|
pub(all) enum SubpixelOrder {
  SubpixelDefault = 0
  SubpixelRgb = 1
  SubpixelBgr = 2
  SubpixelVrgb = 3
  SubpixelVbgr = 4
} derive(Eq, Debug)

///|
pub(all) enum LineCap {
  LineCapButt = 0
  LineCapRound = 1
  LineCapSquare = 2
} derive(Eq, Debug)

///|
pub(all) enum LineJoin {
  LineJoinMiter = 0
  LineJoinRound = 1
  LineJoinBevel = 2
} derive(Eq, Debug)

///|
pub(all) enum Filter {
  Fast = 0
  Good = 1
  Best = 2
  Nearest = 3
  Bilinear = 4
  Gaussian = 5
} derive(Eq, Debug)

///|
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
pub(all) enum Extend {
  ExtendNone = 0
  Repeat = 1
  Reflect = 2
  Pad = 3
} derive(Eq, Debug)

///|
pub(all) enum FontSlant {
  FontSlantNormal = 0
  FontSlantItalic = 1
  FontSlantOblique = 2
} derive(Eq, Debug)

///|
pub(all) enum FontWeight {
  FontWeightNormal = 0
  FontWeightBold = 1
} derive(Eq, Debug)

///|
pub(all) enum PDFVersion {
  PdfVersion1_4 = 0
  PdfVersion1_5 = 1
  PdfVersion1_6 = 2
  PdfVersion1_7 = 3
} derive(Eq, Debug)

///|
pub(all) enum PSLevel {
  PsLevel2 = 0
  PsLevel3 = 1
} derive(Eq, Debug)

///|
pub(all) enum PathDataType {
  PathMoveTo = 0
  PathLineTo = 1
  PathCurveTo = 2
  PathClosePath = 3
} derive(Eq, Debug)

///|
pub(all) enum RegionOverlap {
  RegionOverlapIn = 0
  RegionOverlapOut = 1
  RegionOverlapPart = 2
} derive(Eq, Debug)

///|
pub(all) enum SVGVersion {
  SvgVersion1_1 = 0
  SvgVersion1_2 = 1
} derive(Eq, Debug)

///|
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
pub(all) enum PDFOutlineFlags {
  PdfOutlineOpen = 0x1
  PdfOutlineBold = 0x2
  PdfOutlineItalic = 0x4
} derive(Eq, Debug)

///|
pub(all) enum ScriptMode {
  ScriptModeAscii = 0
  ScriptModeBinary = 1
} derive(Eq, Debug)

///|
pub(all) enum TextClusterFlags {
  TextClusterBackward = 0x00000001
} derive(Eq, Debug)

///|
pub(all) enum SurfaceObserverMode {
  SurfaceObserverNormal = 0
  SurfaceObserverRecordOperations = 0x1
} derive(Eq, Debug)
