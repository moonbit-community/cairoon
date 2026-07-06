#!/usr/bin/env python3
"""Check that pycairo APIs are represented in cairoon's migration ledger."""

from __future__ import annotations

import ast
import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PYCAIRO_STUB = REPO_ROOT.parent / "cairo" / "__init__.pyi"
INVENTORY = REPO_ROOT / "API_INVENTORY.md"
GENERATED_MBTI = REPO_ROOT / "src" / "pkg.generated.mbti"

# Each public top-level pycairo class/function must have at least one inventory
# anchor recording either its cairoon implementation or an explicit product
# Decision.
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


def method_anchor(type_name: str, method: str) -> str:
    return f"pub fn {type_name}::{method}("


def direct_method_map(type_name: str, methods: tuple[str, ...]) -> dict[str, tuple[str, ...]]:
    return {method: (method_anchor(type_name, method),) for method in methods}


# Portable pycairo methods that must have public cairoon API equivalents. This
# intentionally excludes Python dunder methods and platform-native Win32/XCB/Xlib
# surface methods that are explicit product Decisions in API_INVENTORY.md.
PUBLIC_METHOD_ANCHORS: dict[str, dict[str, tuple[str, ...]]] = {
    "Format": direct_method_map("Format", ("stride_for_width",)),
    "Matrix": direct_method_map(
        "Matrix",
        (
            "init_rotate",
            "invert",
            "multiply",
            "rotate",
            "scale",
            "transform_distance",
            "transform_point",
            "translate",
        ),
    ),
    "Pattern": direct_method_map(
        "Pattern",
        (
            "get_extend",
            "get_matrix",
            "get_filter",
            "set_filter",
            "set_extend",
            "set_matrix",
            "get_dither",
            "set_dither",
        ),
    ),
    "FontOptions": direct_method_map(
        "FontOptions",
        (
            "get_antialias",
            "get_hint_style",
            "get_subpixel_order",
            "set_antialias",
            "set_hint_metrics",
            "set_hint_style",
            "merge",
            "copy",
            "hash",
            "equal",
            "set_variations",
            "get_variations",
            "get_hint_metrics",
            "set_subpixel_order",
            "set_color_mode",
            "get_color_mode",
            "set_color_palette",
            "get_color_palette",
            "set_custom_palette_color",
            "get_custom_palette_color",
        ),
    ),
    "ScaledFont": direct_method_map(
        "ScaledFont",
        (
            "extents",
            "get_ctm",
            "get_font_face",
            "get_font_matrix",
            "get_font_options",
            "get_scale_matrix",
            "glyph_extents",
            "text_extents",
            "text_to_glyphs",
        ),
    ),
    "Device": direct_method_map(
        "Device",
        ("finish", "flush", "acquire", "release"),
    ),
    "Surface": direct_method_map(
        "Surface",
        (
            "copy_page",
            "create_for_rectangle",
            "create_similar",
            "create_similar_image",
            "finish",
            "flush",
            "get_content",
            "get_device",
            "get_device_offset",
            "get_device_scale",
            "get_fallback_resolution",
            "get_font_options",
            "get_mime_data",
            "has_show_text_glyphs",
            "map_to_image",
            "mark_dirty",
            "mark_dirty_rectangle",
            "set_device_offset",
            "set_device_scale",
            "set_fallback_resolution",
            "set_mime_data",
            "show_page",
            "supports_mime_type",
            "unmap_image",
        ),
    )
    | {
        "write_to_png": (
            method_anchor("Surface", "write_to_png"),
            method_anchor("Surface", "write_to_png_stream"),
        ),
    },
    "ImageSurface": {
        "create_for_data": (method_anchor("Surface", "image_for_data"),),
        "create_from_png": (
            method_anchor("Surface", "image_from_png"),
            method_anchor("Surface", "image_from_png_stream"),
        ),
        "get_data": (method_anchor("Surface", "get_data"),),
        "get_format": (method_anchor("Surface", "get_format"),),
        "get_height": (method_anchor("Surface", "get_height"),),
        "get_stride": (method_anchor("Surface", "get_stride"),),
        "get_width": (method_anchor("Surface", "get_width"),),
    },
    "SurfacePattern": {
        "get_surface": (method_anchor("Pattern", "get_surface"),),
    },
    "Context": direct_method_map(
        "Context",
        (
            "append_path",
            "arc",
            "arc_negative",
            "clip",
            "clip_extents",
            "clip_preserve",
            "close_path",
            "copy_clip_rectangle_list",
            "copy_page",
            "copy_path",
            "copy_path_flat",
            "curve_to",
            "device_to_user",
            "device_to_user_distance",
            "fill",
            "fill_extents",
            "fill_preserve",
            "font_extents",
            "get_antialias",
            "get_current_point",
            "get_dash",
            "get_dash_count",
            "get_fill_rule",
            "get_font_face",
            "get_font_matrix",
            "get_font_options",
            "get_group_target",
            "get_hairline",
            "get_line_cap",
            "get_line_join",
            "get_line_width",
            "get_matrix",
            "get_miter_limit",
            "get_operator",
            "get_scaled_font",
            "get_source",
            "get_target",
            "get_tolerance",
            "glyph_extents",
            "glyph_path",
            "has_current_point",
            "identity_matrix",
            "in_clip",
            "in_fill",
            "in_stroke",
            "line_to",
            "mask",
            "mask_surface",
            "move_to",
            "new_path",
            "new_sub_path",
            "paint",
            "paint_with_alpha",
            "path_extents",
            "pop_group",
            "pop_group_to_source",
            "push_group",
            "push_group_with_content",
            "rectangle",
            "rel_curve_to",
            "rel_line_to",
            "rel_move_to",
            "reset_clip",
            "restore",
            "rotate",
            "save",
            "scale",
            "select_font_face",
            "set_antialias",
            "set_dash",
            "set_fill_rule",
            "set_font_face",
            "set_font_matrix",
            "set_font_options",
            "set_font_size",
            "set_hairline",
            "set_line_cap",
            "set_line_join",
            "set_line_width",
            "set_matrix",
            "set_miter_limit",
            "set_operator",
            "set_scaled_font",
            "set_source",
            "set_source_rgb",
            "set_source_rgba",
            "set_source_surface",
            "set_tolerance",
            "show_glyphs",
            "show_page",
            "show_text",
            "show_text_glyphs",
            "stroke",
            "stroke_extents",
            "stroke_preserve",
            "tag_begin",
            "tag_end",
            "text_extents",
            "text_path",
            "transform",
            "translate",
            "user_to_device",
            "user_to_device_distance",
        ),
    ),
    "Gradient": {
        "add_color_stop_rgb": (method_anchor("Pattern", "add_color_stop_rgb"),),
        "add_color_stop_rgba": (method_anchor("Pattern", "add_color_stop_rgba"),),
        "get_color_stops_rgba": (method_anchor("Pattern", "get_color_stops_rgba"),),
    },
    "LinearGradient": {
        "get_linear_points": (method_anchor("Pattern", "get_linear_points"),),
    },
    "MeshPattern": {
        "begin_patch": (method_anchor("Pattern", "mesh_begin_patch"),),
        "curve_to": (method_anchor("Pattern", "mesh_curve_to"),),
        "end_patch": (method_anchor("Pattern", "mesh_end_patch"),),
        "get_control_point": (method_anchor("Pattern", "mesh_get_control_point"),),
        "get_corner_color_rgba": (method_anchor("Pattern", "mesh_get_corner_color_rgba"),),
        "get_patch_count": (method_anchor("Pattern", "mesh_get_patch_count"),),
        "line_to": (method_anchor("Pattern", "mesh_line_to"),),
        "move_to": (method_anchor("Pattern", "mesh_move_to"),),
        "set_control_point": (method_anchor("Pattern", "mesh_set_control_point"),),
        "set_corner_color_rgb": (method_anchor("Pattern", "mesh_set_corner_color_rgb"),),
        "set_corner_color_rgba": (method_anchor("Pattern", "mesh_set_corner_color_rgba"),),
        "get_path": (method_anchor("Pattern", "mesh_get_path"),),
    },
    "PDFSurface": {
        "set_custom_metadata": (method_anchor("Surface", "pdf_set_custom_metadata"),),
        "set_size": (method_anchor("Surface", "pdf_set_size"),),
        "restrict_to_version": (method_anchor("Surface", "pdf_restrict_to_version"),),
        "get_versions": (method_anchor("PDFVersion", "supported"),),
        "version_to_string": (method_anchor("PDFVersion", "to_string"),),
        "add_outline": (
            method_anchor("Surface", "pdf_add_outline"),
            method_anchor("Surface", "pdf_add_outline_with_flags"),
        ),
        "set_metadata": (method_anchor("Surface", "pdf_set_metadata"),),
        "set_page_label": (method_anchor("Surface", "pdf_set_page_label"),),
        "set_thumbnail_size": (method_anchor("Surface", "pdf_set_thumbnail_size"),),
    },
    "PSSurface": {
        "dsc_begin_page_setup": (method_anchor("Surface", "ps_dsc_begin_page_setup"),),
        "dsc_begin_setup": (method_anchor("Surface", "ps_dsc_begin_setup"),),
        "dsc_comment": (method_anchor("Surface", "ps_dsc_comment"),),
        "get_eps": (method_anchor("Surface", "ps_get_eps"),),
        "level_to_string": (method_anchor("PSLevel", "to_string"),),
        "restrict_to_level": (method_anchor("Surface", "ps_restrict_to_level"),),
        "set_eps": (method_anchor("Surface", "ps_set_eps"),),
        "set_size": (method_anchor("Surface", "ps_set_size"),),
        "get_levels": (method_anchor("PSLevel", "supported"),),
    },
    "SVGSurface": {
        "restrict_to_version": (method_anchor("Surface", "svg_restrict_to_version"),),
        "get_versions": (method_anchor("SVGVersion", "supported"),),
        "version_to_string": (method_anchor("SVGVersion", "to_string"),),
        "get_document_unit": (method_anchor("Surface", "svg_get_document_unit"),),
        "set_document_unit": (method_anchor("Surface", "svg_set_document_unit"),),
    },
    "RadialGradient": {
        "get_radial_circles": (method_anchor("Pattern", "get_radial_circles"),),
    },
    "RasterSourcePattern": {
        "set_acquire": (method_anchor("Pattern", "raster_set_acquire"),),
        "get_acquire": (method_anchor("Pattern", "raster_get_acquire"),),
    },
    "RecordingSurface": {
        "ink_extents": (method_anchor("Surface", "recording_ink_extents"),),
        "get_extents": (method_anchor("Surface", "recording_get_extents"),),
    },
    "Region": direct_method_map(
        "Region",
        (
            "copy",
            "get_extents",
            "num_rectangles",
            "get_rectangle",
            "is_empty",
            "contains_point",
            "contains_rectangle",
            "equal",
            "translate",
        ),
    )
    | {
        "intersect": (
            method_anchor("Region", "intersect"),
            method_anchor("Region", "intersect_rectangle"),
        ),
        "subtract": (
            method_anchor("Region", "subtract"),
            method_anchor("Region", "subtract_rectangle"),
        ),
        "union": (
            method_anchor("Region", "union"),
            method_anchor("Region", "union_rectangle"),
        ),
        "xor": (
            method_anchor("Region", "xor"),
            method_anchor("Region", "xor_rectangle"),
        ),
    },
    "ScriptDevice": {
        "set_mode": (method_anchor("Device", "script_set_mode"),),
        "get_mode": (method_anchor("Device", "script_get_mode"),),
        "write_comment": (method_anchor("Device", "script_write_comment"),),
        "from_recording_surface": (method_anchor("Device", "script_from_recording_surface"),),
    },
    "ScriptSurface": {
        "create_for_target": (method_anchor("Surface", "script_for_target"),),
    },
    "SolidPattern": {
        "get_rgba": (method_anchor("Pattern", "get_rgba"),),
    },
    "TeeSurface": {
        "add": (method_anchor("Surface", "tee_add"),),
        "remove": (method_anchor("Surface", "tee_remove"),),
        "index": (method_anchor("Surface", "tee_index"),),
    },
    "ToyFontFace": {
        "get_family": (method_anchor("FontFace", "get_family"),),
        "get_slant": (method_anchor("FontFace", "get_slant"),),
        "get_weight": (method_anchor("FontFace", "get_weight"),),
    },
}


