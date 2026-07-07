///|
pub const CAIRO_VERSION : Int = @constants_impl.CAIRO_VERSION

///|
pub const CAIRO_VERSION_STRING : String = @constants_impl.CAIRO_VERSION_STRING

///|
pub const CAIRO_VERSION_MAJOR : Int = @constants_impl.CAIRO_VERSION_MAJOR

///|
pub const CAIRO_VERSION_MINOR : Int = @constants_impl.CAIRO_VERSION_MINOR

///|
pub const CAIRO_VERSION_MICRO : Int = @constants_impl.CAIRO_VERSION_MICRO

///|
pub const HAS_ATSUI_FONT : Bool = @constants_impl.HAS_ATSUI_FONT

///|
pub const HAS_FT_FONT : Bool = @constants_impl.HAS_FT_FONT

///|
pub const HAS_GLITZ_SURFACE : Bool = @constants_impl.HAS_GLITZ_SURFACE

///|
pub const HAS_IMAGE_SURFACE : Bool = @constants_impl.HAS_IMAGE_SURFACE

///|
pub const HAS_MIME_SURFACE : Bool = @constants_impl.HAS_MIME_SURFACE

///|
pub const HAS_PDF_SURFACE : Bool = @constants_impl.HAS_PDF_SURFACE

///|
pub const HAS_PNG_FUNCTIONS : Bool = @constants_impl.HAS_PNG_FUNCTIONS

///|
pub const HAS_PS_SURFACE : Bool = @constants_impl.HAS_PS_SURFACE

///|
pub const HAS_QUARTZ_SURFACE : Bool = @constants_impl.HAS_QUARTZ_SURFACE

///|
pub const HAS_RECORDING_SURFACE : Bool = @constants_impl.HAS_RECORDING_SURFACE

///|
pub const HAS_SCRIPT_SURFACE : Bool = @constants_impl.HAS_SCRIPT_SURFACE

///|
pub const HAS_SVG_SURFACE : Bool = @constants_impl.HAS_SVG_SURFACE

///|
pub const HAS_TEE_SURFACE : Bool = @constants_impl.HAS_TEE_SURFACE

///|
pub const HAS_USER_FONT : Bool = @constants_impl.HAS_USER_FONT

///|
pub const HAS_WIN32_FONT : Bool = @constants_impl.HAS_WIN32_FONT

///|
pub const HAS_WIN32_SURFACE : Bool = @constants_impl.HAS_WIN32_SURFACE

///|
pub const HAS_XCB_SURFACE : Bool = @constants_impl.HAS_XCB_SURFACE

///|
pub const HAS_XLIB_SURFACE : Bool = @constants_impl.HAS_XLIB_SURFACE

///|
pub const HAS_DWRITE_FONT : Bool = @constants_impl.HAS_DWRITE_FONT

///|
pub const MIME_TYPE_JP2 : String = @constants_impl.MIME_TYPE_JP2

///|
pub const MIME_TYPE_JPEG : String = @constants_impl.MIME_TYPE_JPEG

///|
pub const MIME_TYPE_PNG : String = @constants_impl.MIME_TYPE_PNG

///|
pub const MIME_TYPE_URI : String = @constants_impl.MIME_TYPE_URI

///|
pub const MIME_TYPE_UNIQUE_ID : String = @constants_impl.MIME_TYPE_UNIQUE_ID

///|
pub const MIME_TYPE_CCITT_FAX : String = @constants_impl.MIME_TYPE_CCITT_FAX

///|
pub const MIME_TYPE_CCITT_FAX_PARAMS : String = @constants_impl.MIME_TYPE_CCITT_FAX_PARAMS

///|
pub const MIME_TYPE_EPS : String = @constants_impl.MIME_TYPE_EPS

///|
pub const MIME_TYPE_EPS_PARAMS : String = @constants_impl.MIME_TYPE_EPS_PARAMS

///|
pub const MIME_TYPE_JBIG2 : String = @constants_impl.MIME_TYPE_JBIG2

///|
pub const MIME_TYPE_JBIG2_GLOBAL : String = @constants_impl.MIME_TYPE_JBIG2_GLOBAL

///|
pub const MIME_TYPE_JBIG2_GLOBAL_ID : String = @constants_impl.MIME_TYPE_JBIG2_GLOBAL_ID

///|
pub const TAG_DEST : String = @constants_impl.TAG_DEST

///|
pub const TAG_LINK : String = @constants_impl.TAG_LINK

///|
pub const TAG_CONTENT : String = @constants_impl.TAG_CONTENT

///|
pub const TAG_CONTENT_REF : String = @constants_impl.TAG_CONTENT_REF

///|
pub const PDF_OUTLINE_ROOT : Int = @constants_impl.PDF_OUTLINE_ROOT

///|
pub const COLOR_PALETTE_DEFAULT : UInt = @constants_impl.COLOR_PALETTE_DEFAULT

///|
pub fn cairo_version() -> Int {
  ignore(@native.native_anchor())
  @version_impl.cairo_version()
}

///|
pub fn cairo_version_string() -> String {
  ignore(@native.native_anchor())
  @version_impl.cairo_version_string()
}
