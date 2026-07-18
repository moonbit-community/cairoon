///|
test "svg 1.1 restriction crosses the typed boundary" {
  inspect(@cairoon.SvgVersion1_1.to_string(), content="SVG 1.1")
  let surface = @cairoon.Surface::svg(10.0, 10.0)
  surface.svg_restrict_to_version(SvgVersion1_1)
  surface.finish()
}

///|
test "svg document units round trip through cairo" {
  let surface = @cairoon.Surface::svg(10.0, 10.0)
  let units : Array[@cairoon.SVGUnit] = [
    SvgUnitUser,
    SvgUnitEm,
    SvgUnitEx,
    SvgUnitPx,
    SvgUnitIn,
    SvgUnitCm,
    SvgUnitMm,
    SvgUnitPt,
    SvgUnitPc,
    SvgUnitPercent,
  ]
  for unit in units {
    surface.svg_set_document_unit(unit)
    inspect(surface.svg_get_document_unit() == unit, content="true")
  }
  surface.finish()
}
