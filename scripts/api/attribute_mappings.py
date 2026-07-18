"""Pycairo class-attribute-to-cairoon evidence mappings."""

from __future__ import annotations

import re


PublicMember = tuple[str, str]


def enum_members(
    type_name: str,
    pairs: tuple[tuple[str, str], ...],
) -> dict[str, PublicMember]:
    return {
        pycairo_name: (type_name, cairoon_name)
        for pycairo_name, cairoon_name in pairs
    }


def field_members(
    type_name: str,
    fields: tuple[tuple[str, str], ...],
) -> dict[str, PublicMember]:
    return {
        pycairo_name: (type_name, signature)
        for pycairo_name, signature in fields
    }


# Members are checked inside their declaring MoonBit type, so repeated field
# names such as x, y, width, and height cannot satisfy the wrong mapping.
PUBLIC_ATTRIBUTE_MEMBERS: dict[str, dict[str, PublicMember]] = {
    "Antialias": enum_members(
        "Antialias",
        (
            ("BEST", "AntialiasBest"),
            ("DEFAULT", "AntialiasDefault"),
            ("FAST", "AntialiasFast"),
            ("GOOD", "AntialiasGood"),
            ("GRAY", "AntialiasGray"),
            ("NONE", "AntialiasNone"),
            ("SUBPIXEL", "AntialiasSubpixel"),
        ),
    ),
    "ColorMode": enum_members(
        "ColorMode",
        (
            ("COLOR", "ColorModeColor"),
            ("DEFAULT", "ColorModeDefault"),
            ("NO_COLOR", "ColorModeNoColor"),
        ),
    ),
    "Content": enum_members(
        "Content",
        (
            ("ALPHA", "ContentAlpha"),
            ("COLOR", "ContentColor"),
            ("COLOR_ALPHA", "ContentColorAlpha"),
        ),
    ),
    "Dither": enum_members(
        "Dither",
        (
            ("BEST", "DitherBest"),
            ("DEFAULT", "DitherDefault"),
            ("FAST", "DitherFast"),
            ("GOOD", "DitherGood"),
            ("NONE", "DitherNone"),
        ),
    ),
    "Extend": enum_members(
        "Extend",
        (
            ("NONE", "ExtendNone"),
            ("PAD", "Pad"),
            ("REFLECT", "Reflect"),
            ("REPEAT", "Repeat"),
        ),
    ),
    "FillRule": enum_members(
        "FillRule",
        (
            ("EVEN_ODD", "FillEvenOdd"),
            ("WINDING", "FillWinding"),
        ),
    ),
    "Filter": enum_members(
        "Filter",
        (
            ("BEST", "Best"),
            ("BILINEAR", "Bilinear"),
            ("FAST", "Fast"),
            ("GAUSSIAN", "Gaussian"),
            ("GOOD", "Good"),
            ("NEAREST", "Nearest"),
        ),
    ),
    "FontSlant": enum_members(
        "FontSlant",
        (
            ("ITALIC", "FontSlantItalic"),
            ("NORMAL", "FontSlantNormal"),
            ("OBLIQUE", "FontSlantOblique"),
        ),
    ),
    "FontWeight": enum_members(
        "FontWeight",
        (
            ("BOLD", "FontWeightBold"),
            ("NORMAL", "FontWeightNormal"),
        ),
    ),
    "Format": enum_members(
        "Format",
        (
            ("A1", "A1"),
            ("A8", "A8"),
            ("ARGB32", "Argb32"),
            ("RGB16_565", "Rgb16_565"),
            ("RGB24", "Rgb24"),
            ("RGB30", "Rgb30"),
            ("RGB96F", "Rgb96F"),
            ("RGBA128F", "Rgba128F"),
        ),
    ),
    "Glyph": field_members(
        "Glyph",
        (
            ("index", "index : UInt64"),
            ("x", "x : Double"),
            ("y", "y : Double"),
        ),
    ),
    "HintMetrics": enum_members(
        "HintMetrics",
        (
            ("DEFAULT", "HintMetricsDefault"),
            ("OFF", "HintMetricsOff"),
            ("ON", "HintMetricsOn"),
        ),
    ),
    "HintStyle": enum_members(
        "HintStyle",
        (
            ("DEFAULT", "HintStyleDefault"),
            ("FULL", "HintStyleFull"),
            ("MEDIUM", "HintStyleMedium"),
            ("NONE", "HintStyleNone"),
            ("SLIGHT", "HintStyleSlight"),
        ),
    ),
    "LineCap": enum_members(
        "LineCap",
        (
            ("BUTT", "LineCapButt"),
            ("ROUND", "LineCapRound"),
            ("SQUARE", "LineCapSquare"),
        ),
    ),
    "LineJoin": enum_members(
        "LineJoin",
        (
            ("BEVEL", "LineJoinBevel"),
            ("MITER", "LineJoinMiter"),
            ("ROUND", "LineJoinRound"),
        ),
    ),
    "Matrix": field_members(
        "Matrix",
        (
            ("x0", "x0 : Double"),
            ("xx", "xx : Double"),
            ("xy", "xy : Double"),
            ("y0", "y0 : Double"),
            ("yx", "yx : Double"),
            ("yy", "yy : Double"),
        ),
    ),
    "Operator": enum_members(
        "Operator",
        (
            ("ADD", "OperatorAdd"),
            ("ATOP", "OperatorAtop"),
            ("CLEAR", "OperatorClear"),
            ("COLOR_BURN", "OperatorColorBurn"),
            ("COLOR_DODGE", "OperatorColorDodge"),
            ("DARKEN", "OperatorDarken"),
            ("DEST", "OperatorDest"),
            ("DEST_ATOP", "OperatorDestAtop"),
            ("DEST_IN", "OperatorDestIn"),
            ("DEST_OUT", "OperatorDestOut"),
            ("DEST_OVER", "OperatorDestOver"),
            ("DIFFERENCE", "OperatorDifference"),
            ("EXCLUSION", "OperatorExclusion"),
            ("HARD_LIGHT", "OperatorHardLight"),
            ("HSL_COLOR", "OperatorHslColor"),
            ("HSL_HUE", "OperatorHslHue"),
            ("HSL_LUMINOSITY", "OperatorHslLuminosity"),
            ("HSL_SATURATION", "OperatorHslSaturation"),
            ("IN", "OperatorIn"),
            ("LIGHTEN", "OperatorLighten"),
            ("MULTIPLY", "OperatorMultiply"),
            ("OUT", "OperatorOut"),
            ("OVER", "OperatorOver"),
            ("OVERLAY", "OperatorOverlay"),
            ("SATURATE", "OperatorSaturate"),
            ("SCREEN", "OperatorScreen"),
            ("SOFT_LIGHT", "OperatorSoftLight"),
            ("SOURCE", "OperatorSource"),
            ("XOR", "OperatorXor"),
        ),
    ),
    "PDFMetadata": enum_members(
        "PDFMetadata",
        (
            ("AUTHOR", "PdfMetadataAuthor"),
            ("CREATE_DATE", "PdfMetadataCreateDate"),
            ("CREATOR", "PdfMetadataCreator"),
            ("KEYWORDS", "PdfMetadataKeywords"),
            ("MOD_DATE", "PdfMetadataModDate"),
            ("SUBJECT", "PdfMetadataSubject"),
            ("TITLE", "PdfMetadataTitle"),
        ),
    ),
    "PDFOutlineFlags": enum_members(
        "PDFOutlineFlags",
        (
            ("BOLD", "PdfOutlineBold"),
            ("ITALIC", "PdfOutlineItalic"),
            ("OPEN", "PdfOutlineOpen"),
        ),
    ),
    "PDFVersion": enum_members(
        "PDFVersion",
        (
            ("VERSION_1_4", "PdfVersion1_4"),
            ("VERSION_1_5", "PdfVersion1_5"),
            ("VERSION_1_6", "PdfVersion1_6"),
            ("VERSION_1_7", "PdfVersion1_7"),
        ),
    ),
    "PSLevel": enum_members(
        "PSLevel",
        (
            ("LEVEL_2", "PsLevel2"),
            ("LEVEL_3", "PsLevel3"),
        ),
    ),
    "PathDataType": enum_members(
        "PathDataType",
        (
            ("CLOSE_PATH", "PathClosePath"),
            ("CURVE_TO", "PathCurveTo"),
            ("LINE_TO", "PathLineTo"),
            ("MOVE_TO", "PathMoveTo"),
        ),
    ),
    "Rectangle": field_members(
        "Rectangle",
        (
            ("height", "height : Double"),
            ("width", "width : Double"),
            ("x", "x : Double"),
            ("y", "y : Double"),
        ),
    ),
    "RectangleInt": field_members(
        "RectangleInt",
        (
            ("height", "height : Int"),
            ("width", "width : Int"),
            ("x", "x : Int"),
            ("y", "y : Int"),
        ),
    ),
    "RegionOverlap": enum_members(
        "RegionOverlap",
        (
            ("IN", "RegionOverlapIn"),
            ("OUT", "RegionOverlapOut"),
            ("PART", "RegionOverlapPart"),
        ),
    ),
    "SVGUnit": enum_members(
        "SVGUnit",
        (
            ("CM", "SvgUnitCm"),
            ("EM", "SvgUnitEm"),
            ("EX", "SvgUnitEx"),
            ("IN", "SvgUnitIn"),
            ("MM", "SvgUnitMm"),
            ("PC", "SvgUnitPc"),
            ("PERCENT", "SvgUnitPercent"),
            ("PT", "SvgUnitPt"),
            ("PX", "SvgUnitPx"),
            ("USER", "SvgUnitUser"),
        ),
    ),
    "SVGVersion": enum_members(
        "SVGVersion",
        (
            ("VERSION_1_1", "SvgVersion1_1"),
            ("VERSION_1_2", "SvgVersion1_2"),
        ),
    ),
    "ScriptMode": enum_members(
        "ScriptMode",
        (
            ("ASCII", "ScriptModeAscii"),
            ("BINARY", "ScriptModeBinary"),
        ),
    ),
    "Status": enum_members(
        "Status",
        (
            ("CLIP_NOT_REPRESENTABLE", "ClipNotRepresentable"),
            ("DEVICE_ERROR", "DeviceError"),
            ("DEVICE_FINISHED", "DeviceFinished"),
            ("DEVICE_TYPE_MISMATCH", "DeviceTypeMismatch"),
            ("DWRITE_ERROR", "DwriteError"),
            ("FILE_NOT_FOUND", "FileNotFound"),
            ("FONT_TYPE_MISMATCH", "FontTypeMismatch"),
            ("FREETYPE_ERROR", "FreetypeError"),
            ("INVALID_CLUSTERS", "InvalidClusters"),
            ("INVALID_CONTENT", "InvalidContent"),
            ("INVALID_DASH", "InvalidDash"),
            ("INVALID_DSC_COMMENT", "InvalidDscComment"),
            ("INVALID_FORMAT", "InvalidFormat"),
            ("INVALID_INDEX", "InvalidIndex"),
            ("INVALID_MATRIX", "InvalidMatrix"),
            ("INVALID_MESH_CONSTRUCTION", "InvalidMeshConstruction"),
            ("INVALID_PATH_DATA", "InvalidPathData"),
            ("INVALID_POP_GROUP", "InvalidPopGroup"),
            ("INVALID_RESTORE", "InvalidRestore"),
            ("INVALID_SIZE", "InvalidSize"),
            ("INVALID_SLANT", "InvalidSlant"),
            ("INVALID_STATUS", "InvalidStatus"),
            ("INVALID_STRIDE", "InvalidStride"),
            ("INVALID_STRING", "InvalidString"),
            ("INVALID_VISUAL", "InvalidVisual"),
            ("INVALID_WEIGHT", "InvalidWeight"),
            ("JBIG2_GLOBAL_MISSING", "Jbig2GlobalMissing"),
            ("LAST_STATUS", "LastStatus"),
            ("NEGATIVE_COUNT", "NegativeCount"),
            ("NO_CURRENT_POINT", "NoCurrentPoint"),
            ("NO_MEMORY", "NoMemory"),
            ("NULL_POINTER", "NullPointer"),
            ("PATTERN_TYPE_MISMATCH", "PatternTypeMismatch"),
            ("PNG_ERROR", "PngError"),
            ("READ_ERROR", "ReadError"),
            ("SUCCESS", "Success"),
            ("SURFACE_FINISHED", "SurfaceFinished"),
            ("SURFACE_TYPE_MISMATCH", "SurfaceTypeMismatch"),
            ("SVG_FONT_ERROR", "SvgFontError"),
            ("TAG_ERROR", "TagError"),
            ("TEMP_FILE_ERROR", "TempFileError"),
            ("USER_FONT_ERROR", "UserFontError"),
            ("USER_FONT_IMMUTABLE", "UserFontImmutable"),
            ("USER_FONT_NOT_IMPLEMENTED", "UserFontNotImplemented"),
            ("WIN32_GDI_ERROR", "Win32GdiError"),
            ("WRITE_ERROR", "WriteError"),
        ),
    ),
    "SubpixelOrder": enum_members(
        "SubpixelOrder",
        (
            ("BGR", "SubpixelBgr"),
            ("DEFAULT", "SubpixelDefault"),
            ("RGB", "SubpixelRgb"),
            ("VBGR", "SubpixelVbgr"),
            ("VRGB", "SubpixelVrgb"),
        ),
    ),
    "SurfaceObserverMode": enum_members(
        "SurfaceObserverMode",
        (
            ("NORMAL", "SurfaceObserverNormal"),
            ("RECORD_OPERATIONS", "SurfaceObserverRecordOperations"),
        ),
    ),
    "TextCluster": field_members(
        "TextCluster",
        (
            ("num_bytes", "num_bytes : Int"),
            ("num_glyphs", "num_glyphs : Int"),
        ),
    ),
    "TextClusterFlags": enum_members(
        "TextClusterFlags",
        (("BACKWARD", "TextClusterBackward"),),
    ),
    "TextExtents": field_members(
        "TextExtents",
        (
            ("height", "height : Double"),
            ("width", "width : Double"),
            ("x_advance", "x_advance : Double"),
            ("x_bearing", "x_bearing : Double"),
            ("y_advance", "y_advance : Double"),
            ("y_bearing", "y_bearing : Double"),
        ),
    ),
}


