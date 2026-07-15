# Status, Errors, And Version Information

cairoon reports failing Cairo operations through the `CairoError` suberror
family. `Status` remains available for diagnostics and callback return values,
but users do not need to poll object status after each checked method.

## Compile-Time And Runtime Versions

`CAIRO_VERSION*` constants describe the Cairo headers used when cairoon's link
configuration was generated. `cairo_version()` and
`cairo_version_string()` query the linked Cairo library at runtime. A release
build should use matching headers and library versions.

```mbt check
///|
test "status docs: compile-time and runtime versions agree" {
  let encoded = CAIRO_VERSION_MAJOR * 10000 +
    CAIRO_VERSION_MINOR * 100 +
    CAIRO_VERSION_MICRO
  inspect(CAIRO_VERSION == encoded, content="true")
  inspect(cairo_version() == CAIRO_VERSION, content="true")
  inspect(cairo_version_string() == CAIRO_VERSION_STRING, content="true")
  inspect(CAIRO_VERSION_STRING.contains("."), content="true")
}
```

## Status Diagnostics

`Success` is the only successful status. `Status::message` delegates to Cairo
and returns a copied MoonBit string, so it remains valid independently of any
Cairo object.

```mbt check
///|
test "status docs: status predicates and messages" {
  let success : Status = Success
  let invalid : Status = InvalidMatrix
  inspect(success.is_success(), content="true")
  inspect(invalid.is_success(), content="false")
  inspect(success.message().length() > 0, content="true")
  inspect(invalid.message().length() > 0, content="true")
}
```

## Error Classes

`check_status` applies cairoon's stable mapping: allocation failures become
`CairoMemoryError`, stream and PNG failures become `CairoIOError`, caller
validation failures become `CairoInvalidArgument`, and other Cairo failures
remain `CairoError`.

```mbt check
///|
test "status docs: status values map to typed suberrors" {
  match run_cairo(() => check_status(NoMemory)) {
    Err(CairoMemoryError(NoMemory, _)) => ()
    _ => @test.fail("expected CairoMemoryError")
  }
  match run_cairo(() => check_status(WriteError)) {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected CairoIOError")
  }
  match run_cairo(() => check_status(InvalidMatrix)) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected CairoInvalidArgument")
  }
  match run_cairo(() => check_status(SurfaceFinished)) {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected CairoError")
  }
}
```

`run_cairo` is the non-raising adapter for application boundaries that prefer
an explicit `Result`.

```mbt check
///|
test "status docs: run_cairo preserves success and errors" {
  debug_inspect(run_cairo(() => 42), content="Ok(42)")
  match run_cairo(() => check_status(ReadError)) {
    Err(CairoIOError(ReadError, message)) =>
      inspect(message.length() > 0, content="true")
    _ => @test.fail("expected checked read error")
  }
}
```

## Feature And Protocol Constants

The `HAS_*` constants describe features detected in the configured Cairo
headers. MIME names, PDF outline roots, and tag names are copied from Cairo's
public constants and can be passed directly to the corresponding checked API.

```mbt check
///|
test "status docs: portable feature and protocol constants" {
  inspect(HAS_IMAGE_SURFACE, content="true")
  inspect(MIME_TYPE_JPEG, content="image/jpeg")
  inspect(MIME_TYPE_PNG, content="image/png")
  inspect(PDF_OUTLINE_ROOT, content="0")
  inspect(TAG_DEST, content="cairo.dest")
  inspect(TAG_LINK, content="Link")
  inspect(TAG_CONTENT, content="cairo.content")
}
```
