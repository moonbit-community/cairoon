///|
enum RasterTransitionMode {
  Cleared
  ReleaseOnly
  AcquireOnly
  AcquireRelease
  DynamicAcquireRelease
  FailedAcquire
}

///|
struct RasterTransitionProbe {
  last_acquire_token : Ref[Int]
  last_release_token : Ref[Int]
  acquire_calls : Ref[Int]
  release_calls : Ref[Int]
}

///|
fn RasterTransitionProbe::new() -> RasterTransitionProbe {
  {
    last_acquire_token: Ref(-1),
    last_release_token: Ref(-1),
    acquire_calls: Ref(0),
    release_calls: Ref(0),
  }
}

///|
fn RasterTransitionMode::has_acquire(self : RasterTransitionMode) -> Bool {
  match self {
    AcquireOnly | AcquireRelease | DynamicAcquireRelease | FailedAcquire => true
    Cleared | ReleaseOnly => false
  }
}

///|
fn RasterTransitionMode::has_release(self : RasterTransitionMode) -> Bool {
  match self {
    ReleaseOnly | AcquireRelease | DynamicAcquireRelease | FailedAcquire => true
    Cleared | AcquireOnly => false
  }
}

///|
fn install_raster_transition_mode(
  pattern : @cairoon.Pattern,
  mode : RasterTransitionMode,
  token : Int,
  source : @cairoon.Surface,
  failed_source : @cairoon.Surface,
  probe : RasterTransitionProbe,
) -> Unit raise @cairoon.CairoError {
  let acquire : (@cairoon.Surface, @cairoon.RectangleInt) -> @cairoon.Surface = fn(
    target,
    extents,
  ) {
    probe.acquire_calls.val += 1
    probe.last_acquire_token.val = token
    match mode {
      DynamicAcquireRelease => {
        let dynamic_source = try! target.create_similar_image(
          Argb32,
          extents.width,
          extents.height,
        )
        try! dynamic_source.set_device_offset(
          extents.x.to_double(),
          extents.y.to_double(),
        )
        let source_ctx = try! @cairoon.Context::new(dynamic_source)
        try! source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
        try! source_ctx.paint()
        dynamic_source
      }
      FailedAcquire => failed_source
      Cleared | ReleaseOnly | AcquireOnly | AcquireRelease => source
    }
  }
  let release : (@cairoon.Surface) -> Unit = fn(surface) {
    probe.release_calls.val += 1
    probe.last_release_token.val = token
    ignore(try! surface.get_width())
  }
  match mode {
    Cleared =>
      if token % 2 == 0 {
        pattern.raster_clear_callbacks()
      } else {
        pattern.raster_clear_acquire()
      }
    ReleaseOnly => pattern.raster_set_callbacks(release=Some(release))
    AcquireOnly => pattern.raster_set_callbacks(acquire=Some(acquire))
    AcquireRelease => pattern.raster_set_acquire(acquire, release=Some(release))
    DynamicAcquireRelease =>
      pattern.raster_set_callbacks(acquire=Some(acquire), release=Some(release))
    FailedAcquire => pattern.raster_set_acquire(acquire, release=Some(release))
  }
}

///|
fn expect_raster_transition_shape(
  pattern : @cairoon.Pattern,
  mode : RasterTransitionMode,
) -> Unit raise {
  let (acquire, release) = pattern.raster_get_callbacks()
  inspect(acquire is Some(_), content="\{mode.has_acquire()}")
  inspect(release is Some(_), content="\{mode.has_release()}")
  inspect(
    pattern.raster_get_acquire() is Some(_),
    content="\{mode.has_acquire()}",
  )
}

///|
fn expect_raster_transition_owners_zero(
  source : @cairoon.Surface,
  failed_source : @cairoon.Surface,
) -> Unit raise {
  inspect(test_raster_surface_owner_count_ffi(source), content="0")
  inspect(test_raster_surface_owner_count_ffi(failed_source), content="0")
}