PUBLIC_CONSTANT_EXACT_ANCHORS: dict[str, tuple[str, ...]] = {
    "CairoError": ("Status and error mapping",),
    "COLOR_PALETTE_DEFAULT": (
        "`PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, `COLOR_PALETTE_DEFAULT`",
    ),
    "FORMAT_INVALID": (
        "`PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, `COLOR_PALETTE_DEFAULT`",
    ),
    "PDF_OUTLINE_ROOT": (
        "`PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, `COLOR_PALETTE_DEFAULT`",
    ),
}


CONSTANT_DECISION_ANCHORS: dict[str, tuple[str, ...]] = {
    "CAPI": ("`CAPI`",),
    "version": ("`version`, `version_info`",),
    "version_info": ("`version`, `version_info`",),
}


LEGACY_ENUM_ALIAS_ANCHOR = ("Legacy uppercase enum alias constants",)


PUBLIC_CONSTANT_API_ANCHORS: dict[str, tuple[str, ...]] = {
    "CairoError": ("pub suberror CairoError",),
}


def public_constant_inventory_anchors(name: str) -> tuple[str, ...] | None:
    if name in PUBLIC_CONSTANT_EXACT_ANCHORS:
        return PUBLIC_CONSTANT_EXACT_ANCHORS[name]
    if name == "CAIRO_VERSION" or name.startswith("CAIRO_VERSION_"):
        return ("`CAIRO_VERSION*` constants",)
    if name.startswith("HAS_"):
        return ("`HAS_*` feature constants",)
    if name.startswith("MIME_TYPE_"):
        return ("`MIME_TYPE_*` constants",)
    if name.startswith("TAG_"):
        return ("`TAG_*` constants",)
    return None


