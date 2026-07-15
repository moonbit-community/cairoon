///|
/// The compile-time Cairo version encoded as `major * 10000 + minor * 100 + micro`.
pub const CAIRO_VERSION : Int = @constants_impl.CAIRO_VERSION

///|
/// The compile-time Cairo version in `major.minor.micro` form.
pub const CAIRO_VERSION_STRING : String = @constants_impl.CAIRO_VERSION_STRING

///|
/// The compile-time Cairo major version.
pub const CAIRO_VERSION_MAJOR : Int = @constants_impl.CAIRO_VERSION_MAJOR

///|
/// The compile-time Cairo minor version.
pub const CAIRO_VERSION_MINOR : Int = @constants_impl.CAIRO_VERSION_MINOR

///|
/// The compile-time Cairo micro version.
pub const CAIRO_VERSION_MICRO : Int = @constants_impl.CAIRO_VERSION_MICRO

///|
/// Whether the linked Cairo headers enable the legacy ATSUI font backend.
pub const HAS_ATSUI_FONT : Bool = @constants_impl.HAS_ATSUI_FONT

///|
/// Whether the linked Cairo headers enable the FreeType font backend.
pub const HAS_FT_FONT : Bool = @constants_impl.HAS_FT_FONT

///|
/// Whether the linked Cairo headers enable the legacy Glitz surface backend.
pub const HAS_GLITZ_SURFACE : Bool = @constants_impl.HAS_GLITZ_SURFACE

///|
/// Whether the linked Cairo headers enable image surfaces.
pub const HAS_IMAGE_SURFACE : Bool = @constants_impl.HAS_IMAGE_SURFACE

///|
/// Whether the linked Cairo headers enable MIME data on surfaces.
pub const HAS_MIME_SURFACE : Bool = @constants_impl.HAS_MIME_SURFACE

///|
/// Whether the linked Cairo headers enable PDF surfaces.
pub const HAS_PDF_SURFACE : Bool = @constants_impl.HAS_PDF_SURFACE

///|
/// Whether the linked Cairo headers enable PNG read and write helpers.
pub const HAS_PNG_FUNCTIONS : Bool = @constants_impl.HAS_PNG_FUNCTIONS

///|
/// Whether the linked Cairo headers enable PostScript surfaces.
pub const HAS_PS_SURFACE : Bool = @constants_impl.HAS_PS_SURFACE

///|
/// Whether the linked Cairo headers enable Quartz surfaces.
pub const HAS_QUARTZ_SURFACE : Bool = @constants_impl.HAS_QUARTZ_SURFACE

///|
/// Whether the linked Cairo headers enable recording surfaces.
pub const HAS_RECORDING_SURFACE : Bool = @constants_impl.HAS_RECORDING_SURFACE

///|
/// Whether the linked Cairo headers enable Cairo script surfaces.
pub const HAS_SCRIPT_SURFACE : Bool = @constants_impl.HAS_SCRIPT_SURFACE

///|
/// Whether the linked Cairo headers enable SVG surfaces.
pub const HAS_SVG_SURFACE : Bool = @constants_impl.HAS_SVG_SURFACE

///|
/// Whether the linked Cairo headers enable Tee surfaces.
pub const HAS_TEE_SURFACE : Bool = @constants_impl.HAS_TEE_SURFACE

///|
/// Whether the linked Cairo headers enable user fonts.
pub const HAS_USER_FONT : Bool = @constants_impl.HAS_USER_FONT

///|
/// Whether the linked Cairo headers enable the Win32 font backend.
pub const HAS_WIN32_FONT : Bool = @constants_impl.HAS_WIN32_FONT

///|
/// Whether the linked Cairo headers enable Win32 surfaces.
pub const HAS_WIN32_SURFACE : Bool = @constants_impl.HAS_WIN32_SURFACE

///|
/// Whether the linked Cairo headers enable XCB surfaces.
pub const HAS_XCB_SURFACE : Bool = @constants_impl.HAS_XCB_SURFACE

