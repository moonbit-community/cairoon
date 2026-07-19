#!/usr/bin/env python3
"""Tests for the external-object owner and lifetime evidence gate."""

from __future__ import annotations

import importlib.util
import json
import pathlib
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-external-owners.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_external_owners", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ExternalOwnerCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        (self.root / "src/internal/sample").mkdir(parents=True)
        (self.root / "src/native").mkdir(parents=True)
        self.stress_dir = self.root / "src/tests/lifetime/sample"
        self.stress_dir.mkdir(parents=True)
        (self.root / "scripts/lifetime").mkdir(parents=True)
        (self.root / "src/internal/sample/ffi.mbt").write_text(
            "///|\ntype RawSample\n",
            encoding="utf-8",
        )
        (self.root / "src/native/cairoon_objects.c").write_text(
            """
static void cairoon_sample_finalize(void *self) {
  release_sample(self);
  release_sample_base(self);
}

void *sample_wrap(void) {
  return moonbit_make_external_object(
    cairoon_sample_finalize, sizeof(CairoonSample));
}
""",
            encoding="utf-8",
        )
        (self.stress_dir / "moon.pkg").write_text("", encoding="utf-8")
        self.stress_path = self.stress_dir / "sample_test.mbt"
        self.stress_path.write_text(
            """
#|test "sample allocation stress" { for index in 0..<1000 { stress_sample() } }

fn stress_sample() -> Unit {
  make_sample()
}

test "sample allocation stress" {
  for index in 0..<1000 {
    ignore(index)
    stress_sample()
  }
}
""",
            encoding="utf-8",
        )
        self.ledger_path = self.root / "scripts/lifetime/owners.json"
        self.ledger = {
            "schema_version": 2,
            "minimum_iterations": 1000,
            "owners": [
                {
                    "raw_type": "RawSample",
                    "ffi_path": "src/internal/sample/ffi.mbt",
                    "c_struct": "CairoonSample",
                    "finalizer": "cairoon_sample_finalize",
                    "release_anchors": [
                        "release_sample(self);",
                        "release_sample_base(self);",
                    ],
                    "stress_path": "src/tests/lifetime/sample/sample_test.mbt",
                    "stress_test": "sample allocation stress",
                    "stress_helper": "stress_sample",
                    "allocation_anchor": "make_sample()",
                    "forbidden_stress_anchors": [],
                }
            ],
        }
        self.write_ledger()

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_ledger(self) -> None:
        self.ledger_path.write_text(
            json.dumps(self.ledger, indent=2) + "\n",
            encoding="utf-8",
        )

    def check(self) -> list[str]:
        return self.checker.check_external_owners(self.root, self.ledger_path)

    def test_valid_owner_evidence_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_stress_helper_cannot_use_a_forbidden_release_anchor(self) -> None:
        self.ledger["owners"][0]["forbidden_stress_anchors"] = [
            "release_sample()"
        ]
        self.write_ledger()
        self.stress_path.write_text(
            self.stress_path.read_text(encoding="utf-8").replace(
                "  make_sample()\n}",
                "  make_sample()\n  release_sample()\n}",
                1,
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("forbidden stress anchor" in e for e in errors))

    def test_forbidden_stress_anchors_must_be_unique_trimmed_strings(self) -> None:
        for anchors in (["release_sample()", "release_sample()"], [" "]):
            with self.subTest(anchors=anchors):
                self.ledger["owners"][0]["forbidden_stress_anchors"] = anchors
                self.write_ledger()

                errors = self.check()

                self.assertTrue(
                    any("forbidden_stress_anchors" in e for e in errors)
                )

    def test_new_raw_owner_requires_a_ledger_row(self) -> None:
        path = self.root / "src/public/ffi_extra.mbt"
        path.parent.mkdir(parents=True)
        path.write_text("///|\ntype RawExtra\n", encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("missing ledger owner for RawExtra" in e for e in errors))

    def test_stale_owner_row_is_rejected(self) -> None:
        self.ledger["owners"][0]["raw_type"] = "RawStale"
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("stale ledger owner RawStale" in e for e in errors))

    def test_ffi_declaration_path_is_exact(self) -> None:
        self.ledger["owners"][0]["ffi_path"] = "src/internal/other/ffi.mbt"
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("does not match declaration" in e for e in errors))

    def test_native_finalizer_is_required(self) -> None:
        path = self.root / "src/native/cairoon_objects.c"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                "cairoon_sample_finalize", "cairoon_wrong_finalize"
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("stale native finalizer" in e for e in errors))

    def test_native_allocator_must_pair_struct_and_finalizer(self) -> None:
        path = self.root / "src/native/cairoon_objects.c"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                "sizeof(CairoonSample)", "sizeof(CairoonWrong)"
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("no external-object allocation pairs" in e for e in errors))

    def test_raw_owner_c_mapping_cannot_be_swapped(self) -> None:
        (self.root / "src/internal/sample/ffi_second.mbt").write_text(
            "///|\ntype RawSecond\n",
            encoding="utf-8",
        )
        objects = self.root / "src/native/cairoon_objects.c"
        objects.write_text(
            objects.read_text(encoding="utf-8")
            + """
static void cairoon_second_finalize(void *self) {
  release_second(self);
}

void *second_wrap(void) {
  return moonbit_make_external_object(
    cairoon_second_finalize, sizeof(CairoonSecond));
}
""",
            encoding="utf-8",
        )
        self.ledger["owners"].append(
            {
                "raw_type": "RawSecond",
                "ffi_path": "src/internal/sample/ffi_second.mbt",
                "c_struct": "CairoonSecond",
                "finalizer": "cairoon_second_finalize",
                "release_anchors": ["release_second(self);"],
                "stress_path": "src/tests/lifetime/sample/sample_test.mbt",
                "stress_test": "sample allocation stress",
                "stress_helper": "stress_sample",
                "allocation_anchor": "make_sample()",
                "forbidden_stress_anchors": [],
            }
        )
        self.write_ledger()
        self.assertEqual(self.check(), [])

        first, second = self.ledger["owners"]
        for key in ("c_struct", "finalizer", "release_anchors"):
            first[key], second[key] = second[key], first[key]
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("C payload must be CairoonSample" in e for e in errors))
        self.assertTrue(
            any("finalizer must be cairoon_sample_finalize" in e for e in errors)
        )

    def test_native_allocator_must_stay_in_owner_source(self) -> None:
        (self.root / "src/native/extra.c").write_text(
            """
void *sample_wrap_elsewhere(void) {
  return moonbit_make_external_object(
    cairoon_sample_finalize, sizeof(CairoonSample));
}
""",
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must use only src/native/cairoon_objects.c" in e for e in errors))

    def test_every_release_anchor_is_required_inside_finalizer(self) -> None:
        path = self.root / "src/native/cairoon_objects.c"
        original = path.read_text(encoding="utf-8")
        path.write_text(
            original.replace(
                "release_sample_base(self);", "/* release_sample_base(self); */"
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("missing release anchor" in e for e in errors))

        path.write_text(original, encoding="utf-8")
        self.ledger["owners"][0]["release_anchors"] = [
            "release_sample(self);",
            "release_sample(self);",
        ]
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("non-empty unique string array" in e for e in errors))

        self.ledger["owners"][0]["release_anchors"] = [" "]
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("non-empty unique string array" in e for e in errors))

    def test_stress_loop_must_reach_minimum_iterations(self) -> None:
        original = self.stress_path.read_text(encoding="utf-8")
        self.stress_path.write_text(
            original.replace("0..<1000", "0..<999"),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("loop of at least 1000" in e for e in errors))

        self.stress_path.write_text(
            """
fn stress_sample() -> Unit {
  make_sample()
}

test "sample allocation stress" {
  if false {
    for index in 0..<1000 {
      ignore(index)
      stress_sample()
    }
  }
}
""",
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("loop of at least 1000" in e for e in errors))

    def test_stress_helper_must_run_inside_the_loop(self) -> None:
        self.stress_path.write_text(
            self.stress_path.read_text(encoding="utf-8").replace(
                "    stress_sample()",
                "    if false {\n      stress_sample()\n    }",
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must call stress_sample" in e for e in errors))

    def test_stress_helper_must_contain_allocation_anchor(self) -> None:
        self.stress_path.write_text(
            self.stress_path.read_text(encoding="utf-8").replace(
                "  make_sample()",
                "  if false {\n    make_sample()\n  }",
            ),
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must reach allocation anchor" in e for e in errors))

        self.stress_path.write_text(
            """
/* outer comment
  /* nested comment */
  fn stress_sample() -> Unit { make_sample() }
*/

fn stress_sample() -> Unit {
  if false {
    make_sample()
  }
}

test "sample allocation stress" {
  for index in 0..<1000 {
    ignore(index)
    stress_sample()
  }
}
""",
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must reach allocation anchor" in e for e in errors))

        self.stress_path.write_text(
            """
fn decoy() -> String {
  "fn stress_sample() -> Unit { make_sample() }"
}

fn stress_sample() -> Unit {
  if false {
    make_sample()
  }
}

test "sample allocation stress" {
  for index in 0..<1000 {
    ignore(index)
    stress_sample()
  }
}
""",
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must reach allocation anchor" in e for e in errors))

        self.stress_path.write_text(
            """
#|fn stress_sample() -> Unit { make_sample() }

fn stress_sample() -> Unit {
  if false {
    make_sample()
  }
}

test "sample allocation stress" {
  for index in 0..<1000 {
    ignore(index)
    stress_sample()
  }
}
""",
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("must reach allocation anchor" in e for e in errors))

    def test_stress_source_requires_a_moon_package(self) -> None:
        (self.root / "src/tests/lifetime/moon.pkg").write_text("", encoding="utf-8")
        (self.stress_dir / "moon.pkg").unlink()

        errors = self.check()

        self.assertTrue(any("must be beside its owning moon.pkg" in e for e in errors))

        (self.stress_dir / "moon.pkg").write_text("", encoding="utf-8")
        wrong_name = self.stress_dir / "sample.mbt"
        wrong_name.write_text(
            self.stress_path.read_text(encoding="utf-8"),
            encoding="utf-8",
        )
        self.ledger["owners"][0]["stress_path"] = (
            "src/tests/lifetime/sample/sample.mbt"
        )
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("executable *_test.mbt file" in e for e in errors))

    def test_minimum_iterations_cannot_weaken_below_contract(self) -> None:
        self.ledger["minimum_iterations"] = 999
        self.write_ledger()

        errors = self.check()

        self.assertTrue(any("integer >= 1000" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
