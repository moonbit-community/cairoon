#!/usr/bin/env python3
"""Tests for module-level Cairo build configuration discovery."""

from __future__ import annotations

import importlib.util
import io
import pathlib
import subprocess
import unittest
from unittest import mock


SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "build" / "cairo_config.py"


def load_script():
    spec = importlib.util.spec_from_file_location("cairo_config", SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class CairoConfigTests(unittest.TestCase):
    def setUp(self) -> None:
        self.config = load_script()

    def test_version_parser_accepts_release_suffix(self) -> None:
        self.assertEqual(self.config.parse_version("1.18.4-2"), (1, 18, 4))

    def test_version_parser_rejects_malformed_value(self) -> None:
        with self.assertRaisesRegex(self.config.CairoConfigError, "invalid Cairo"):
            self.config.parse_version("development")

    def test_discovery_preserves_quoted_flags_without_a_shell(self) -> None:
        responses = {
            ("--modversion", "cairo"): "1.18.4\n",
            ("--cflags", "cairo"): "-I'/sdk/include dir' -DCAIRO_TEST=1\n",
            ("--libs", "cairo"): "-L'/sdk/lib dir' -lcairo -pthread\n",
        }
        calls: list[list[str]] = []

        def runner(command, **kwargs):
            calls.append(command)
            self.assertNotIn("shell", kwargs)
            return subprocess.CompletedProcess(
                command,
                0,
                stdout=responses[tuple(command[1:])],
                stderr="",
            )

        discovered = self.config.discover_cairo(
            environ={"PKG_CONFIG": "/tools/pkg config"},
            runner=runner,
        )

        self.assertEqual(discovered.version, (1, 18, 4))
        self.assertEqual(
            discovered.cflags,
            ("-I/sdk/include dir", "-DCAIRO_TEST=1"),
        )
        self.assertEqual(
            discovered.link_flags,
            ("-L/sdk/lib dir", "-lcairo", "-pthread"),
        )
        self.assertEqual(
            calls,
            [
                ["/tools/pkg config", "--modversion", "cairo"],
                ["/tools/pkg config", "--cflags", "cairo"],
                ["/tools/pkg config", "--libs", "cairo"],
            ],
        )

    def test_discovery_enforces_supported_cairo_floor(self) -> None:
        def runner(command, **_kwargs):
            return subprocess.CompletedProcess(
                command,
                0,
                stdout="1.15.9\n",
                stderr="",
            )

        with self.assertRaisesRegex(
            self.config.CairoConfigError,
            "1.15.10 or newer",
        ):
            self.config.discover_cairo(environ={}, runner=runner)

    def test_discovery_reports_pkg_config_failure_without_environment_dump(self) -> None:
        def runner(command, **_kwargs):
            return subprocess.CompletedProcess(
                command,
                1,
                stdout="",
                stderr="cairo was not found",
            )

        with self.assertRaisesRegex(
            self.config.CairoConfigError,
            "cairo was not found",
        ) as raised:
            self.config.discover_cairo(
                environ={"TOP_SECRET": "do-not-print"},
                runner=runner,
            )
        self.assertNotIn("do-not-print", str(raised.exception))

    def test_build_output_targets_native_stub_package(self) -> None:
        discovered = self.config.CairoConfig(
            version=(1, 18, 4),
            cflags=("-I/sdk/include dir", "-DCAIRO_TEST=1"),
            link_flags=("-L/sdk/lib dir", "-lcairo"),
        )

        output = self.config.build_output(discovered)

        self.assertEqual(
            output,
            {
                "vars": {
                    "CAIRO_CFLAGS": "'-I/sdk/include dir' -DCAIRO_TEST=1",
                },
                "link_configs": [
                    {
                        "package": "CAIMEOX/cairoon/native",
                        "link_flags": "'-L/sdk/lib dir' -lcairo",
                    }
                ],
            },
        )

    def test_main_emits_only_build_protocol_json(self) -> None:
        stdin = io.StringIO('{"env": {}, "paths": {"module_root": "/tmp/p"}}')
        stdout = io.StringIO()
        stderr = io.StringIO()
        discovered = self.config.CairoConfig(
            version=(1, 18, 4),
            cflags=("-I/include",),
            link_flags=("-lcairo",),
        )

        with mock.patch.object(
            self.config,
            "discover_cairo",
            return_value=discovered,
        ):
            result = self.config.main(
                stdin=stdin,
                stdout=stdout,
                stderr=stderr,
                environ={"TOP_SECRET": "do-not-print"},
            )

        self.assertEqual(result, 0)
        self.assertEqual(stderr.getvalue(), "")
        self.assertEqual(
            stdout.getvalue(),
            '{"link_configs":[{"link_flags":"-lcairo",'
            '"package":"CAIMEOX/cairoon/native"}],'
            '"vars":{"CAIRO_CFLAGS":"-I/include"}}\n',
        )
        self.assertNotIn("do-not-print", stdout.getvalue())

    def test_main_rejects_invalid_protocol_input(self) -> None:
        stdout = io.StringIO()
        stderr = io.StringIO()

        result = self.config.main(
            stdin=io.StringIO("[]"),
            stdout=stdout,
            stderr=stderr,
            environ={},
        )

        self.assertEqual(result, 1)
        self.assertEqual(stdout.getvalue(), "")
        self.assertIn("pre-build input must be a JSON object", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
