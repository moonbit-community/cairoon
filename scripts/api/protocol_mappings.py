"""Pycairo protocol-to-cairoon evidence mappings."""

from __future__ import annotations


def method_anchor(type_name: str, method: str) -> str:
    return f"pub fn {type_name}::{method}("


PUBLIC_PROTOCOL_ANCHORS: dict[str, dict[str, tuple[str, ...]]] = {
    "Context": {
        "__init__": (method_anchor("Context", "new"),),
    },
    "Device": {
        "__enter__": ("pub fn[T] Device::with_finished(",),
    },
    "FontOptions": {
        "__init__": (method_anchor("FontOptions", "new"),),
    },
    "Glyph": {
        "__init__": (method_anchor("Glyph", "new"),),
    },
    "ImageSurface": {
        "__init__": (method_anchor("Surface", "image"),),
    },
    "LinearGradient": {
        "__init__": (method_anchor("Pattern", "linear"),),
    },
    "Matrix": {
        "__getitem__": ('#alias("_[_]")', method_anchor("Matrix", "at")),
        "__init__": (method_anchor("Matrix", "new"),),
        "__mul__": ("pub impl Mul for Matrix",),
    },
    "MeshPattern": {
        "__init__": (method_anchor("Pattern", "mesh"),),
    },
    "PDFSurface": {
        "__init__": (
            method_anchor("Surface", "pdf"),
            method_anchor("Surface", "pdf_stream"),
        ),
    },
    "PSSurface": {
        "__init__": (
            method_anchor("Surface", "ps"),
            method_anchor("Surface", "ps_stream"),
        ),
    },
    "Path": {
        "__eq__": ("pub impl Eq for Path",),
        "__ge__": ("pub impl Compare for Path",),
        "__gt__": ("pub impl Compare for Path",),
        "__iter__": (method_anchor("Path", "iter"),),
        "__le__": ("pub impl Compare for Path",),
        "__lt__": ("pub impl Compare for Path",),
        "__ne__": ("pub impl Eq for Path",),
    },
    "RadialGradient": {
        "__init__": (method_anchor("Pattern", "radial"),),
    },
    "RasterSourcePattern": {
        "__init__": (method_anchor("Pattern", "raster_source"),),
    },
    "RecordingSurface": {
        "__init__": (method_anchor("Surface", "recording"),),
    },
    "Rectangle": {
        "__init__": (method_anchor("Rectangle", "new"),),
    },
    "RectangleInt": {
        "__init__": (method_anchor("RectangleInt", "new"),),
    },
    "Region": {
        "__init__": (
            method_anchor("Region", "new"),
            method_anchor("Region", "from_rectangle"),
            method_anchor("Region", "from_rectangles"),
        ),
    },
    "SVGSurface": {
        "__init__": (
            method_anchor("Surface", "svg"),
            method_anchor("Surface", "svg_stream"),
        ),
    },
    "ScaledFont": {
        "__init__": (method_anchor("ScaledFont", "new"),),
    },
    "ScriptDevice": {
        "__init__": (
            method_anchor("Device", "script"),
            method_anchor("Device", "script_stream"),
        ),
    },
    "ScriptSurface": {
        "__init__": (
            method_anchor("Surface", "script"),
            method_anchor("Surface", "script_for_target"),
        ),
    },
    "SolidPattern": {
        "__init__": (
            method_anchor("Pattern", "solid_rgb"),
            method_anchor("Pattern", "solid_rgba"),
        ),
    },
    "Surface": {
        "__enter__": ("pub fn[T] Surface::with_finished(",),
    },
    "SurfacePattern": {
        "__init__": (method_anchor("Pattern", "for_surface"),),
    },
    "TeeSurface": {
        "__init__": (method_anchor("Surface", "tee"),),
    },
    "TextCluster": {
        "__init__": (method_anchor("TextCluster", "new"),),
    },
    "TextExtents": {
        "__init__": (method_anchor("TextExtents", "new"),),
    },
    "ToyFontFace": {
        "__init__": (method_anchor("FontFace", "toy"),),
    },
}


PROTOCOL_DECISION_ANCHORS: dict[str, dict[str, tuple[str, ...]]] = {
    "Win32PrintingSurface": {
        "__init__": (
            "| `Win32Surface` / `Win32PrintingSurface` | Decision |",
        ),
    },
    "Win32Surface": {
        "__init__": (
            "| `Win32Surface` / `Win32PrintingSurface` | Decision |",
        ),
    },
    "XCBSurface": {
        "__init__": (
            "| `XCBSurface` / `XlibSurface` | Decision |",
        ),
    },
}
