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
#owned(reader)
#borrow(status)
extern "C" fn image_surface_create_from_png_stream_ffi(
  call_reader : FuncRef[(Int, (Int) -> Bytes) -> Bytes],
  reader : (Int) -> Bytes,
  status : Ref[Status],
) -> Surface = "cairoon_image_surface_create_from_png_stream"

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
extern "C" fn surface_create_for_rectangle_ffi(
  surface : Surface,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_surface_create_for_rectangle"

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
#borrow(surface, other)
extern "C" fn surface_equal_ffi(surface : Surface, other : Surface) -> Bool = "cairoon_surface_equal"

///|
#borrow(surface)
extern "C" fn surface_hash_ffi(surface : Surface) -> UInt64 = "cairoon_surface_hash"

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
#borrow(surface)
#owned(writer)
extern "C" fn surface_write_to_png_stream_ffi(
  surface : Surface,
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
) -> Status = "cairoon_surface_write_to_png_stream"

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
#borrow(surface, status)
extern "C" fn image_surface_get_width_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_width"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_height_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_height"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_stride_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_stride"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_format_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Format = "cairoon_image_surface_get_format"

///|
#borrow(surface, status)
extern "C" fn image_surface_copy_data_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Bytes = "cairoon_image_surface_copy_data"

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
