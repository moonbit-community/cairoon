#!/usr/bin/env python3
"""Check that pycairo top-level APIs are assigned in API_INVENTORY.md."""

from __future__ import annotations

import ast
import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PYCAIRO_STUB = REPO_ROOT.parent / "cairo" / "__init__.pyi"
INVENTORY = REPO_ROOT / "API_INVENTORY.md"

# This is a triage map, not a method-level parity proof. Each public top-level
# pycairo class/function must have at least one inventory anchor that records
# either its cairoon implementation or an explicit product Decision.
EXPECTED_ANCHORS: dict[str, tuple[str, ...]] = {
    "Antialias": ("`Antialias`",),
    "ColorMode": ("`ColorMode`",),
    "Content": ("`Content`",),
    "Context": ("Context APIs",),
    "Device": ("`Device`",),
    "Dither": ("`Dither`",),
    "Error": ("Status and error mapping",),
    "Extend": ("`Extend`",),
    "FillRule": ("`FillRule`",),
    "Filter": ("`Filter`",),
    "FontFace": ("`FontFace`",),
    "FontOptions": ("`FontOptions`",),
    "FontSlant": ("`FontSlant`",),
    "FontWeight": ("`FontWeight`",),
    "Format": ("`Format`",),
    "Glyph": ("`Glyph`",),
    "Gradient": ("`Gradient.add_color_stop_*`",),
    "HintMetrics": ("`HintMetrics`",),
    "HintStyle": ("`HintStyle`",),
    "ImageSurface": ("`ImageSurface`",),
    "LineCap": ("`LineCap`",),
    "LineJoin": ("`LineJoin`",),
    "LinearGradient": ("`LinearGradient`",),
    "Matrix": ("`Matrix`",),
    "MeshPattern": ("`MeshPattern`",),
    "Operator": ("`Operator`",),
    "PDFMetadata": ("`PDFMetadata`",),
    "PDFOutlineFlags": ("`PDFOutlineFlags`",),
    "PDFSurface": ("`PDFSurface`",),
    "PDFVersion": ("`PDFVersion`",),
    "PSLevel": ("`PSLevel`",),
    "PSSurface": ("`PSSurface`",),
    "Path": ("`Path`",),
    "PathDataType": ("`PathDataType`",),
    "Pattern": ("Pattern APIs",),
    "RadialGradient": ("`RadialGradient`",),
    "RasterSourcePattern": ("`RasterSourcePattern`",),
    "RecordingSurface": ("`RecordingSurface`",),
    "Rectangle": ("`Rectangle`",),
    "RectangleInt": ("`RectangleInt`",),
    "Region": ("`Region`",),
    "RegionOverlap": ("`RegionOverlap`",),
    "SVGSurface": ("`SVGSurface`",),
    "SVGUnit": ("`SVGUnit`",),
    "SVGVersion": ("`SVGVersion`",),
    "ScaledFont": ("`ScaledFont`",),
    "ScriptDevice": ("`ScriptDevice` / `ScriptSurface`",),
    "ScriptMode": ("`ScriptMode`",),
    "ScriptSurface": ("`ScriptDevice` / `ScriptSurface`",),
    "SolidPattern": ("`SolidPattern.__init__/get_rgba`",),
    "Status": ("`Status`",),
    "SubpixelOrder": ("`SubpixelOrder`",),
    "Surface": ("`Surface` base methods",),
    "SurfaceObserverMode": ("`SurfaceObserverMode`",),
    "SurfacePattern": ("`SurfacePattern.__init__`", "`SurfacePattern.get_surface`"),
    "TeeSurface": ("`TeeSurface`",),
    "TextCluster": ("`TextCluster`",),
    "TextClusterFlags": ("`TextClusterFlags`",),
    "TextExtents": ("`TextExtents`",),
    "ToyFontFace": ("`ToyFontFace`",),
    "Win32PrintingSurface": ("`Win32Surface` / `Win32PrintingSurface`",),
    "Win32Surface": ("`Win32Surface` / `Win32PrintingSurface`",),
    "XCBSurface": ("`XCBSurface` / `XlibSurface`",),
    "XlibSurface": ("`XCBSurface` / `XlibSurface`",),
    "cairo_version": ("`cairo_version()`",),
    "cairo_version_string": ("`cairo_version_string()`",),
    "get_include": ("`get_include()`",),
}


def public_top_level_names(stub_path: pathlib.Path) -> set[str]:
    module = ast.parse(stub_path.read_text(encoding="utf-8"))
    names = set()
    for node in module.body:
        if isinstance(node, (ast.ClassDef, ast.FunctionDef)) and not node.name.startswith("_"):
            names.add(node.name)
    return names


def main() -> int:
    stub_names = public_top_level_names(PYCAIRO_STUB)
    expected_names = set(EXPECTED_ANCHORS)
    inventory = INVENTORY.read_text(encoding="utf-8")

    errors: list[str] = []
    for name in sorted(stub_names - expected_names):
        errors.append(f"{PYCAIRO_STUB}: public API '{name}' has no inventory mapping")
    for name in sorted(expected_names - stub_names):
        errors.append(f"{INVENTORY}: inventory mapping for '{name}' is no longer in pycairo stub")
    for name in sorted(stub_names & expected_names):
        for anchor in EXPECTED_ANCHORS[name]:
            if anchor not in inventory:
                errors.append(
                    f"{INVENTORY}: anchor {anchor!r} for pycairo API '{name}' is missing"
                )

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(f"API inventory covers {len(stub_names)} pycairo top-level entries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