///|
/// Whether the linked Cairo headers enable Xlib surfaces.
pub const HAS_XLIB_SURFACE : Bool = @constants_impl.HAS_XLIB_SURFACE

///|
/// Whether the linked Cairo headers enable the DirectWrite font backend.
pub const HAS_DWRITE_FONT : Bool = @constants_impl.HAS_DWRITE_FONT

///|
/// The MIME key for JPEG 2000 image data attached to a surface.
pub const MIME_TYPE_JP2 : String = @constants_impl.MIME_TYPE_JP2

///|
/// The MIME key for JPEG image data attached to a surface.
pub const MIME_TYPE_JPEG : String = @constants_impl.MIME_TYPE_JPEG

///|
/// The MIME key for PNG image data attached to a surface.
pub const MIME_TYPE_PNG : String = @constants_impl.MIME_TYPE_PNG

///|
/// The MIME key for a source URI attached to a surface.
pub const MIME_TYPE_URI : String = @constants_impl.MIME_TYPE_URI

///|
/// The MIME key for Cairo's unique surface identifier.
pub const MIME_TYPE_UNIQUE_ID : String = @constants_impl.MIME_TYPE_UNIQUE_ID

///|
/// The MIME key for CCITT Group 3 fax image data.
pub const MIME_TYPE_CCITT_FAX : String = @constants_impl.MIME_TYPE_CCITT_FAX

///|
/// The MIME key for parameters associated with CCITT fax image data.
pub const MIME_TYPE_CCITT_FAX_PARAMS : String = @constants_impl.MIME_TYPE_CCITT_FAX_PARAMS

///|
/// The MIME key for encapsulated PostScript data.
pub const MIME_TYPE_EPS : String = @constants_impl.MIME_TYPE_EPS

///|
/// The MIME key for parameters associated with encapsulated PostScript data.
pub const MIME_TYPE_EPS_PARAMS : String = @constants_impl.MIME_TYPE_EPS_PARAMS

///|
/// The MIME key for JBIG2 image data.
pub const MIME_TYPE_JBIG2 : String = @constants_impl.MIME_TYPE_JBIG2

///|
/// The MIME key for shared JBIG2 global data.
pub const MIME_TYPE_JBIG2_GLOBAL : String = @constants_impl.MIME_TYPE_JBIG2_GLOBAL

///|
/// The MIME key identifying the shared JBIG2 global-data object.
pub const MIME_TYPE_JBIG2_GLOBAL_ID : String = @constants_impl.MIME_TYPE_JBIG2_GLOBAL_ID

///|
/// Cairo's tag name for a named destination.
pub const TAG_DEST : String = @constants_impl.TAG_DEST

///|
/// Cairo's tag name for a hyperlink.
pub const TAG_LINK : String = @constants_impl.TAG_LINK

///|
/// Cairo's tag name for content identifiers.
pub const TAG_CONTENT : String = @constants_impl.TAG_CONTENT

///|
/// Cairo's tag name for references to tagged content.
pub const TAG_CONTENT_REF : String = @constants_impl.TAG_CONTENT_REF

///|
/// The root outline identifier accepted by Cairo's PDF outline API.
pub const PDF_OUTLINE_ROOT : Int = @constants_impl.PDF_OUTLINE_ROOT

///|
/// The default color-palette identifier used by Cairo font options.
pub const COLOR_PALETTE_DEFAULT : UInt = @constants_impl.COLOR_PALETTE_DEFAULT

///|
/// Return the runtime Cairo library version in encoded integer form.
pub fn cairo_version() -> Int {
  ignore(@native.native_anchor())
  @version_impl.cairo_version()
}

///|
/// Return the runtime Cairo library version as `major.minor.micro` text.
pub fn cairo_version_string() -> String {
  ignore(@native.native_anchor())
  @version_impl.cairo_version_string()
}
