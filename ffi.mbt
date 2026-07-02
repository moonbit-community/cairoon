///|
type Surface

///|
type Device

///|
type MappedImageSurface

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
#borrow(path)
extern "C" fn path_status_ffi(path : Path) -> Status = "cairoon_path_status"

///|
#borrow(path, other)
extern "C" fn path_equal_ffi(path : Path, other : Path) -> Bool = "cairoon_path_equal"

///|
#borrow(path)
extern "C" fn path_hash_ffi(path : Path) -> UInt64 = "cairoon_path_hash"

///|
#borrow(path, status)
extern "C" fn path_num_data_ffi(path : Path, status : Ref[Status]) -> Int = "cairoon_path_num_data"

///|
#borrow(path, status)
extern "C" fn path_num_segments_ffi(path : Path, status : Ref[Status]) -> Int = "cairoon_path_num_segments"

///|
#borrow(path, type_, length, x1, y1, x2, y2, x3, y3)
extern "C" fn path_get_data_ffi(
  path : Path,
  data_index : Int,
  type_ : Ref[PathDataType],
  length : Ref[Int],
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
  x3 : Ref[Double],
  y3 : Ref[Double],
) -> Status = "cairoon_path_get_data"

///|
#borrow(path, status)
extern "C" fn path_to_string_ffi(path : Path, status : Ref[Status]) -> Bytes = "cairoon_path_to_string"

///|
extern "C" fn cairo_version_ffi() -> Int = "cairo_version"

///|
extern "C" fn cairo_version_string_ffi() -> Bytes = "cairoon_version_string"

///|
extern "C" fn status_to_string_ffi(status : Status) -> Bytes = "cairoon_status_to_string"

///|
#borrow(filename, status)
extern "C" fn script_device_create_ffi(
  filename : Bytes,
  status : Ref[Status],
) -> Device = "cairoon_script_device_create"

///|
#borrow(device)
extern "C" fn device_status_ffi(device : Device) -> Status = "cairoon_device_status"

///|
#borrow(device, other)
extern "C" fn device_equal_ffi(device : Device, other : Device) -> Bool = "cairoon_device_equal"

///|
#borrow(device)
extern "C" fn device_hash_ffi(device : Device) -> UInt64 = "cairoon_device_hash"

///|
#borrow(device, status)
extern "C" fn device_get_type_ffi(
  device : Device,
  status : Ref[Status],
) -> DeviceType = "cairoon_device_get_type"

///|
#borrow(device)
extern "C" fn device_finish_ffi(device : Device) -> Status = "cairoon_device_finish"

///|
#borrow(device)
extern "C" fn device_flush_ffi(device : Device) -> Status = "cairoon_device_flush"

///|
#borrow(device)
extern "C" fn device_acquire_ffi(device : Device) -> Status = "cairoon_device_acquire"

///|
#borrow(device)
extern "C" fn device_release_ffi(device : Device) -> Status = "cairoon_device_release"

///|
#borrow(device, status)
extern "C" fn script_device_get_mode_ffi(
  device : Device,
  status : Ref[Status],
) -> ScriptMode = "cairoon_script_device_get_mode"

///|
#borrow(device)
extern "C" fn script_device_set_mode_ffi(
  device : Device,
  mode : ScriptMode,
) -> Status = "cairoon_script_device_set_mode"

///|
#borrow(device, comment)
extern "C" fn script_device_write_comment_ffi(
  device : Device,
  comment : Bytes,
) -> Status = "cairoon_script_device_write_comment"

///|
#borrow(device, surface)
extern "C" fn script_device_from_recording_surface_ffi(
  device : Device,
  surface : Surface,
) -> Status = "cairoon_script_device_from_recording_surface"

///|
extern "C" fn font_options_create_ffi() -> FontOptions = "cairoon_font_options_create"

///|
#borrow(options)
extern "C" fn font_options_status_ffi(options : FontOptions) -> Status = "cairoon_font_options_status"

///|
#borrow(options, status)
extern "C" fn font_options_copy_ffi(
  options : FontOptions,
  status : Ref[Status],
) -> FontOptions = "cairoon_font_options_copy"

///|
#borrow(options, other)
extern "C" fn font_options_merge_ffi(
  options : FontOptions,
  other : FontOptions,
) -> Status = "cairoon_font_options_merge"

///|
#borrow(options, other)
extern "C" fn font_options_equal_ffi(
  options : FontOptions,
  other : FontOptions,
) -> Bool = "cairoon_font_options_equal"

///|
#borrow(options)
extern "C" fn font_options_hash_ffi(options : FontOptions) -> UInt64 = "cairoon_font_options_hash"

///|
#borrow(options)
extern "C" fn font_options_get_antialias_ffi(
  options : FontOptions,
) -> Antialias = "cairoon_font_options_get_antialias"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_ffi(
  options : FontOptions,
  antialias : Antialias,
) -> Status = "cairoon_font_options_set_antialias"

///|
#borrow(options)
extern "C" fn font_options_get_subpixel_order_ffi(
  options : FontOptions,
) -> SubpixelOrder = "cairoon_font_options_get_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_ffi(
  options : FontOptions,
  subpixel_order : SubpixelOrder,
) -> Status = "cairoon_font_options_set_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_get_hint_style_ffi(
  options : FontOptions,
) -> HintStyle = "cairoon_font_options_get_hint_style"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_ffi(
  options : FontOptions,
  hint_style : HintStyle,
) -> Status = "cairoon_font_options_set_hint_style"

///|
#borrow(options)
extern "C" fn font_options_get_hint_metrics_ffi(
  options : FontOptions,
) -> HintMetrics = "cairoon_font_options_get_hint_metrics"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_ffi(
  options : FontOptions,
  hint_metrics : HintMetrics,
) -> Status = "cairoon_font_options_set_hint_metrics"