///|
fn expect_raster_transition_red_pixel(surface : @cairoon.Surface) -> Unit raise {
  surface.flush()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
fn exercise_raster_transition_mode(
  pattern : @cairoon.Pattern,
  mode : RasterTransitionMode,
  token : Int,
  source : @cairoon.Surface,
  failed_source : @cairoon.Surface,
  probe : RasterTransitionProbe,
  successful_paints : Ref[Int],
  failed_paints : Ref[Int],
  release_only_calls : Ref[Int],
) -> Unit raise {
  expect_raster_transition_shape(pattern, mode)
  let acquire_calls_before = probe.acquire_calls.val
  let release_calls_before = probe.release_calls.val
  match mode {
    Cleared => ()
    ReleaseOnly => {
      let (_, release) = pattern.raster_get_callbacks()
      match release {
        Some(release) => release(source)
        None => @test.fail("expected release-only callback")
      }
      inspect(probe.acquire_calls.val, content="\{acquire_calls_before}")
      inspect(probe.release_calls.val > release_calls_before, content="true")
      inspect(probe.last_release_token.val, content="\{token}")
      release_only_calls.val += 1
    }
    AcquireOnly | AcquireRelease | DynamicAcquireRelease | FailedAcquire => {
      let target = @cairoon.Surface::image(Argb32, 3, 3)
      let ctx = @cairoon.Context::new(target)
      let result = @cairoon.run_cairo(() => {
        ctx.set_source(pattern)
        ctx.paint()
      })
      inspect(probe.acquire_calls.val > acquire_calls_before, content="true")
      inspect(probe.last_acquire_token.val, content="\{token}")
      if mode is FailedAcquire {
        match result {
          Err(CairoMemoryError(NoMemory, _)) => ()
          _ => @test.fail("expected NoMemory from failed raster acquire")
        }
        inspect(probe.release_calls.val, content="\{release_calls_before}")
        failed_paints.val += 1
      } else {
        match result {
          Ok(_) => ()
          _ => @test.fail("expected successful raster transition paint")
        }
        expect_raster_transition_red_pixel(target)
        if mode.has_release() {
          inspect(
            probe.release_calls.val > release_calls_before,
            content="true",
          )
          inspect(probe.last_release_token.val, content="\{token}")
        } else {
          inspect(probe.release_calls.val, content="\{release_calls_before}")
        }
        successful_paints.val += 1
      }
    }
  }
  expect_raster_transition_owners_zero(source, failed_source)
}

///|
test "raster source exhaustive callback transition matrix balances owners" {
  let source = @cairoon.Surface::image(Argb32, 3, 3)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  let failed_source = @cairoon.Surface::image(Argb32, 1, 1)
  failed_source.finish()
  expect_raster_transition_owners_zero(source, failed_source)

  let modes = [
    Cleared,
    ReleaseOnly,
    AcquireOnly,
    AcquireRelease,
    DynamicAcquireRelease,
    FailedAcquire,
  ]
  let transition_count = Ref(0)
  let successful_paints = Ref(0)
  let failed_paints = Ref(0)
  let release_only_calls = Ref(0)
  for source_index, source_mode in modes {
    for destination_index, destination_mode in modes {
      let pattern = @cairoon.Pattern::raster_source(ContentColorAlpha, 3, 3)
      let probe = RasterTransitionProbe::new()
      let source_token = source_index * 100 + destination_index * 2
      install_raster_transition_mode(
        pattern, source_mode, source_token, source, failed_source, probe,
      )
      exercise_raster_transition_mode(
        pattern, source_mode, source_token, source, failed_source, probe, successful_paints,
        failed_paints, release_only_calls,
      )

      let destination_token = source_token + 1
      install_raster_transition_mode(
        pattern, destination_mode, destination_token, source, failed_source, probe,
      )
      exercise_raster_transition_mode(
        pattern, destination_mode, destination_token, source, failed_source, probe,
        successful_paints, failed_paints, release_only_calls,
      )
      pattern.raster_clear_callbacks()
      expect_raster_transition_owners_zero(source, failed_source)
      transition_count.val += 1
    }
  }

  inspect(transition_count.val, content="36")
  inspect(successful_paints.val, content="36")
  inspect(failed_paints.val, content="12")
  inspect(release_only_calls.val, content="12")
  expect_raster_transition_owners_zero(source, failed_source)
}