def is_public_cairoon_constant(name: str) -> bool:
    return public_constant_inventory_anchors(name) is not None


def public_constant_api_anchors(name: str) -> tuple[str, ...]:
    if name in PUBLIC_CONSTANT_API_ANCHORS:
        return PUBLIC_CONSTANT_API_ANCHORS[name]
    if is_public_cairoon_constant(name):
        return (f"pub const {name} :",)
    return ()


def is_enum_alias(value: ast.AST) -> bool:
    return (
        isinstance(value, ast.Attribute)
        and isinstance(value.value, ast.Name)
        and value.value.id in EXPECTED_ANCHORS
    )


def public_top_level_names(stub_path: pathlib.Path) -> set[str]:
    module = ast.parse(stub_path.read_text(encoding="utf-8"))
    names = set()
    for node in module.body:
        if isinstance(node, (ast.ClassDef, ast.FunctionDef)) and not node.name.startswith("_"):
            names.add(node.name)
    return names


def public_class_methods(stub_path: pathlib.Path) -> dict[str, set[str]]:
    module = ast.parse(stub_path.read_text(encoding="utf-8"))
    methods: dict[str, set[str]] = {}
    for node in module.body:
        if not isinstance(node, ast.ClassDef):
            continue
        public = {
            item.name
            for item in node.body
            if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
            and not item.name.startswith("_")
        }
        if public:
            methods[node.name] = public
    return methods


