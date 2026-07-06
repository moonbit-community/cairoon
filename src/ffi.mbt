///|
type Surface

///|
type Device

///|
type MappedImageSurface

///|
type ImageData

///|
type Context

///|
type Pattern

///|
type FontOptions

///|
type FontFace

///|
type ScaledFont

///|
type Path

///|
type Region

///|
priv type TextToGlyphsNative

///|
extern "C" fn cairo_version_ffi() -> Int = "cairo_version"

///|
extern "C" fn cairo_version_string_ffi() -> Bytes = "cairoon_version_string"

///|
extern "C" fn status_to_string_ffi(status : Status) -> Bytes = "cairoon_status_to_string"
