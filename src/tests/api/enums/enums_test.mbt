///|
test "portable enum constructors expose cairo names" {
  let antialias : @cairoon.Antialias = @cairoon.AntialiasDefault
  let content : @cairoon.Content = @cairoon.ContentColorAlpha
  let surface_type : @cairoon.SurfaceType = @cairoon.SurfaceTypeImage
  let device_type : @cairoon.DeviceType = @cairoon.DeviceTypeScript
  let fill : @cairoon.FillRule = @cairoon.FillEvenOdd
  let filter : @cairoon.Filter = @cairoon.Bilinear
  let hint_metrics : @cairoon.HintMetrics = @cairoon.HintMetricsOn
  let color_mode : @cairoon.ColorMode = @cairoon.ColorModeColor
  let dither : @cairoon.Dither = @cairoon.DitherBest
  let hint_style : @cairoon.HintStyle = @cairoon.HintStyleFull
  let subpixel : @cairoon.SubpixelOrder = @cairoon.SubpixelVbgr
  let line_cap : @cairoon.LineCap = @cairoon.LineCapSquare
  let line_join : @cairoon.LineJoin = @cairoon.LineJoinBevel
  let operator : @cairoon.Operator = @cairoon.OperatorHslLuminosity
  let extend_mode : @cairoon.Extend = @cairoon.ExtendNone
  let font_slant : @cairoon.FontSlant = @cairoon.FontSlantOblique
  let font_weight : @cairoon.FontWeight = @cairoon.FontWeightBold
  let pdf_version : @cairoon.PDFVersion = @cairoon.PdfVersion1_7
  let ps_level : @cairoon.PSLevel = @cairoon.PsLevel3
  let path_data : @cairoon.PathDataType = @cairoon.PathClosePath
  let overlap : @cairoon.RegionOverlap = @cairoon.RegionOverlapPart
  let svg_version : @cairoon.SVGVersion = @cairoon.SvgVersion1_2
  let svg_unit : @cairoon.SVGUnit = @cairoon.SvgUnitPercent
  let metadata : @cairoon.PDFMetadata = @cairoon.PdfMetadataModDate
  let outline : @cairoon.PDFOutlineFlags = @cairoon.PdfOutlineItalic
  let script_mode : @cairoon.ScriptMode = @cairoon.ScriptModeBinary
  let cluster_flags : @cairoon.TextClusterFlags = @cairoon.TextClusterBackward
  let observer_mode : @cairoon.SurfaceObserverMode = @cairoon.SurfaceObserverRecordOperations
  debug_inspect(antialias, content="AntialiasDefault")
  debug_inspect(content, content="ContentColorAlpha")
  debug_inspect(surface_type, content="SurfaceTypeImage")
  debug_inspect(device_type, content="DeviceTypeScript")
  debug_inspect(fill, content="FillEvenOdd")
  debug_inspect(filter, content="Bilinear")
  debug_inspect(hint_metrics, content="HintMetricsOn")
  debug_inspect(color_mode, content="ColorModeColor")
  debug_inspect(dither, content="DitherBest")
  debug_inspect(hint_style, content="HintStyleFull")
  debug_inspect(subpixel, content="SubpixelVbgr")
  debug_inspect(line_cap, content="LineCapSquare")
  debug_inspect(line_join, content="LineJoinBevel")
  debug_inspect(operator, content="OperatorHslLuminosity")
  debug_inspect(extend_mode, content="ExtendNone")
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
test "pycairo enum smoke fixtures" {
  let status : @cairoon.Status = @cairoon.Jbig2GlobalMissing
  let backward : @cairoon.TextClusterFlags = @cairoon.TextClusterBackward
  let observer : @cairoon.SurfaceObserverMode = @cairoon.SurfaceObserverNormal
  inspect(status == @cairoon.Jbig2GlobalMissing, content="true")
  inspect(status.message().length() > 0, content="true")
  inspect(backward == @cairoon.TextClusterBackward, content="true")
  inspect(observer == @cairoon.SurfaceObserverNormal, content="true")
  debug_inspect(status, content="Jbig2GlobalMissing")
  debug_inspect(backward, content="TextClusterBackward")
  debug_inspect(observer, content="SurfaceObserverNormal")
}

///|
test "format stride_for_width delegates to cairo" {
  let rgb24 : @cairoon.Format = @cairoon.Rgb24
  let argb32 : @cairoon.Format = @cairoon.Argb32
  let a8 : @cairoon.Format = @cairoon.A8
  let a1 : @cairoon.Format = @cairoon.A1
  inspect(rgb24.stride_for_width(8), content="32")
  inspect(argb32.stride_for_width(8), content="32")
  inspect(a8.stride_for_width(8), content="8")
  inspect(a1.stride_for_width(8), content="4")
}

///|
test "format stride_for_width covers extended formats and invalid widths" {
  let argb32 : @cairoon.Format = @cairoon.Argb32
  let rgb16 : @cairoon.Format = @cairoon.Rgb16_565
  let rgb30 : @cairoon.Format = @cairoon.Rgb30
  let rgb96f : @cairoon.Format = @cairoon.Rgb96F
  let rgba128f : @cairoon.Format = @cairoon.Rgba128F
  inspect(rgb16.stride_for_width(2), content="4")
  inspect(rgb30.stride_for_width(2), content="8")
  inspect(rgb96f.stride_for_width(2), content="24")
  inspect(rgba128f.stride_for_width(2), content="32")
  inspect(argb32.stride_for_width(-1), content="-1")
}

///|
test "format invalid is exposed as an integer sentinel" {
  inspect(@cairoon.FORMAT_INVALID, content="-1")
}