///|
#borrow(options, has_variations)
extern "C" fn font_options_get_variations_ffi(
  options : FontOptions,
  has_variations : Ref[Int],
) -> Bytes = "cairoon_font_options_get_variations"

///|
#borrow(options, variations)
extern "C" fn font_options_set_variations_ffi(
  options : FontOptions,
  variations : Bytes,
) -> Status = "cairoon_font_options_set_variations"

///|
#borrow(options)
extern "C" fn font_options_clear_variations_ffi(
  options : FontOptions,
) -> Status = "cairoon_font_options_clear_variations"

///|
#borrow(options)
extern "C" fn font_options_get_color_mode_ffi(
  options : FontOptions,
) -> ColorMode = "cairoon_font_options_get_color_mode"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_ffi(
  options : FontOptions,
  color_mode : ColorMode,
) -> Status = "cairoon_font_options_set_color_mode"

///|
#borrow(options)
extern "C" fn font_options_get_color_palette_ffi(options : FontOptions) -> UInt = "cairoon_font_options_get_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_color_palette_ffi(
  options : FontOptions,
  palette_index : UInt,
) -> Status = "cairoon_font_options_set_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_custom_palette_color_ffi(
  options : FontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_font_options_set_custom_palette_color"

///|
#borrow(options, red, green, blue, alpha)
extern "C" fn font_options_get_custom_palette_color_ffi(
  options : FontOptions,
  index : UInt,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_font_options_get_custom_palette_color"

///|
#borrow(family)
extern "C" fn toy_font_face_create_ffi(
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> FontFace = "cairoon_toy_font_face_create"

///|
#borrow(font_face)
extern "C" fn font_face_status_ffi(font_face : FontFace) -> Status = "cairoon_font_face_status"

///|
#borrow(font_face, other)
extern "C" fn font_face_equal_ffi(
  font_face : FontFace,
  other : FontFace,
) -> Bool = "cairoon_font_face_equal"

///|
#borrow(font_face)
extern "C" fn font_face_hash_ffi(font_face : FontFace) -> UInt64 = "cairoon_font_face_hash"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_family_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> Bytes = "cairoon_toy_font_face_get_family"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_slant_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontSlant = "cairoon_toy_font_face_get_slant"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_weight_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontWeight = "cairoon_toy_font_face_get_weight"

///|
#borrow(font_face, options)
extern "C" fn scaled_font_create_ffi(
  font_face : FontFace,
  font_xx : Double,
  font_yx : Double,
  font_xy : Double,
  font_yy : Double,
  font_x0 : Double,
  font_y0 : Double,
  ctm_xx : Double,
  ctm_yx : Double,
  ctm_xy : Double,
  ctm_yy : Double,
  ctm_x0 : Double,
  ctm_y0 : Double,
  options : FontOptions,
) -> ScaledFont = "cairoon_scaled_font_create"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_status_ffi(scaled_font : ScaledFont) -> Status = "cairoon_scaled_font_status"

///|
#borrow(scaled_font, other)
extern "C" fn scaled_font_equal_ffi(
  scaled_font : ScaledFont,
  other : ScaledFont,
) -> Bool = "cairoon_scaled_font_equal"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_hash_ffi(scaled_font : ScaledFont) -> UInt64 = "cairoon_scaled_font_hash"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_face_ffi(
  scaled_font : ScaledFont,
  status : Ref[Status],
) -> FontFace = "cairoon_scaled_font_get_font_face"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_options_ffi(
  scaled_font : ScaledFont,
  status : Ref[Status],
) -> FontOptions = "cairoon_scaled_font_get_font_options"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_font_matrix_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_font_matrix"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_ctm_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_ctm"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_scale_matrix_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_scale_matrix"

///|
#borrow(scaled_font, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn scaled_font_extents_ffi(
  scaled_font : ScaledFont,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_extents"

///|
#borrow(scaled_font, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_text_extents_ffi(
  scaled_font : ScaledFont,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_text_extents"

///|
#borrow(scaled_font, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_glyph_extents_ffi(
  scaled_font : ScaledFont,
  indices : FixedArray[UInt],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_glyph_extents"

///|
#borrow(scaled_font, text)
extern "C" fn scaled_font_text_to_glyphs_ffi(
  scaled_font : ScaledFont,
  x : Double,
  y : Double,
  text : Bytes,
) -> TextToGlyphsNative = "cairoon_scaled_font_text_to_glyphs"

///|
#borrow(result)
extern "C" fn text_to_glyphs_status_ffi(result : TextToGlyphsNative) -> Status = "cairoon_text_to_glyphs_status"

///|
#borrow(result)
extern "C" fn text_to_glyphs_indices_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Int] = "cairoon_text_to_glyphs_indices"

///|
#borrow(result)
extern "C" fn text_to_glyphs_positions_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Double] = "cairoon_text_to_glyphs_positions"

///|
#borrow(result)
extern "C" fn text_to_glyphs_clusters_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Int] = "cairoon_text_to_glyphs_clusters"

///|
#borrow(result)
extern "C" fn text_to_glyphs_flags_ffi(
  result : TextToGlyphsNative,
) -> TextClusterFlags = "cairoon_text_to_glyphs_flags"

///|
extern "C" fn image_surface_create_ffi(
  format : Format,
  width : Int,
  height : Int,
) -> Surface = "cairoon_image_surface_create"

///|
#owned(data)
#borrow(status)
extern "C" fn image_surface_create_for_data_ffi(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride : Int,
  status : Ref[Status],
) -> Surface = "cairoon_image_surface_create_for_data"

///|
#borrow(filename, status)
extern "C" fn image_surface_create_from_png_ffi(
  filename : Bytes,
  status : Ref[Status],
) -> Surface = "cairoon_image_surface_create_from_png"

