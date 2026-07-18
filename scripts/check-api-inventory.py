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
from api.method_mappings import METHOD_DECISION_ANCHORS, PUBLIC_METHOD_ANCHORS
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
    actual_method_keys = {
        (class_name, method)
        for class_name, methods in stub_methods.items()
        for method in methods
    }
    public_method_keys = {
        (class_name, method)
        for class_name, methods in PUBLIC_METHOD_ANCHORS.items()
        for method in methods
    }
    decision_method_keys = {
        (class_name, method)
        for class_name, methods in METHOD_DECISION_ANCHORS.items()
        for method in methods
    }
    mapped_method_keys = public_method_keys | decision_method_keys
    for class_name, method in sorted(public_method_keys & decision_method_keys):
        errors.append(
            f"method mapping '{class_name}.{method}' has both public API and "
            "Decision evidence"
        )
    for class_name, method in sorted(actual_method_keys - mapped_method_keys):
        errors.append(
            f"{source_label}: pycairo method '{class_name}.{method}' has no "
            "portable mapping or product Decision"
        )
    for class_name, method in sorted(mapped_method_keys - actual_method_keys):
        errors.append(
            f"{args.inventory}: method mapping '{class_name}.{method}' is no "
            "longer in pycairo stub"
        )
    for class_name, method in sorted(actual_method_keys & public_method_keys):
        for anchor in PUBLIC_METHOD_ANCHORS[class_name][method]:
            if anchor not in public_api:
                errors.append(
                    f"{public_api_label}: public API anchor {anchor!r} for "
                    f"pycairo method '{class_name}.{method}' is missing"
                )
    for class_name, method in sorted(actual_method_keys & decision_method_keys):
        for anchor in METHOD_DECISION_ANCHORS[class_name][method]:
            if anchor not in inventory:
                errors.append(
                    f"{args.inventory}: Decision anchor {anchor!r} for pycairo "
                    f"method '{class_name}.{method}' is missing"
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
    method_count = len(actual_method_keys & public_method_keys)
    method_decision_count = len(actual_method_keys & decision_method_keys)
    protocol_count = sum(len(protocols) for protocols in stub_protocols.values())
    attribute_count = sum(len(attributes) for attributes in stub_attributes.values())
    print(
        f"API inventory covers {len(stub_names)} pycairo top-level entries, "
        f"{len(stub_constants)} top-level constants, and "
        f"{method_count} portable class methods and "
        f"{method_decision_count} method Decisions, plus "
        f"{protocol_count} class protocols and {attribute_count} class attributes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
