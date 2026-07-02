///|
test "portable enum constructors expose cairo names" {
  let antialias : Antialias = AntialiasDefault
  let content : Content = ContentColorAlpha
  let surface_type : SurfaceType = SurfaceTypeImage
  let device_type : DeviceType = DeviceTypeScript
  let fill : FillRule = FillEvenOdd
  let hint_metrics : HintMetrics = HintMetricsOn
  let color_mode : ColorMode = ColorModeColor
  let dither : Dither = DitherBest
  let hint_style : HintStyle = HintStyleFull
  let subpixel : SubpixelOrder = SubpixelVbgr
  let line_cap : LineCap = LineCapSquare
  let line_join : LineJoin = LineJoinBevel
  let operator : Operator = OperatorHslLuminosity
  let font_slant : FontSlant = FontSlantOblique
  let font_weight : FontWeight = FontWeightBold
  let pdf_version : PDFVersion = PdfVersion1_7
  let ps_level : PSLevel = PsLevel3
  let path_data : PathDataType = PathClosePath
  let overlap : RegionOverlap = RegionOverlapPart
  let svg_version : SVGVersion = SvgVersion1_2
  let svg_unit : SVGUnit = SvgUnitPercent
  let metadata : PDFMetadata = PdfMetadataModDate
  let outline : PDFOutlineFlags = PdfOutlineItalic
  let script_mode : ScriptMode = ScriptModeBinary
  let cluster_flags : TextClusterFlags = TextClusterBackward
  let observer_mode : SurfaceObserverMode = SurfaceObserverRecordOperations
  debug_inspect(antialias, content="AntialiasDefault")
  debug_inspect(content, content="ContentColorAlpha")
  debug_inspect(surface_type, content="SurfaceTypeImage")
  debug_inspect(device_type, content="DeviceTypeScript")
  debug_inspect(fill, content="FillEvenOdd")
  debug_inspect(hint_metrics, content="HintMetricsOn")
  debug_inspect(color_mode, content="ColorModeColor")
  debug_inspect(dither, content="DitherBest")
  debug_inspect(hint_style, content="HintStyleFull")
  debug_inspect(subpixel, content="SubpixelVbgr")
  debug_inspect(line_cap, content="LineCapSquare")
  debug_inspect(line_join, content="LineJoinBevel")
  debug_inspect(operator, content="OperatorHslLuminosity")
  debug_inspect(font_slant, content="FontSlantOblique")
  debug_inspect(font_weight, content="FontWeightBold")
  debug_inspect(pdf_version, content="PdfVersion1_7")
  debug_inspect(ps_level, content="PsLevel3")
  debug_inspect(path_data, content="PathClosePath")
  debug_inspect(overlap, content="RegionOverlapPart")
  debug_inspect(svg_version, content="SvgVersion1_2")
  debug_inspect(svg_unit, content="SvgUnitPercent")
  debug_inspect(metadata, content="PdfMetadataModDate")
  debug_inspect(outline, content="PdfOutlineItalic")
  debug_inspect(script_mode, content="ScriptModeBinary")
  debug_inspect(cluster_flags, content="TextClusterBackward")
  debug_inspect(observer_mode, content="SurfaceObserverRecordOperations")
}

///|
test "format stride_for_width delegates to cairo" {
  let rgb24 : Format = Rgb24
  let argb32 : Format = Argb32
  let a8 : Format = A8
  let a1 : Format = A1
  inspect(rgb24.stride_for_width(8), content="32")
  inspect(argb32.stride_for_width(8), content="32")
  inspect(a8.stride_for_width(8), content="8")
  inspect(a1.stride_for_width(8), content="4")
}