def public_top_level_constants(stub_path: pathlib.Path) -> tuple[set[str], set[str]]:
    module = ast.parse(stub_path.read_text(encoding="utf-8"))
    constants: set[str] = set()
    enum_aliases: set[str] = set()
    for node in module.body:
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            name = node.target.id
            if not name.startswith("_"):
                constants.add(name)
        elif isinstance(node, ast.Assign):
            public_names = [
                target.id
                for target in node.targets
                if isinstance(target, ast.Name) and not target.id.startswith("_")
            ]
            constants.update(public_names)
            if is_enum_alias(node.value):
                enum_aliases.update(public_names)
    return constants, enum_aliases


def pycairo_api_snapshot() -> tuple[set[str], dict[str, set[str]], set[str], set[str]]:
    """Return the maintained pycairo API snapshot for standalone checkouts."""

    return (
        set(EXPECTED_ANCHORS),
        {
            class_name: set(method_anchors)
            for class_name, method_anchors in PUBLIC_METHOD_ANCHORS.items()
        },
        set(),
        set(),
    )


def load_pycairo_api(
    stub_path: pathlib.Path,
) -> tuple[set[str], dict[str, set[str]], set[str], set[str]]:
    if stub_path.exists():
        constants, enum_aliases = public_top_level_constants(stub_path)
        return (
            public_top_level_names(stub_path),
            public_class_methods(stub_path),
            constants,
            enum_aliases,
        )
    return pycairo_api_snapshot()