///|
#borrow(status)
extern "C" fn recording_surface_create_ffi(
  content : Content,
  has_extents : Bool,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_recording_surface_create"

///|
#borrow(device, status)
extern "C" fn script_surface_create_ffi(
  device : Device,
  content : Content,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create"

///|
#borrow(device, target, status)
extern "C" fn script_surface_create_for_target_ffi(
  device : Device,
  target : Surface,
  status : Ref[Status],
) -> Surface = "cairoon_script_surface_create_for_target"

///|
#borrow(filename, status)
extern "C" fn pdf_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_pdf_surface_create"

///|
#borrow(status)
extern "C" fn pdf_get_version_count_ffi(status : Ref[Status]) -> Int = "cairoon_pdf_get_version_count"

///|
#borrow(status)
extern "C" fn pdf_get_version_ffi(
  index : Int,
  status : Ref[Status],
) -> PDFVersion = "cairoon_pdf_get_version"

///|
#borrow(status)
extern "C" fn pdf_version_to_string_ffi(
  version : PDFVersion,
  status : Ref[Status],
) -> Bytes = "cairoon_pdf_version_to_string"

///|
#borrow(surface)
extern "C" fn pdf_surface_restrict_to_version_ffi(
  surface : Surface,
  version : PDFVersion,
) -> Status = "cairoon_pdf_surface_restrict_to_version"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_size_ffi(
  surface : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Status = "cairoon_pdf_surface_set_size"

///|
#borrow(surface, value)
extern "C" fn pdf_surface_set_metadata_ffi(
  surface : Surface,
  metadata : PDFMetadata,
  value : Bytes,
) -> Status = "cairoon_pdf_surface_set_metadata"

///|
#borrow(surface, name, value)
extern "C" fn pdf_surface_set_custom_metadata_ffi(
  surface : Surface,
  name : Bytes,
  has_value : Bool,
  value : Bytes,
) -> Status = "cairoon_pdf_surface_set_custom_metadata"

///|
#borrow(surface, label)
extern "C" fn pdf_surface_set_page_label_ffi(
  surface : Surface,
  label : Bytes,
) -> Status = "cairoon_pdf_surface_set_page_label"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_thumbnail_size_ffi(
  surface : Surface,
  width : Int,
  height : Int,
) -> Status = "cairoon_pdf_surface_set_thumbnail_size"

///|
#borrow(surface, title, link_attributes, status)
extern "C" fn pdf_surface_add_outline_bits_ffi(
  surface : Surface,
  parent_id : Int,
  title : Bytes,
  link_attributes : Bytes,
  flags : Int,
  status : Ref[Status],
) -> Int = "cairoon_pdf_surface_add_outline"

///|
#borrow(filename, status)
extern "C" fn svg_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_svg_surface_create"

///|
#borrow(status)
extern "C" fn svg_get_version_count_ffi(status : Ref[Status]) -> Int = "cairoon_svg_get_version_count"

///|
#borrow(status)
extern "C" fn svg_get_version_ffi(
  index : Int,
  status : Ref[Status],
) -> SVGVersion = "cairoon_svg_get_version"

///|
#borrow(status)
extern "C" fn svg_version_to_string_ffi(
  version : SVGVersion,
  status : Ref[Status],
) -> Bytes = "cairoon_svg_version_to_string"

///|
#borrow(surface)
extern "C" fn svg_surface_restrict_to_version_ffi(
  surface : Surface,
  version : SVGVersion,
) -> Status = "cairoon_svg_surface_restrict_to_version"

///|
#borrow(surface, status)
extern "C" fn svg_surface_get_document_unit_ffi(
  surface : Surface,
  status : Ref[Status],
) -> SVGUnit = "cairoon_svg_surface_get_document_unit"

///|
#borrow(surface)
extern "C" fn svg_surface_set_document_unit_ffi(
  surface : Surface,
  unit : SVGUnit,
) -> Status = "cairoon_svg_surface_set_document_unit"

///|
#borrow(filename, status)
extern "C" fn ps_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_ps_surface_create"

///|
#borrow(status)
extern "C" fn ps_get_level_count_ffi(status : Ref[Status]) -> Int = "cairoon_ps_get_level_count"

///|
#borrow(status)
extern "C" fn ps_get_level_ffi(index : Int, status : Ref[Status]) -> PSLevel = "cairoon_ps_get_level"

///|
#borrow(status)
extern "C" fn ps_level_to_string_ffi(
  level : PSLevel,
  status : Ref[Status],
) -> Bytes = "cairoon_ps_level_to_string"

///|
#borrow(surface)
extern "C" fn ps_surface_restrict_to_level_ffi(
  surface : Surface,
  level : PSLevel,
) -> Status = "cairoon_ps_surface_restrict_to_level"

///|
#borrow(surface, status)
extern "C" fn ps_surface_get_eps_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Bool = "cairoon_ps_surface_get_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_eps_ffi(surface : Surface, eps : Bool) -> Status = "cairoon_ps_surface_set_eps"

///|
#borrow(surface)
extern "C" fn ps_surface_set_size_ffi(
  surface : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Status = "cairoon_ps_surface_set_size"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_setup_ffi(surface : Surface) -> Status = "cairoon_ps_surface_dsc_begin_setup"

///|
#borrow(surface)
extern "C" fn ps_surface_dsc_begin_page_setup_ffi(surface : Surface) -> Status = "cairoon_ps_surface_dsc_begin_page_setup"

///|
#borrow(surface, comment)
extern "C" fn ps_surface_dsc_comment_ffi(
  surface : Surface,
  comment : Bytes,
) -> Status = "cairoon_ps_surface_dsc_comment"

///|
#borrow(surface, status)
extern "C" fn surface_create_similar_ffi(
  surface : Surface,
  content : Content,
  width : Int,
  height : Int,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_similar"

///|
#borrow(surface, status)
extern "C" fn surface_create_similar_image_ffi(
  surface : Surface,
  format : Format,
  width : Int,
  height : Int,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_similar_image"

///|
#borrow(surface, status)
extern "C" fn surface_map_to_image_ffi(
  surface : Surface,
  has_extents : Bool,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  status : Ref[Status],
) -> MappedImageSurface = "cairoon_surface_map_to_image"

///|
extern "C" fn format_stride_for_width_ffi(format : Format, width : Int) -> Int = "cairo_format_stride_for_width"

///|
#borrow(surface)
extern "C" fn surface_status_ffi(surface : Surface) -> Status = "cairoon_surface_status"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_status_ffi(
  surface : MappedImageSurface,
) -> Status = "cairoon_mapped_image_surface_status"

///|
#borrow(surface, mapped)
extern "C" fn surface_unmap_image_ffi(
  surface : Surface,
  mapped : MappedImageSurface,
) -> Status = "cairoon_surface_unmap_image"

///|
#borrow(mapped)
extern "C" fn mapped_image_surface_unmap_ffi(
  mapped : MappedImageSurface,
) -> Status = "cairoon_mapped_image_surface_unmap"

///|
#borrow(surface)
extern "C" fn surface_get_content_ffi(surface : Surface) -> Content = "cairoon_surface_get_content"

///|
#borrow(surface)
extern "C" fn surface_get_type_ffi(surface : Surface) -> SurfaceType = "cairoon_surface_get_type"

///|
#borrow(surface, has_device, status)
extern "C" fn surface_get_device_ffi(
  surface : Surface,
  has_device : Ref[Int],
  status : Ref[Status],
) -> Device = "cairoon_surface_get_device"

///|
#borrow(surface)
extern "C" fn surface_finish_ffi(surface : Surface) -> Status = "cairoon_surface_finish"

///|
#borrow(surface)
extern "C" fn surface_flush_ffi(surface : Surface) -> Status = "cairoon_surface_flush"

///|
#borrow(surface)
extern "C" fn surface_mark_dirty_ffi(surface : Surface) -> Status = "cairoon_surface_mark_dirty"

///|
#borrow(surface)
extern "C" fn surface_mark_dirty_rectangle_ffi(
  surface : Surface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_surface_mark_dirty_rectangle"

///|
#borrow(surface, x0, y0, width, height)
extern "C" fn recording_surface_ink_extents_ffi(
  surface : Surface,
  x0 : Ref[Double],
  y0 : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Status = "cairoon_recording_surface_ink_extents"

///|
#borrow(surface, has_extents, x, y, width, height)
extern "C" fn recording_surface_get_extents_ffi(
  surface : Surface,
  has_extents : Ref[Int],
  x : Ref[Double],
  y : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Status = "cairoon_recording_surface_get_extents"

///|
#borrow(surface)
extern "C" fn surface_set_device_offset_ffi(
  surface : Surface,
  x_offset : Double,
  y_offset : Double,
) -> Status = "cairoon_surface_set_device_offset"

///|
#borrow(surface, x_offset, y_offset)
extern "C" fn surface_get_device_offset_ffi(
  surface : Surface,
  x_offset : Ref[Double],
  y_offset : Ref[Double],
) -> Status = "cairoon_surface_get_device_offset"

///|
#borrow(surface)
extern "C" fn surface_set_device_scale_ffi(
  surface : Surface,
  x_scale : Double,
  y_scale : Double,
) -> Status = "cairoon_surface_set_device_scale"

///|
#borrow(surface, x_scale, y_scale)
extern "C" fn surface_get_device_scale_ffi(
  surface : Surface,
  x_scale : Ref[Double],
  y_scale : Ref[Double],
) -> Status = "cairoon_surface_get_device_scale"

///|
#borrow(surface)
extern "C" fn surface_set_fallback_resolution_ffi(
  surface : Surface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Status = "cairoon_surface_set_fallback_resolution"

///|
#borrow(surface, x_pixels_per_inch, y_pixels_per_inch)
extern "C" fn surface_get_fallback_resolution_ffi(
  surface : Surface,
  x_pixels_per_inch : Ref[Double],
  y_pixels_per_inch : Ref[Double],
) -> Status = "cairoon_surface_get_fallback_resolution"

///|
#borrow(surface, status)
extern "C" fn surface_has_show_text_glyphs_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Bool = "cairoon_surface_has_show_text_glyphs"

///|
#borrow(surface)
extern "C" fn surface_copy_page_ffi(surface : Surface) -> Status = "cairoon_surface_copy_page"

///|
#borrow(surface)
extern "C" fn surface_show_page_ffi(surface : Surface) -> Status = "cairoon_surface_show_page"

///|
#borrow(surface, filename)
extern "C" fn surface_write_to_png_ffi(
  surface : Surface,
  filename : Bytes,
) -> Status = "cairoon_surface_write_to_png"

///|
#borrow(surface, mime_type, data)
extern "C" fn surface_set_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
  data : Bytes,
) -> Status = "cairoon_surface_set_mime_data"

///|
#borrow(surface, mime_type)
extern "C" fn surface_clear_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
) -> Status = "cairoon_surface_clear_mime_data"

///|
#borrow(surface, mime_type, has_data, status)
extern "C" fn surface_get_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
  has_data : Ref[Int],
  status : Ref[Status],
) -> Bytes = "cairoon_surface_get_mime_data"

///|
#borrow(surface, mime_type, status)
extern "C" fn surface_supports_mime_type_ffi(
  surface : Surface,
  mime_type : Bytes,
  status : Ref[Status],
) -> Bool = "cairoon_surface_supports_mime_type"

///|
#borrow(surface)
extern "C" fn image_surface_get_width_ffi(surface : Surface) -> Int = "cairoon_image_surface_get_width"

///|
#borrow(surface)
extern "C" fn image_surface_get_height_ffi(surface : Surface) -> Int = "cairoon_image_surface_get_height"

///|
#borrow(surface)
extern "C" fn image_surface_get_stride_ffi(surface : Surface) -> Int = "cairoon_image_surface_get_stride"

///|
#borrow(surface)
extern "C" fn image_surface_get_format_ffi(surface : Surface) -> Format = "cairoon_image_surface_get_format"

///|
#borrow(surface)
extern "C" fn image_surface_copy_data_ffi(surface : Surface) -> Bytes = "cairoon_image_surface_copy_data"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_flush_ffi(
  surface : MappedImageSurface,
) -> Status = "cairoon_mapped_image_surface_flush"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_width_ffi(
  surface : MappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_width"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_height_ffi(
  surface : MappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_height"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_stride_ffi(
  surface : MappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_stride"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_format_ffi(
  surface : MappedImageSurface,
) -> Format = "cairoon_mapped_image_surface_get_format"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_copy_data_ffi(
  surface : MappedImageSurface,
) -> Bytes = "cairoon_mapped_image_surface_copy_data"

///|
#borrow(surface, status)
extern "C" fn surface_get_font_options_ffi(
  surface : Surface,
  status : Ref[Status],
) -> FontOptions = "cairoon_surface_get_font_options"

///|
#borrow(surface)
extern "C" fn context_create_ffi(surface : Surface) -> Context = "cairoon_context_create"

///|
#borrow(surface, status)
extern "C" fn context_create_for_mapped_image_ffi(
  surface : MappedImageSurface,
  status : Ref[Status],
) -> Context = "cairoon_context_create_for_mapped_image"

///|
#borrow(ctx)
extern "C" fn context_status_ffi(ctx : Context) -> Status = "cairoon_context_status"

///|
#borrow(ctx)
extern "C" fn context_save_ffi(ctx : Context) -> Status = "cairoon_context_save"

///|
#borrow(ctx)
extern "C" fn context_restore_ffi(ctx : Context) -> Status = "cairoon_context_restore"

///|
#borrow(ctx, status)
extern "C" fn context_get_target_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_target"

///|
#borrow(ctx, tag_name, attributes)
extern "C" fn context_tag_begin_ffi(
  ctx : Context,
  tag_name : Bytes,
  attributes : Bytes,
) -> Status = "cairoon_context_tag_begin"

///|
#borrow(ctx, tag_name)
extern "C" fn context_tag_end_ffi(ctx : Context, tag_name : Bytes) -> Status = "cairoon_context_tag_end"

///|
#borrow(ctx, status)
extern "C" fn context_get_source_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Pattern = "cairoon_context_get_source"

///|
#borrow(ctx, status)
extern "C" fn context_get_group_target_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_group_target"

///|
#borrow(ctx)
extern "C" fn context_push_group_ffi(ctx : Context) -> Status = "cairoon_context_push_group"

///|
#borrow(ctx)
extern "C" fn context_push_group_with_content_ffi(
  ctx : Context,
  content : Content,
) -> Status = "cairoon_context_push_group_with_content"

///|
#borrow(ctx, status)
extern "C" fn context_pop_group_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Pattern = "cairoon_context_pop_group"

///|
#borrow(ctx)
extern "C" fn context_pop_group_to_source_ffi(ctx : Context) -> Status = "cairoon_context_pop_group_to_source"

///|
#borrow(ctx, status)
extern "C" fn context_get_font_options_ffi(
  ctx : Context,
  status : Ref[Status],
) -> FontOptions = "cairoon_context_get_font_options"

///|
#borrow(ctx, options)
extern "C" fn context_set_font_options_ffi(
  ctx : Context,
  options : FontOptions,
) -> Status = "cairoon_context_set_font_options"

///|
#borrow(ctx, status)
extern "C" fn context_get_font_face_ffi(
  ctx : Context,
  status : Ref[Status],
) -> FontFace = "cairoon_context_get_font_face"

///|
#borrow(ctx, font_face)
extern "C" fn context_set_font_face_ffi(
  ctx : Context,
  font_face : FontFace,
) -> Status = "cairoon_context_set_font_face"

///|
#borrow(ctx)
extern "C" fn context_set_font_face_default_ffi(ctx : Context) -> Status = "cairoon_context_set_font_face_default"

///|
#borrow(ctx, family)
extern "C" fn context_select_font_face_ffi(
  ctx : Context,
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> Status = "cairoon_context_select_font_face"

///|
#borrow(ctx)
extern "C" fn context_set_font_matrix_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_set_font_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_font_matrix_ffi(
  ctx : Context,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_context_get_font_matrix"

///|
#borrow(ctx)
extern "C" fn context_set_font_size_ffi(ctx : Context, size : Double) -> Status = "cairoon_context_set_font_size"

///|
#borrow(ctx, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn context_font_extents_ffi(
  ctx : Context,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Status = "cairoon_context_font_extents"

///|
#borrow(ctx, text)
extern "C" fn context_show_text_ffi(ctx : Context, text : Bytes) -> Status = "cairoon_context_show_text"

///|
#borrow(ctx, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_text_extents_ffi(
  ctx : Context,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_context_text_extents"

///|
#borrow(ctx, text)
extern "C" fn context_text_path_ffi(ctx : Context, text : Bytes) -> Status = "cairoon_context_text_path"

///|
#borrow(ctx, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_glyph_extents_ffi(
  ctx : Context,
  indices : FixedArray[UInt],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_context_glyph_extents"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_glyph_path_ffi(
  ctx : Context,
  indices : FixedArray[UInt],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Status = "cairoon_context_glyph_path"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_show_glyphs_ffi(
  ctx : Context,
  indices : FixedArray[UInt],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Status = "cairoon_context_show_glyphs"

///|
#borrow(ctx, text, indices, xs, ys, cluster_num_bytes, cluster_num_glyphs)
extern "C" fn context_show_text_glyphs_ffi(
  ctx : Context,
  text : Bytes,
  indices : FixedArray[UInt],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  cluster_num_bytes : FixedArray[Int],
  cluster_num_glyphs : FixedArray[Int],
  flags : TextClusterFlags,
) -> Status = "cairoon_context_show_text_glyphs"

///|
#borrow(ctx, status)
extern "C" fn context_get_scaled_font_ffi(
  ctx : Context,
  status : Ref[Status],
) -> ScaledFont = "cairoon_context_get_scaled_font"

///|
#borrow(ctx, scaled_font)
extern "C" fn context_set_scaled_font_ffi(
  ctx : Context,
  scaled_font : ScaledFont,
) -> Status = "cairoon_context_set_scaled_font"

///|
#borrow(ctx)
extern "C" fn context_scale_ffi(
  ctx : Context,
  sx : Double,
  sy : Double,
) -> Status = "cairoon_context_scale"

///|
#borrow(ctx)
extern "C" fn context_translate_ffi(
  ctx : Context,
  tx : Double,
  ty : Double,
) -> Status = "cairoon_context_translate"

///|
#borrow(ctx)
extern "C" fn context_rotate_ffi(ctx : Context, radians : Double) -> Status = "cairoon_context_rotate"

///|
#borrow(ctx)
extern "C" fn context_transform_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_transform"

///|
#borrow(ctx)
extern "C" fn context_set_matrix_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_set_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_matrix_ffi(
  ctx : Context,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_context_get_matrix"

///|
#borrow(ctx)
extern "C" fn context_identity_matrix_ffi(ctx : Context) -> Status = "cairoon_context_identity_matrix"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_user_to_device_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_user_to_device"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_user_to_device_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_user_to_device_distance"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_device_to_user_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_device_to_user"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_device_to_user_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_device_to_user_distance"

///|
#borrow(ctx)
extern "C" fn context_set_line_width_ffi(
  ctx : Context,
  width : Double,
) -> Status = "cairoon_context_set_line_width"

///|
#borrow(ctx)
extern "C" fn context_get_line_width_ffi(ctx : Context) -> Double = "cairoon_context_get_line_width"

///|
#borrow(ctx)
extern "C" fn context_set_line_cap_ffi(ctx : Context, cap : LineCap) -> Status = "cairoon_context_set_line_cap"

///|
#borrow(ctx)
extern "C" fn context_get_line_cap_ffi(ctx : Context) -> LineCap = "cairoon_context_get_line_cap"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_ffi(
  ctx : Context,
  join : LineJoin,
) -> Status = "cairoon_context_set_line_join"

///|
#borrow(ctx)
extern "C" fn context_get_line_join_ffi(ctx : Context) -> LineJoin = "cairoon_context_get_line_join"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_ffi(
  ctx : Context,
  fill_rule : FillRule,
) -> Status = "cairoon_context_set_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_get_fill_rule_ffi(ctx : Context) -> FillRule = "cairoon_context_get_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_set_operator_ffi(
  ctx : Context,
  operator : Operator,
) -> Status = "cairoon_context_set_operator"

///|
#borrow(ctx)
extern "C" fn context_get_operator_ffi(ctx : Context) -> Operator = "cairoon_context_get_operator"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_ffi(
  ctx : Context,
  antialias : Antialias,
) -> Status = "cairoon_context_set_antialias"

///|
#borrow(ctx)
extern "C" fn context_get_antialias_ffi(ctx : Context) -> Antialias = "cairoon_context_get_antialias"

///|
#borrow(ctx)
extern "C" fn context_set_tolerance_ffi(
  ctx : Context,
  tolerance : Double,
) -> Status = "cairoon_context_set_tolerance"

///|
#borrow(ctx)
extern "C" fn context_get_tolerance_ffi(ctx : Context) -> Double = "cairoon_context_get_tolerance"

///|
#borrow(ctx)
extern "C" fn context_set_miter_limit_ffi(
  ctx : Context,
  limit : Double,
) -> Status = "cairoon_context_set_miter_limit"

///|
#borrow(ctx)
extern "C" fn context_get_miter_limit_ffi(ctx : Context) -> Double = "cairoon_context_get_miter_limit"

///|
#borrow(ctx, dashes)
extern "C" fn context_set_dash_ffi(
  ctx : Context,
  dashes : FixedArray[Double],
  offset : Double,
) -> Status = "cairoon_context_set_dash"

///|
#borrow(ctx)
extern "C" fn context_get_dash_count_ffi(ctx : Context) -> Int = "cairoon_context_get_dash_count"

///|
#borrow(ctx, offset)
extern "C" fn context_get_dash_ffi(
  ctx : Context,
  offset : Ref[Double],
) -> FixedArray[Double] = "cairoon_context_get_dash"

///|
#borrow(ctx)
extern "C" fn context_move_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_move_to"

///|
#borrow(ctx)
extern "C" fn context_rel_move_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_move_to"

///|
#borrow(ctx)
extern "C" fn context_line_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_line_to"

///|
#borrow(ctx)
extern "C" fn context_rel_line_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_line_to"

///|
#borrow(ctx)
extern "C" fn context_curve_to_ffi(
  ctx : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Status = "cairoon_context_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rel_curve_to_ffi(
  ctx : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Status = "cairoon_context_rel_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rectangle_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Status = "cairoon_context_rectangle"

///|
#borrow(ctx)
extern "C" fn context_arc_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc"

///|
#borrow(ctx)
extern "C" fn context_arc_negative_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc_negative"

///|
#borrow(ctx)
extern "C" fn context_close_path_ffi(ctx : Context) -> Status = "cairoon_context_close_path"

///|
#borrow(ctx)
extern "C" fn context_new_path_ffi(ctx : Context) -> Status = "cairoon_context_new_path"

///|
#borrow(ctx)
extern "C" fn context_new_sub_path_ffi(ctx : Context) -> Status = "cairoon_context_new_sub_path"

///|
#borrow(ctx, x, y)
extern "C" fn context_get_current_point_ffi(
  ctx : Context,
  x : Ref[Double],
  y : Ref[Double],
) -> Status = "cairoon_context_get_current_point"

///|
#borrow(ctx, result)
extern "C" fn context_has_current_point_ffi(
  ctx : Context,
  result : Ref[Int],
) -> Status = "cairoon_context_has_current_point"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_flat_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path_flat"

///|
#borrow(ctx, path)
extern "C" fn context_append_path_ffi(ctx : Context, path : Path) -> Status = "cairoon_context_append_path"

///|
#borrow(ctx)
extern "C" fn context_clip_ffi(ctx : Context) -> Status = "cairoon_context_clip"

///|
#borrow(ctx)
extern "C" fn context_clip_preserve_ffi(ctx : Context) -> Status = "cairoon_context_clip_preserve"

///|
#borrow(ctx)
extern "C" fn context_reset_clip_ffi(ctx : Context) -> Status = "cairoon_context_reset_clip"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_clip_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_clip_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_clip_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_clip"

///|
#borrow(ctx, status)
extern "C" fn context_copy_clip_rectangle_list_ffi(
  ctx : Context,
  status : Ref[Status],
) -> FixedArray[Double] = "cairoon_context_copy_clip_rectangle_list"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_fill_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_fill_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_stroke_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_stroke_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_path_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_path_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_fill_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_fill"

///|
#borrow(ctx, result)
extern "C" fn context_in_stroke_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_stroke"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgb_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_context_set_source_rgb"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgba_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_context_set_source_rgba"

///|
#borrow(ctx, pattern)
extern "C" fn context_set_source_ffi(
  ctx : Context,
  pattern : Pattern,
) -> Status = "cairoon_context_set_source"

///|
#borrow(ctx)
extern "C" fn context_paint_ffi(ctx : Context) -> Status = "cairoon_context_paint"

///|
#borrow(ctx)
extern "C" fn context_paint_with_alpha_ffi(
  ctx : Context,
  alpha : Double,
) -> Status = "cairoon_context_paint_with_alpha"

///|
#borrow(ctx, pattern)
extern "C" fn context_mask_ffi(ctx : Context, pattern : Pattern) -> Status = "cairoon_context_mask"

///|
#borrow(ctx, surface)
extern "C" fn context_mask_surface_ffi(
  ctx : Context,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_mask_surface"

///|
#borrow(ctx)
extern "C" fn context_fill_ffi(ctx : Context) -> Status = "cairoon_context_fill"

///|
#borrow(ctx)
extern "C" fn context_fill_preserve_ffi(ctx : Context) -> Status = "cairoon_context_fill_preserve"

///|
#borrow(ctx)
extern "C" fn context_stroke_ffi(ctx : Context) -> Status = "cairoon_context_stroke"

///|
#borrow(ctx)
extern "C" fn context_stroke_preserve_ffi(ctx : Context) -> Status = "cairoon_context_stroke_preserve"

///|
#borrow(ctx)
extern "C" fn context_copy_page_ffi(ctx : Context) -> Status = "cairoon_context_copy_page"

///|
#borrow(ctx)
extern "C" fn context_show_page_ffi(ctx : Context) -> Status = "cairoon_context_show_page"

///|
extern "C" fn pattern_create_rgb_ffi(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern = "cairoon_pattern_create_rgb"

///|
extern "C" fn pattern_create_rgba_ffi(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern = "cairoon_pattern_create_rgba"

///|
extern "C" fn pattern_create_linear_ffi(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> Pattern = "cairoon_pattern_create_linear"

///|
extern "C" fn pattern_create_radial_ffi(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> Pattern = "cairoon_pattern_create_radial"

///|
extern "C" fn pattern_create_mesh_ffi() -> Pattern = "cairoon_pattern_create_mesh"

///|
#borrow(surface)
extern "C" fn pattern_create_for_surface_ffi(surface : Surface) -> Pattern = "cairoon_pattern_create_for_surface"

///|
#borrow(pattern)
extern "C" fn pattern_status_ffi(pattern : Pattern) -> Status = "cairoon_pattern_status"

///|
#borrow(pattern, status)
extern "C" fn pattern_get_surface_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> Surface = "cairoon_pattern_get_surface"

///|
#borrow(pattern)
extern "C" fn pattern_get_extend_ffi(pattern : Pattern) -> Extend = "cairoon_pattern_get_extend"

///|
#borrow(pattern)
extern "C" fn pattern_set_extend_ffi(
  pattern : Pattern,
  extend : Extend,
) -> Status = "cairoon_pattern_set_extend"

///|
#borrow(pattern)
extern "C" fn pattern_get_filter_ffi(pattern : Pattern) -> Filter = "cairoon_pattern_get_filter"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_ffi(
  pattern : Pattern,
  filter : Filter,
) -> Status = "cairoon_pattern_set_filter"

///|
#borrow(pattern)
extern "C" fn pattern_get_dither_ffi(pattern : Pattern) -> Dither = "cairoon_pattern_get_dither"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_ffi(
  pattern : Pattern,
  dither : Dither,
) -> Status = "cairoon_pattern_set_dither"

///|
#borrow(pattern, xx, yx, xy, yy, x0, y0)
extern "C" fn pattern_get_matrix_ffi(
  pattern : Pattern,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_pattern_get_matrix"

///|
#borrow(pattern)
extern "C" fn pattern_set_matrix_ffi(
  pattern : Pattern,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_pattern_set_matrix"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn pattern_get_rgba_ffi(
  pattern : Pattern,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_pattern_get_rgba"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgb_ffi(
  pattern : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_pattern_add_color_stop_rgb"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgba_ffi(
  pattern : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_pattern_add_color_stop_rgba"

///|
#borrow(pattern, count)
extern "C" fn pattern_get_color_stop_count_ffi(
  pattern : Pattern,
  count : Ref[Int],
) -> Status = "cairoon_pattern_get_color_stop_count"

///|
#borrow(pattern, offset, red, green, blue, alpha)
extern "C" fn pattern_get_color_stop_rgba_ffi(
  pattern : Pattern,
  index : Int,
  offset : Ref[Double],
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_pattern_get_color_stop_rgba"

///|
#borrow(pattern, x0, y0, x1, y1)
extern "C" fn pattern_get_linear_points_ffi(
  pattern : Pattern,
  x0 : Ref[Double],
  y0 : Ref[Double],
  x1 : Ref[Double],
  y1 : Ref[Double],
) -> Status = "cairoon_pattern_get_linear_points"

///|
#borrow(pattern, cx0, cy0, radius0, cx1, cy1, radius1)
extern "C" fn pattern_get_radial_circles_ffi(
  pattern : Pattern,
  cx0 : Ref[Double],
  cy0 : Ref[Double],
  radius0 : Ref[Double],
  cx1 : Ref[Double],
  cy1 : Ref[Double],
  radius1 : Ref[Double],
) -> Status = "cairoon_pattern_get_radial_circles"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_begin_patch_ffi(pattern : Pattern) -> Status = "cairoon_mesh_pattern_begin_patch"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_end_patch_ffi(pattern : Pattern) -> Status = "cairoon_mesh_pattern_end_patch"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_move_to_ffi(
  pattern : Pattern,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_move_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_line_to_ffi(
  pattern : Pattern,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_line_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_curve_to_ffi(
  pattern : Pattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Status = "cairoon_mesh_pattern_curve_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_control_point_ffi(
  pattern : Pattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_set_control_point"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgb_ffi(
  pattern : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_mesh_pattern_set_corner_color_rgb"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgba_ffi(
  pattern : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_mesh_pattern_set_corner_color_rgba"

///|
#borrow(pattern, count)
extern "C" fn mesh_pattern_get_patch_count_ffi(
  pattern : Pattern,
  count : Ref[Int],
) -> Status = "cairoon_mesh_pattern_get_patch_count"

///|
#borrow(pattern, status)
extern "C" fn mesh_pattern_get_path_ffi(
  pattern : Pattern,
  patch_num : Int,
  status : Ref[Status],
) -> Path = "cairoon_mesh_pattern_get_path"

///|
#borrow(pattern, x, y)
extern "C" fn mesh_pattern_get_control_point_ffi(
  pattern : Pattern,
  patch_num : Int,
  point_num : Int,
  x : Ref[Double],
  y : Ref[Double],
) -> Status = "cairoon_mesh_pattern_get_control_point"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn mesh_pattern_get_corner_color_rgba_ffi(
  pattern : Pattern,
  patch_num : Int,
  corner_num : Int,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_mesh_pattern_get_corner_color_rgba"

///|
extern "C" fn region_create_ffi() -> Region = "cairoon_region_create"

///|
extern "C" fn region_create_rectangle_ffi(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Region = "cairoon_region_create_rectangle"

///|
#borrow(xs, ys, widths, heights, status)
extern "C" fn region_create_rectangles_ffi(
  xs : FixedArray[Int],
  ys : FixedArray[Int],
  widths : FixedArray[Int],
  heights : FixedArray[Int],
  status : Ref[Status],
) -> Region = "cairoon_region_create_rectangles"

///|
#borrow(region)
extern "C" fn region_copy_ffi(region : Region) -> Region = "cairoon_region_copy"

///|
#borrow(region)
extern "C" fn region_status_ffi(region : Region) -> Status = "cairoon_region_status"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_extents_ffi(
  region : Region,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Status = "cairoon_region_get_extents"

///|
#borrow(region)
extern "C" fn region_num_rectangles_ffi(region : Region) -> Int = "cairoon_region_num_rectangles"

///|
#borrow(region, x, y, width, height)
extern "C" fn region_get_rectangle_ffi(
  region : Region,
  index : Int,
  x : Ref[Int],
  y : Ref[Int],
  width : Ref[Int],
  height : Ref[Int],
) -> Status = "cairoon_region_get_rectangle"

///|
#borrow(region)
extern "C" fn region_is_empty_ffi(region : Region) -> Bool = "cairoon_region_is_empty"

///|
#borrow(region)
extern "C" fn region_contains_point_ffi(
  region : Region,
  x : Int,
  y : Int,
) -> Bool = "cairoon_region_contains_point"

///|
#borrow(region)
extern "C" fn region_contains_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> RegionOverlap = "cairoon_region_contains_rectangle"

///|
#borrow(region, other)
extern "C" fn region_equal_ffi(region : Region, other : Region) -> Bool = "cairoon_region_equal"

///|
#borrow(region)
extern "C" fn region_translate_ffi(
  region : Region,
  dx : Int,
  dy : Int,
) -> Status = "cairoon_region_translate"

///|
#borrow(region, other)
extern "C" fn region_intersect_ffi(region : Region, other : Region) -> Status = "cairoon_region_intersect"

///|
#borrow(region)
extern "C" fn region_intersect_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_intersect_rectangle"

///|
#borrow(region, other)
extern "C" fn region_subtract_ffi(region : Region, other : Region) -> Status = "cairoon_region_subtract"

///|
#borrow(region)
extern "C" fn region_subtract_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_subtract_rectangle"

///|
#borrow(region, other)
extern "C" fn region_union_ffi(region : Region, other : Region) -> Status = "cairoon_region_union"

///|
#borrow(region)
extern "C" fn region_union_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_union_rectangle"

///|
#borrow(region, other)
extern "C" fn region_xor_ffi(region : Region, other : Region) -> Status = "cairoon_region_xor"

///|
#borrow(region)
extern "C" fn region_xor_rectangle_ffi(
  region : Region,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Status = "cairoon_region_xor_rectangle"
