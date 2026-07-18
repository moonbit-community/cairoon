///|
fn expect_lifetime_stream_fuzz_distribution(
  actual : FixedArray[Int],
  expected : Array[Int],
) -> Unit raise {
  inspect(actual.length(), content="\{expected.length()}")
  for index in 0..<expected.length() {
    inspect(actual[index], content="\{expected[index]}")
  }
}

///|
test "backend stream callback multi-seed fuzz covers status and reader edges" {
  let write_successes = Ref(0)
  let write_failures = Ref(0)
  let invalid_status_failures = Ref(0)
  let reader_successes = Ref(0)
  let reader_failures = Ref(0)
  let total_chunks = Ref(0)
  let total_bytes = Ref(0)
  let operation_counts = FixedArray::make(7, 0)
  let writer_status_counts = FixedArray::make(15, 0)

  for seed_start in [23, 311, 1237, 4001] {
    let seed = Ref(seed_start)
    for step in 0..<24 {
      let value = next_lifetime_stream_fuzz_seed(seed)
      let op = (value + step) % 7
      operation_counts[op] = operation_counts[op] + 1
      let status_selector = value / 7 + step
      let status_index = status_selector % 3
      let status = lifetime_stream_fuzz_status(status_selector)
      if op < 5 {
        let index = op * 3 + status_index
        writer_status_counts[index] = writer_status_counts[index] + 1
      }
      if op < 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_vector_writer(
          op, status,
        )
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_png_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 4 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_script_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
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

  expect_lifetime_stream_fuzz_distribution(operation_counts, [
    10, 20, 12, 11, 16, 10, 17,
  ])
  expect_lifetime_stream_fuzz_distribution(writer_status_counts, [
    3, 4, 3, 8, 4, 8, 2, 4, 6, 3, 5, 3, 6, 4, 6,
  ])
  inspect(write_successes.val, content="22")
  inspect(write_failures.val, content="47")
  inspect(invalid_status_failures.val, content="26")
  inspect(reader_successes.val, content="10")
  inspect(reader_failures.val, content="17")
  inspect(total_chunks.val > 96, content="true")
  inspect(total_bytes.val > 0, content="true")
}