def main() -> int:
    stub_names, stub_methods, stub_constants, enum_alias_constants = load_pycairo_api(
        PYCAIRO_STUB
    )
    expected_names = set(EXPECTED_ANCHORS)
    inventory = INVENTORY.read_text(encoding="utf-8")
    public_api = GENERATED_MBTI.read_text(encoding="utf-8")

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
    for class_name in sorted(set(PUBLIC_METHOD_ANCHORS) - set(stub_methods)):
        errors.append(f"{PYCAIRO_STUB}: expected portable class '{class_name}' is missing")
    for class_name, method_anchors in sorted(PUBLIC_METHOD_ANCHORS.items()):
        actual_methods = stub_methods.get(class_name, set())
        expected_methods = set(method_anchors)
        for method in sorted(actual_methods - expected_methods):
            errors.append(
                f"{PYCAIRO_STUB}: pycairo method '{class_name}.{method}' has no "
                "portable method mapping"
            )
        for method in sorted(expected_methods - actual_methods):
            errors.append(
                f"{INVENTORY}: portable method mapping '{class_name}.{method}' is "
                "no longer in pycairo stub"
            )
        for method in sorted(actual_methods & expected_methods):
            for anchor in method_anchors[method]:
                if anchor not in public_api:
                    errors.append(
                        f"{GENERATED_MBTI}: public API anchor {anchor!r} for "
                        f"pycairo method '{class_name}.{method}' is missing"
                    )
    for name in sorted(stub_constants):
        anchors = public_constant_inventory_anchors(name)
        if anchors is None:
            anchors = CONSTANT_DECISION_ANCHORS.get(name)
        if anchors is None and name in enum_alias_constants:
            anchors = LEGACY_ENUM_ALIAS_ANCHOR
        if anchors is None:
            errors.append(f"{PYCAIRO_STUB}: public constant '{name}' has no inventory mapping")
            continue
        for anchor in anchors:
            if anchor not in inventory:
                errors.append(
                    f"{INVENTORY}: anchor {anchor!r} for pycairo constant "
                    f"'{name}' is missing"
                )
        for public_anchor in public_constant_api_anchors(name):
            if public_anchor not in public_api:
                errors.append(
                    f"{GENERATED_MBTI}: public API anchor {public_anchor!r} "
                    f"for pycairo constant or alias '{name}' is missing"
                )

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    method_count = sum(len(stub_methods.get(name, set())) for name in PUBLIC_METHOD_ANCHORS)
    print(
        f"API inventory covers {len(stub_names)} pycairo top-level entries, "
        f"{len(stub_constants)} top-level constants, and "
        f"{method_count} portable class methods"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
