///|
#borrow(call_writer)
#owned(writer)
extern "C" fn test_stream_surface_attach_failure_ffi(
  kind : Int,
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
) -> Int = "cairoon_test_stream_surface_attach_failure"

///|
#borrow(call_writer)
#owned(writer)
extern "C" fn test_stream_device_attach_failure_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Int) -> Int],
  writer : (Bytes) -> Int,
) -> Int = "cairoon_test_stream_device_attach_failure"

///|
fn link_production_stream_support() -> Unit raise @cairoon.CairoError {
  // Pull the production stream archive member before the test C oracle.
  let surface = @cairoon.Surface::pdf_stream(1.0, 1.0, fn(_) { Success })
  surface.finish()
}

///|
test "stream surface attach failure keeps writer alive through producer destroy" {
  ignore(@oracle_native.oracle_native_anchor())
  link_production_stream_support()
  for kind in 0..<3 {
    let armed = Ref(false)
    let destroy_calls = Ref(0)
    let destroy_bytes = Ref(0)
    let status = test_stream_surface_attach_failure_ffi(
      kind,
      fn(chunk, writer) { writer(chunk) },
      fn(chunk) {
        if chunk.length() == 0 {
          armed.val = true
        } else if armed.val {
          destroy_calls.val += 1
          destroy_bytes.val += chunk.length()
        }
        0
      },
    )
    inspect(status, content="1")
    inspect(armed.val, content="true")
    inspect(destroy_calls.val > 0, content="true")
    inspect(destroy_bytes.val > 0, content="true")
  }
}

///|
test "script device attach failure releases writer after bare producer destroy" {
  ignore(@oracle_native.oracle_native_anchor())
  link_production_stream_support()
  let armed = Ref(false)
  let status = test_stream_device_attach_failure_ffi(
    fn(chunk, writer) { writer(chunk) },
    fn(chunk) {
      if chunk.length() == 0 {
        armed.val = true
      }
      0
    },
  )
  inspect(status, content="1")
  inspect(armed.val, content="true")
}
