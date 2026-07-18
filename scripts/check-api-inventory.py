#!/usr/bin/env python3
"""Check that pycairo APIs are represented in cairoon's migration ledger."""

from __future__ import annotations

import argparse
import pathlib
import sys


SCRIPT_ROOT = pathlib.Path(__file__).resolve().parent
if str(SCRIPT_ROOT) not in sys.path:
    sys.path.insert(0, str(SCRIPT_ROOT))

from api.attribute_mappings import (
    PUBLIC_ATTRIBUTE_API_ANCHORS,
    PUBLIC_ATTRIBUTE_MEMBERS,
    parse_public_type_members,
)
from api.protocol_mappings import (
    PROTOCOL_DECISION_ANCHORS,
    PUBLIC_PROTOCOL_ANCHORS,
)
from api.snapshot import load_pycairo_api, write_api_snapshot


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PYCAIRO_STUB = REPO_ROOT.parent / "cairo" / "__init__.pyi"
PYCAIRO_API_SNAPSHOT = REPO_ROOT / "scripts" / "api" / "pycairo-api-snapshot.json"
INVENTORY = REPO_ROOT / "API_INVENTORY.md"
GENERATED_MBTI = REPO_ROOT / "src" / "pkg.generated.mbti"
GLYPH_MBTI = REPO_ROOT / "src" / "core" / "glyph" / "pkg.generated.mbti"
DEFAULT_PUBLIC_APIS = (GENERATED_MBTI, GLYPH_MBTI)

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


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stub", type=pathlib.Path, default=PYCAIRO_STUB)
    parser.add_argument(
        "--snapshot", type=pathlib.Path, default=PYCAIRO_API_SNAPSHOT
    )
    parser.add_argument("--inventory", type=pathlib.Path, default=INVENTORY)
    parser.add_argument("--public-api", type=pathlib.Path, action="append")
    parser.add_argument("--update-snapshot", action="store_true")
    parser.add_argument("--upstream-commit")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.update_snapshot:
        if args.upstream_commit is None:
            print("--update-snapshot requires --upstream-commit", file=sys.stderr)
            return 2
        try:
            shape = write_api_snapshot(args.stub, args.snapshot, args.upstream_commit)
        except (OSError, SyntaxError, ValueError) as exc:
            print(exc, file=sys.stderr)
            return 1
        names, methods, protocols, attributes, constants, _ = shape
        print(
            f"Wrote {args.snapshot} with {len(names)} top-level entries, "
            f"{len(constants)} constants, and "
            f"{sum(len(items) for items in methods.values())} class methods, "
            f"{sum(len(items) for items in protocols.values())} protocols, and "
            f"{sum(len(items) for items in attributes.values())} class attributes"
        )
        return 0
    try:
        (
            stub_names,
            stub_methods,
            stub_protocols,
            stub_attributes,
            stub_constants,
            enum_alias_constants,
        ) = load_pycairo_api(args.stub, args.snapshot)
        inventory = args.inventory.read_text(encoding="utf-8")
        public_api_paths = tuple(args.public_api or DEFAULT_PUBLIC_APIS)
        public_api = "\n".join(
            path.read_text(encoding="utf-8") for path in public_api_paths
        )
        public_type_members = parse_public_type_members(public_api)
    except (OSError, SyntaxError, ValueError) as exc:
        print(exc, file=sys.stderr)
        return 1
    source_label = args.stub if args.stub.is_file() else args.snapshot
    public_api_label = ", ".join(str(path) for path in public_api_paths)
    expected_names = set(EXPECTED_ANCHORS)

    errors: list[str] = []
    for name in sorted(stub_names - expected_names):
        errors.append(f"{source_label}: public API '{name}' has no inventory mapping")
    for name in sorted(expected_names - stub_names):
        errors.append(
            f"{args.inventory}: inventory mapping for '{name}' is no longer "
            "in the pycairo API snapshot"
        )
    for name in sorted(stub_names & expected_names):
        for anchor in EXPECTED_ANCHORS[name]:
            if anchor not in inventory:
                errors.append(
                    f"{args.inventory}: anchor {anchor!r} for pycairo API "
                    f"'{name}' is missing"
                )
    for class_name in sorted(set(PUBLIC_METHOD_ANCHORS) - set(stub_methods)):
        errors.append(f"{source_label}: expected portable class '{class_name}' is missing")
    for class_name, method_anchors in sorted(PUBLIC_METHOD_ANCHORS.items()):
        actual_methods = stub_methods.get(class_name, set())
        expected_methods = set(method_anchors)
        for method in sorted(actual_methods - expected_methods):
            errors.append(
                f"{source_label}: pycairo method '{class_name}.{method}' has no "
                "portable method mapping"
            )
        for method in sorted(expected_methods - actual_methods):
            errors.append(
                f"{args.inventory}: portable method mapping "
                f"'{class_name}.{method}' is "
                "no longer in pycairo stub"
            )
        for method in sorted(actual_methods & expected_methods):
            for anchor in method_anchors[method]:
                if anchor not in public_api:
                    errors.append(
                        f"{public_api_label}: public API anchor {anchor!r} for "
                        f"pycairo method '{class_name}.{method}' is missing"
                    )
    actual_protocol_keys = {
        (class_name, protocol)
        for class_name, protocols in stub_protocols.items()
        for protocol in protocols
    }
    public_protocol_keys = {
        (class_name, protocol)
        for class_name, protocols in PUBLIC_PROTOCOL_ANCHORS.items()
        for protocol in protocols
    }
    decision_protocol_keys = {
        (class_name, protocol)
        for class_name, protocols in PROTOCOL_DECISION_ANCHORS.items()
        for protocol in protocols
    }
    mapped_protocol_keys = public_protocol_keys | decision_protocol_keys
    for class_name, protocol in sorted(actual_protocol_keys - mapped_protocol_keys):
        errors.append(
            f"{source_label}: pycairo protocol '{class_name}.{protocol}' has no "
            "portable mapping or product Decision"
        )
    for class_name, protocol in sorted(mapped_protocol_keys - actual_protocol_keys):
        errors.append(
            f"{args.inventory}: protocol mapping '{class_name}.{protocol}' is "
            "no longer in pycairo stub"
        )
    for class_name, protocol in sorted(actual_protocol_keys & public_protocol_keys):
        for anchor in PUBLIC_PROTOCOL_ANCHORS[class_name][protocol]:
            if anchor not in public_api:
                errors.append(
                    f"{public_api_label}: public API anchor {anchor!r} for "
                    f"pycairo protocol '{class_name}.{protocol}' is missing"
                )
    for class_name, protocol in sorted(actual_protocol_keys & decision_protocol_keys):
        for anchor in PROTOCOL_DECISION_ANCHORS[class_name][protocol]:
            if anchor not in inventory:
                errors.append(
                    f"{args.inventory}: Decision anchor {anchor!r} for "
                    f"pycairo protocol '{class_name}.{protocol}' is missing"
                )
    actual_attribute_keys = {
        (class_name, attribute)
        for class_name, attributes in stub_attributes.items()
        for attribute in attributes
    }
    member_attribute_keys = {
        (class_name, attribute)
        for class_name, attributes in PUBLIC_ATTRIBUTE_MEMBERS.items()
        for attribute in attributes
    }
    api_attribute_keys = {
        (class_name, attribute)
        for class_name, attributes in PUBLIC_ATTRIBUTE_API_ANCHORS.items()
        for attribute in attributes
    }
    mapped_attribute_keys = member_attribute_keys | api_attribute_keys
    for class_name, attribute in sorted(
        member_attribute_keys & api_attribute_keys
    ):
        errors.append(
            f"attribute mapping '{class_name}.{attribute}' has both member and "
            "API-anchor evidence"
        )
    for class_name, attribute in sorted(
        actual_attribute_keys - mapped_attribute_keys
    ):
        errors.append(
            f"{source_label}: pycairo class attribute "
            f"'{class_name}.{attribute}' has no public API mapping"
        )
    for class_name, attribute in sorted(
        mapped_attribute_keys - actual_attribute_keys
    ):
        errors.append(
            f"{args.inventory}: class attribute mapping "
            f"'{class_name}.{attribute}' is no longer in pycairo stub"
        )
    for class_name, attribute in sorted(
        actual_attribute_keys & member_attribute_keys
    ):
        type_name, member = PUBLIC_ATTRIBUTE_MEMBERS[class_name][attribute]
        if member not in public_type_members.get(type_name, set()):
            errors.append(
                f"{public_api_label}: public member '{type_name}.{member}' for "
                f"pycairo class attribute '{class_name}.{attribute}' is missing"
            )
    for class_name, attribute in sorted(
        actual_attribute_keys & api_attribute_keys
    ):
        for anchor in PUBLIC_ATTRIBUTE_API_ANCHORS[class_name][attribute]:
            if anchor not in public_api:
                errors.append(
                    f"{public_api_label}: public API anchor {anchor!r} for "
                    f"pycairo class attribute '{class_name}.{attribute}' is missing"
                )
    for name in sorted(stub_constants):
        anchors = public_constant_inventory_anchors(name)
        if anchors is None:
            anchors = CONSTANT_DECISION_ANCHORS.get(name)
        if anchors is None and name in enum_alias_constants:
            anchors = LEGACY_ENUM_ALIAS_ANCHOR
        if anchors is None:
            errors.append(
                f"{source_label}: public constant '{name}' has no inventory mapping"
            )
            continue
        for anchor in anchors:
            if anchor not in inventory:
                errors.append(
                    f"{args.inventory}: anchor {anchor!r} for pycairo constant "
                    f"'{name}' is missing"
                )
        for public_anchor in public_constant_api_anchors(name):
            if public_anchor not in public_api:
                errors.append(
                    f"{public_api_label}: public API anchor {public_anchor!r} "
                    f"for pycairo constant or alias '{name}' is missing"
                )

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    method_count = sum(len(stub_methods.get(name, set())) for name in PUBLIC_METHOD_ANCHORS)
    protocol_count = sum(len(protocols) for protocols in stub_protocols.values())
    attribute_count = sum(len(attributes) for attributes in stub_attributes.values())
    print(
        f"API inventory covers {len(stub_names)} pycairo top-level entries, "
        f"{len(stub_constants)} top-level constants, and "
        f"{method_count} portable class methods, plus "
        f"{protocol_count} class protocols and {attribute_count} class attributes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
