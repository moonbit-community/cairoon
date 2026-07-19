#!/usr/bin/env python3
"""Run and strictly validate Moon's non-mutating publish dry-run."""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys
from collections.abc import Sequence


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
MODULE_NAME_RE = re.compile(r'^name\s*=\s*"([^"]+)"\s*$', re.MULTILINE)
MODULE_VERSION_RE = re.compile(r'^version\s*=\s*"([^"]+)"\s*$', re.MULTILINE)
SERVER_STATUS_PREFIX = "Server status: "
EXTRACTED_CHECK_MARKER = "running moon check on extracted package"
SUCCESS_DETAIL = "Dry run completed successfully. No changes were made."
PUBLISH_FAILURE_BANNER = "Error: `moon publish` failed"
KNOWN_SUCCESS_EXIT_CODES = {0, 255}


def parse_module_identity(path: pathlib.Path) -> tuple[str, str]:
    text = path.read_text(encoding="utf-8")
    names = MODULE_NAME_RE.findall(text)
    versions = MODULE_VERSION_RE.findall(text)
    if len(names) != 1:
        raise ValueError(f"{path}: expected exactly one module name")
    if len(versions) != 1:
        raise ValueError(f"{path}: expected exactly one module version")
    return names[0], versions[0]


def validate_publish_output(
    output: str,
    returncode: int,
    module_name: str,
    module_version: str,
) -> list[str]:
    errors: list[str] = []
    lines = output.splitlines()
    if returncode not in KNOWN_SUCCESS_EXIT_CODES:
        errors.append(f"moon publish --dry-run returned unexpected status {returncode}")
    elif returncode == 255:
        error_lines = [line for line in lines if line.startswith("Error:")]
        if error_lines != [PUBLISH_FAILURE_BANNER] or not output.rstrip().endswith(
            PUBLISH_FAILURE_BANNER
        ):
            errors.append(
                "moon status 255 is accepted only with its exact trailing "
                "publish-failure banner"
            )
    elif any(line.startswith("Error:") for line in lines):
        errors.append("moon status 0 must not include an error banner")

    check_count = lines.count("Check passed")
    if check_count != 2:
        errors.append(
            "publish dry-run must pass exactly the source and extracted checks; "
            f"found {check_count} successful checks"
        )
    extracted_check_count = lines.count(EXTRACTED_CHECK_MARKER)
    if extracted_check_count != 1:
        errors.append(
            "publish dry-run must check the extracted package exactly once; "
            f"found {extracted_check_count} markers"
        )
    if "moon check failed" in output:
        errors.append("publish dry-run reported a failed Moon check")

    expected_package = (
        f"The dry-run was made for package {module_name} version {module_version}."
    )
    expected_response = (
        f"{SERVER_STATUS_PREFIX}202 Accepted, detail: {SUCCESS_DETAIL} "
        f"{expected_package}"
    )
    server_lines = [line for line in lines if line.startswith(SERVER_STATUS_PREFIX)]
    if server_lines != [expected_response]:
        errors.append(
            "publish dry-run must report one exact 202/no-change response for the "
            f"packaged module; found {server_lines!r}"
        )
    return errors


def run_publish_dry_run(
    moon: str,
    repo_root: pathlib.Path = REPO_ROOT,
) -> tuple[str, int]:
    completed = subprocess.run(
        [moon, "publish", "--dry-run"],
        cwd=repo_root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    return completed.stdout, completed.returncode


def print_errors(errors: Sequence[str]) -> None:
    for error in errors:
        print(error, file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--moon",
        default="moon",
        help="Moon executable to use (default: moon)",
    )
    args = parser.parse_args()

    try:
        module_name, module_version = parse_module_identity(REPO_ROOT / "moon.mod")
        output, returncode = run_publish_dry_run(args.moon)
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1

    sys.stdout.write(output)
    errors = validate_publish_output(
        output,
        returncode,
        module_name,
        module_version,
    )
    if errors:
        print_errors(errors)
        return 1
    print(
        f"Moon publish dry-run accepted {module_name}@{module_version}; "
        "no registry changes were made."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
