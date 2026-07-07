///|
test "backend stream callback multi-seed fuzz covers status and reader edges" {
  let write_successes = Ref(0)
  let write_failures = Ref(0)
  let invalid_status_failures = Ref(0)
  let reader_successes = Ref(0)
  let reader_failures = Ref(0)
  let total_chunks = Ref(0)
  let total_bytes = Ref(0)

  for seed_start in [23, 311, 1237, 4001] {
    let seed = Ref(seed_start)
    for step in 0..<24 {
      let value = next_lifetime_stream_fuzz_seed(seed)
      let op = (value + step) % 7
      let status = lifetime_stream_fuzz_status(value / 7 + step)
      if op < 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_vector_writer(
          op, status,
        )
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == @cairoon.Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == @cairoon.LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_png_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == @cairoon.Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == @cairoon.LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 4 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_script_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == @cairoon.Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == @cairoon.LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else {
        let short_read = op == 6
        let (result, chunks, bytes, width, height) = lifetime_stream_fuzz_png_reader(
          short_read,
        )
        total_chunks.val += chunks
        total_bytes.val += bytes
        if short_read {
          expect_lifetime_stream_fuzz_read_error(result, chunks)
          reader_failures.val += 1
        } else {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          inspect(width, content="1")
          inspect(height, content="1")
          reader_successes.val += 1
        }
      }
    }
  }

  inspect(write_successes.val > 0, content="true")
  inspect(write_failures.val > 0, content="true")
  inspect(invalid_status_failures.val > 0, content="true")
  inspect(reader_successes.val > 0, content="true")
  inspect(reader_failures.val > 0, content="true")
  inspect(total_chunks.val > 96, content="true")
  inspect(total_bytes.val > 0, content="true")
}
