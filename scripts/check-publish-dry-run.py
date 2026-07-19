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
SERVER_STATUS_RE = re.compile(r"^Server status: ([^,\n]+)", re.MULTILINE)
EXTRACTED_CHECK_MARKER = "running moon check on extracted package"
SUCCESS_DETAIL = "Dry run completed successfully. No changes were made."
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
    if returncode not in KNOWN_SUCCESS_EXIT_CODES:
        errors.append(f"moon publish --dry-run returned unexpected status {returncode}")
    if output.count("Check passed") < 2:
        errors.append("publish dry-run did not pass both source and extracted checks")
    if EXTRACTED_CHECK_MARKER not in output:
        errors.append("publish dry-run did not check the extracted package")
    if "moon check failed" in output:
        errors.append("publish dry-run reported a failed Moon check")

    statuses = SERVER_STATUS_RE.findall(output)
    if statuses != ["202 Accepted"]:
        errors.append(
            "publish dry-run must report exactly one '202 Accepted' server status; "
            f"found {statuses!r}"
        )
    if SUCCESS_DETAIL not in output:
        errors.append("publish dry-run did not confirm that no changes were made")
    expected_package = (
        f"The dry-run was made for package {module_name} version {module_version}."
    )
    if expected_package not in output:
        errors.append(
            "publish dry-run response does not match the packaged module identity: "
            f"expected {expected_package!r}"
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
