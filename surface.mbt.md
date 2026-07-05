# Surface And Image Surfaces

`Surface` is the shared MoonBit owner for Cairo surface handles. pycairo uses
backend subclasses such as `ImageSurface`, `PDFSurface`, and `RecordingSurface`;
cairoon keeps one opaque `Surface` type and exposes backend-specific
constructors and methods on it.

Surface methods that can observe a Cairo status raise `CairoError`. Image data
APIs are available on `Surface` because cairoon does not model CPython-style
subclasses; callers should use them only with image-compatible surfaces.

## Scoped Finish

`with_finished` mirrors pycairo's `with surface:` behavior: it runs a scoped
operation and calls `finish()` whether the operation succeeds or raises a Cairo
error.

```mbt check
///|
test "surface docs: scoped finish" {
  let surface = Surface::image(Argb32, 1, 1)
  let len = surface.with_finished(() => surface.copy_data().length())
  inspect(len, content="4")
  debug_inspect(surface.status(), content="SurfaceFinished")
}
```

## Image Surface Basics

`Surface::image` creates an image surface. The byte order follows Cairo's native
ARGB32 memory layout for the current platform.

```mbt check
///|
test "surface docs: image surface properties and copied bytes" {
  let surface = Surface::image(Argb32, 2, 1)
  debug_inspect(surface.get_type(), content="SurfaceTypeImage")
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  debug_inspect(surface.get_format(), content="Argb32")
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="1")
  inspect(surface.get_stride(), content="8")

  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()

  let data = surface.copy_data()
  inspect(data.length(), content="8")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}
```

## Caller-Owned Pixel Buffers

`Surface::image_for_data` maps pycairo's `ImageSurface.create_for_data`. Cairo
keeps a pointer to the mutable byte buffer, and cairoon retains that MoonBit
buffer until the surface is finalized.

```mbt check
///|
test "surface docs: buffer backed image data shares storage" {
  let stride = Format::stride_for_width(Argb32, 1)
  let pixels : FixedArray[Byte] = FixedArray::make(stride, b'\x00')
  let surface = Surface::image_for_data(pixels, Argb32, 1, 1, stride~)

  let data = surface.get_data()
  data.set(0, b'\x00')
  data.set(1, b'\x80')
  data.set(2, b'\xff')
  data.set(3, b'\xff')
  surface.mark_dirty()
  surface.flush()

  inspect(pixels[0].to_int(), content="0")
  inspect(pixels[1].to_int(), content="128")
  inspect(pixels[2].to_int(), content="255")
  inspect(pixels[3].to_int(), content="255")
  inspect(surface.copy_data() == Bytes::from_array(pixels), content="true")
}
```

## Similar And Subsurfaces

`create_similar` and `create_similar_image` follow Cairo's compatible-surface
constructors. `create_similar_raw` mirrors pycairo's C-int `Content` parsing for
ported code. `create_for_rectangle` creates a child surface that clips and
translates drawing into its parent; cairoon retains the parent wrapper while
the child can reference it.

```mbt check
///|
test "surface docs: similar images and rectangular child surfaces" {
  let parent = Surface::image(Argb32, 4, 4)

  let similar = parent.create_similar(ContentColor, 2, 2)
  debug_inspect(similar.get_content(), content="ContentColor")

  let raw_similar = parent.create_similar_raw(0x1000, 1, 1)
  inspect(raw_similar.get_content_raw(), content="4096")
  debug_inspect(raw_similar.get_content(), content="ContentColor")

  let image = parent.create_similar_image(Rgb24, 2, 3)
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_format(), content="Rgb24")
  inspect(image.get_height(), content="3")

  let child = parent.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
  let ctx = Context::new(child)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.paint()
  child.flush()

  let bytes = parent.copy_data()
  let stride = parent.get_stride()
  inspect(bytes[stride + 4].to_int(), content="255")
  inspect(bytes[stride + 5].to_int(), content="0")
  inspect(bytes[stride + 6].to_int(), content="0")
  inspect(bytes[stride + 7].to_int(), content="255")
  inspect(bytes[0].to_int(), content="0")
}
```

## Mapped Images

`map_to_image` returns a `MappedImageSurface` wrapper. Use either
`Surface::unmap_image`, `MappedImageSurface::unmap`, or
`MappedImageSurface::with_unmapped` exactly once to upload changes back to the
original surface. `with_unmapped` mirrors pycairo's mapped-image context
manager and unmaps after success or Cairo errors.

```mbt check
///|
test "surface docs: mapped image extents update selected pixels" {
  let surface = Surface::image(Rgb24, 2, 1)
  let mapped = surface.map_to_image(
    extents=Some(RectangleInt::new(x=0, y=0, width=1, height=1)),
  )
  let ctx = Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  mapped.unmap()
  surface.flush()

  let data = surface.copy_data()
  inspect(data.length(), content="8")
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
  inspect(data[4].to_int(), content="0")
}
```

```mbt check
///|
test "surface docs: scoped mapped-image unmap" {
  let surface = Surface::image(Rgb24, 1, 1)
  let mapped = surface.map_to_image()
  mapped.with_unmapped(() => {
    let ctx = Context::new_for_mapped_image(mapped)
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.paint()
  })
  surface.flush()

  let data = surface.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}
```

## PNG And MIME Data

Filename APIs accept MoonBit `String` values, encode them to UTF-8, and reject
embedded NUL before crossing into Cairo. MIME data is copied into Cairo-owned
storage on set and copied back into MoonBit-owned `Bytes` on get.

```mbt check
///|
test "surface docs: png roundtrip and mime bytes" {
  let path = "/tmp/cairoon_surface_docs_roundtrip.png"
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  surface.write_to_png(path)

  let loaded = Surface::image_from_png(path)
  inspect(loaded.get_width(), content="1")
  inspect(loaded.get_height(), content="1")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")

  let jpeg = @utf8.encode("encoded-jpeg-bytes")
  surface.set_mime_data(MIME_TYPE_JPEG, Some(jpeg))
  match surface.get_mime_data(MIME_TYPE_JPEG) {
    Some(bytes) => inspect(bytes == jpeg, content="true")
    None => fail("expected MIME data")
  }
  surface.set_mime_data(MIME_TYPE_JPEG, None)
  inspect(surface.get_mime_data(MIME_TYPE_JPEG) is None, content="true")
}
```

## Checked Errors

Invalid values are surfaced as checked `CairoError` suberrors rather than
leaving callers to inspect `status()` after the fact.

```mbt check
///|
test "surface docs: invalid inputs raise checked cairo errors" {
  let surface = Surface::image(Argb32, 2, 2)

  match run_cairo(() => surface.create_similar(ContentColor, -1, 1)) {
    Err(CairoInvalidArgument(InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }

  match run_cairo(() => surface.set_device_scale(0.0, 1.0)) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  match run_cairo(() => surface.write_to_png("/tmp/cairoon\u{0}bad.png")) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}
```
