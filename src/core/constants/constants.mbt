///|
/// The configured Cairo version encoded as `major * 10000 + minor * 100 + micro`.
pub const CAIRO_VERSION : Int = 11804

///|
/// The configured Cairo version in `major.minor.micro` form.
pub const CAIRO_VERSION_STRING : String = "1.18.4"

///|
/// The configured Cairo major version.
pub const CAIRO_VERSION_MAJOR : Int = 1

///|
/// The configured Cairo minor version.
pub const CAIRO_VERSION_MINOR : Int = 18

///|
/// The configured Cairo micro version.
pub const CAIRO_VERSION_MICRO : Int = 4

///|
/// Whether the configured Cairo headers enable the legacy ATSUI font backend.
pub const HAS_ATSUI_FONT : Bool = false

///|
/// Whether the configured Cairo headers enable the FreeType font backend.
pub const HAS_FT_FONT : Bool = true

///|
/// Whether the configured Cairo headers enable the legacy Glitz surface backend.
pub const HAS_GLITZ_SURFACE : Bool = false

///|
/// Whether the configured Cairo headers enable image surfaces.
pub const HAS_IMAGE_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable MIME data on surfaces.
pub const HAS_MIME_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable PDF surfaces.
pub const HAS_PDF_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable PNG read and write helpers.
pub const HAS_PNG_FUNCTIONS : Bool = true

///|
/// Whether the configured Cairo headers enable PostScript surfaces.
pub const HAS_PS_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable Quartz surfaces.
pub const HAS_QUARTZ_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable recording surfaces.
pub const HAS_RECORDING_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable Cairo script surfaces.
pub const HAS_SCRIPT_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable SVG surfaces.
pub const HAS_SVG_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable Tee surfaces.
pub const HAS_TEE_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable user fonts.
pub const HAS_USER_FONT : Bool = true

///|
/// Whether the configured Cairo headers enable the Win32 font backend.
pub const HAS_WIN32_FONT : Bool = false

///|
/// Whether the configured Cairo headers enable Win32 surfaces.
pub const HAS_WIN32_SURFACE : Bool = false

///|
/// Whether the configured Cairo headers enable XCB surfaces.
pub const HAS_XCB_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable Xlib surfaces.
pub const HAS_XLIB_SURFACE : Bool = true

///|
/// Whether the configured Cairo headers enable the DirectWrite font backend.
pub const HAS_DWRITE_FONT : Bool = false

///|
/// The MIME key for JPEG 2000 image data attached to a surface.
pub const MIME_TYPE_JP2 : String = "image/jp2"

///|
/// The MIME key for JPEG image data attached to a surface.
pub const MIME_TYPE_JPEG : String = "image/jpeg"

///|
/// The MIME key for PNG image data attached to a surface.
pub const MIME_TYPE_PNG : String = "image/png"

///|
/// The MIME key for a source URI attached to a surface.
pub const MIME_TYPE_URI : String = "text/x-uri"

///|
/// The MIME key for Cairo's unique surface identifier.
pub const MIME_TYPE_UNIQUE_ID : String = "application/x-cairo.uuid"

///|
/// The MIME key for CCITT Group 3 fax image data.
pub const MIME_TYPE_CCITT_FAX : String = "image/g3fax"

///|
/// The MIME key for parameters associated with CCITT fax image data.
pub const MIME_TYPE_CCITT_FAX_PARAMS : String = "application/x-cairo.ccitt.params"

///|
/// The MIME key for encapsulated PostScript data.
pub const MIME_TYPE_EPS : String = "application/postscript"

///|
/// The MIME key for parameters associated with encapsulated PostScript data.
pub const MIME_TYPE_EPS_PARAMS : String = "application/x-cairo.eps.params"

///|
/// The MIME key for JBIG2 image data.
pub const MIME_TYPE_JBIG2 : String = "application/x-cairo.jbig2"

///|
/// The MIME key for shared JBIG2 global data.
pub const MIME_TYPE_JBIG2_GLOBAL : String = "application/x-cairo.jbig2-global"

///|
/// The MIME key identifying the shared JBIG2 global-data object.
pub const MIME_TYPE_JBIG2_GLOBAL_ID : String = "application/x-cairo.jbig2-global-id"

///|
/// Cairo's tag name for a named destination.
pub const TAG_DEST : String = "cairo.dest"

///|
/// Cairo's tag name for a hyperlink.
pub const TAG_LINK : String = "Link"

///|
/// Cairo's tag name for content identifiers.
pub const TAG_CONTENT : String = "cairo.content"

///|
/// Cairo's tag name for references to tagged content.
pub const TAG_CONTENT_REF : String = "cairo.content_ref"

///|
/// The root outline identifier accepted by Cairo's PDF outline API.
pub const PDF_OUTLINE_ROOT : Int = 0

///|
/// The default color-palette identifier used by Cairo font options.
pub const COLOR_PALETTE_DEFAULT : UInt = 0U