# These pycairo attributes intentionally adapt to a MoonBit function, constant,
# or structured error payload instead of a member of the same-named type.
PUBLIC_ATTRIBUTE_API_ANCHORS: dict[str, dict[str, tuple[str, ...]]] = {
    "Error": {
        "status": (
            "CairoError(Status, String)",
            "CairoMemoryError(Status, String)",
            "CairoIOError(Status, String)",
            "CairoInvalidArgument(Status, String)",
        ),
    },
    "Format": {
        "INVALID": ("pub const FORMAT_INVALID :",),
    },
    "ImageSurface": {
        "format_stride_for_width": ("pub fn Format::stride_for_width(",),
    },
    "PSSurface": {
        "ps_level_to_string": ("pub fn PSLevel::to_string(",),
    },
}


PUBLIC_TYPE_BLOCK = re.compile(
    r"^pub(?:\(all\))? (?:enum|struct|suberror) ([A-Za-z_][A-Za-z0-9_]*) \{$"
)


def parse_public_type_members(public_api: str) -> dict[str, set[str]]:
    """Parse generated MoonBit interface enum constructors and struct fields."""
    members: dict[str, set[str]] = {}
    current_type: str | None = None
    for line in public_api.splitlines():
        if current_type is None:
            match = PUBLIC_TYPE_BLOCK.match(line)
            if match is not None:
                current_type = match.group(1)
                members.setdefault(current_type, set())
            continue
        if line.startswith("}"):
            current_type = None
            continue
        member = line.strip()
        if member:
            members[current_type].add(member)
    return members
