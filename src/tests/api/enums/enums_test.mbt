///|
fn expect_operator_raw(
  ctx : @cairoon.Context,
  operator : @cairoon.Operator,
  expected : Int,
) -> Unit raise {
  ctx.set_operator(operator)
  inspect(ctx.get_operator_raw(), content="\{expected}")
}

///|
test "portable enum constructors expose cairo names" {
  let antialias : @cairoon.Antialias = AntialiasDefault
  let content : @cairoon.Content = ContentColorAlpha
  let surface_type : @cairoon.SurfaceType = SurfaceTypeImage
  let device_type : @cairoon.DeviceType = DeviceTypeScript
  let fill : @cairoon.FillRule = FillEvenOdd
  let filter : @cairoon.Filter = Bilinear
  let hint_metrics : @cairoon.HintMetrics = HintMetricsOn
  let color_mode : @cairoon.ColorMode = ColorModeColor
  let dither : @cairoon.Dither = DitherBest
  let hint_style : @cairoon.HintStyle = HintStyleFull
  let subpixel : @cairoon.SubpixelOrder = SubpixelVbgr
  let line_cap : @cairoon.LineCap = LineCapSquare
  let line_join : @cairoon.LineJoin = LineJoinBevel
  let operator : @cairoon.Operator = OperatorHslLuminosity
  let extend_mode : @cairoon.Extend = ExtendNone
  let font_slant : @cairoon.FontSlant = FontSlantOblique
  let font_weight : @cairoon.FontWeight = FontWeightBold
  let pdf_version : @cairoon.PDFVersion = PdfVersion1_7
  let ps_level : @cairoon.PSLevel = PsLevel3
  let path_data : @cairoon.PathDataType = PathClosePath
  let overlap : @cairoon.RegionOverlap = RegionOverlapPart
  let svg_version : @cairoon.SVGVersion = SvgVersion1_2
  let svg_unit : @cairoon.SVGUnit = SvgUnitPercent
  let metadata : @cairoon.PDFMetadata = PdfMetadataModDate
  let outline : @cairoon.PDFOutlineFlags = PdfOutlineItalic
  let script_mode : @cairoon.ScriptMode = ScriptModeBinary
  let cluster_flags : @cairoon.TextClusterFlags = TextClusterBackward
  let observer_mode : @cairoon.SurfaceObserverMode = SurfaceObserverRecordOperations
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
  let status : @cairoon.Status = Jbig2GlobalMissing
  let backward : @cairoon.TextClusterFlags = TextClusterBackward
  let observer : @cairoon.SurfaceObserverMode = SurfaceObserverNormal
  inspect(status == Jbig2GlobalMissing, content="true")
  inspect(status.message().length() > 0, content="true")
  inspect(backward == TextClusterBackward, content="true")
  inspect(observer == SurfaceObserverNormal, content="true")
  debug_inspect(status, content="Jbig2GlobalMissing")
  debug_inspect(backward, content="TextClusterBackward")
  debug_inspect(observer, content="SurfaceObserverNormal")
}

///|
test "pycairo module constants raw value fixture" {
  let ctx = @cairoon.Context::new(@cairoon.Surface::image(Argb32, 1, 1))
  ctx.set_antialias(AntialiasFast)
  inspect(ctx.get_antialias_raw(), content="4")
  ctx.set_antialias(AntialiasGood)
  inspect(ctx.get_antialias_raw(), content="5")
  ctx.set_antialias(AntialiasBest)
  inspect(ctx.get_antialias_raw(), content="6")

  expect_operator_raw(ctx, OperatorMultiply, 14)
  expect_operator_raw(ctx, OperatorScreen, 15)
  expect_operator_raw(ctx, OperatorOverlay, 16)
  expect_operator_raw(ctx, OperatorDarken, 17)
  expect_operator_raw(ctx, OperatorLighten, 18)
  expect_operator_raw(ctx, OperatorColorDodge, 19)
  expect_operator_raw(ctx, OperatorColorBurn, 20)
  expect_operator_raw(ctx, OperatorHardLight, 21)
  expect_operator_raw(ctx, OperatorSoftLight, 22)
  expect_operator_raw(ctx, OperatorDifference, 23)
  expect_operator_raw(ctx, OperatorExclusion, 24)
  expect_operator_raw(ctx, OperatorHslHue, 25)
  expect_operator_raw(ctx, OperatorHslSaturation, 26)
  expect_operator_raw(ctx, OperatorHslColor, 27)
  expect_operator_raw(ctx, OperatorHslLuminosity, 28)

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=4, height=4),
  )
  let inside = @cairoon.RectangleInt::new(x=1, y=1, width=1, height=1)
  let outside = @cairoon.RectangleInt::new(x=5, y=5, width=1, height=1)
  let partial = @cairoon.RectangleInt::new(x=3, y=3, width=2, height=2)
  debug_inspect(region.contains_rectangle(inside), content="RegionOverlapIn")
  debug_inspect(region.contains_rectangle(outside), content="RegionOverlapOut")
  debug_inspect(region.contains_rectangle(partial), content="RegionOverlapPart")

  let rgb30 = @cairoon.Surface::image_raw(5, 1, 1)
  debug_inspect(rgb30.get_format(), content="Rgb30")
  inspect(rgb30.get_format_raw(), content="5")
  inspect(@cairoon.FORMAT_INVALID, content="-1")
  inspect(@cairoon.MIME_TYPE_JPEG, content="image/jpeg")
  inspect(@cairoon.SVGVersion::to_string_raw(0), content="SVG 1.1")
  inspect(@cairoon.SVGVersion::to_string_raw(1), content="SVG 1.2")
}

///|
test "format stride_for_width delegates to cairo" {
  let rgb24 : @cairoon.Format = Rgb24
  let argb32 : @cairoon.Format = Argb32
  let a8 : @cairoon.Format = A8
  let a1 : @cairoon.Format = A1
  inspect(rgb24.stride_for_width(8), content="32")
  inspect(argb32.stride_for_width(8), content="32")
  inspect(a8.stride_for_width(8), content="8")
  inspect(a1.stride_for_width(8), content="4")
}

///|
test "format stride_for_width covers extended formats and invalid widths" {
  let argb32 : @cairoon.Format = Argb32
  let rgb16 : @cairoon.Format = Rgb16_565
  let rgb30 : @cairoon.Format = Rgb30
  let rgb96f : @cairoon.Format = Rgb96F
  let rgba128f : @cairoon.Format = Rgba128F
  inspect(rgb16.stride_for_width(2), content="4")
  inspect(rgb30.stride_for_width(2), content="8")
  if @cairoon.CAIRO_VERSION >= 11702 {
    inspect(rgb96f.stride_for_width(2), content="24")
    inspect(rgba128f.stride_for_width(2), content="32")
  } else {
    inspect(rgb96f.stride_for_width(2), content="-1")
    inspect(rgba128f.stride_for_width(2), content="-1")
  }
  inspect(argb32.stride_for_width(-1), content="-1")
}

///|
test "format invalid is exposed as an integer sentinel" {
  inspect(@cairoon.FORMAT_INVALID, content="-1")
}
