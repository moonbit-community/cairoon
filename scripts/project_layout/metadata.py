"""Repository metadata, documentation, and consumer-fixture layout audits."""

from __future__ import annotations

import pathlib
import re

from .common import is_public_root_file, is_source_like


EXECUTABLE_MBT_CHECK_BLOCK = re.compile(
    r"^```mbt[ \t]+check[ \t]*\r?\n(?P<body>.*?)^```[ \t]*$",
    re.MULTILINE | re.DOTALL,
)
REFERENCE_DOC_INDEX_ENTRY = re.compile(r"`(?P<path>src/docs/[^`\s]+\.mbt\.md)`")


def check_root_freeze(repo_root: pathlib.Path, allowed: set[str]) -> list[str]:
    errors: list[str] = []
    root_source = {
        path.name
        for path in repo_root.iterdir()
        if path.is_file() and is_source_like(path)
    }
    unexpected = sorted(root_source - allowed)
    if unexpected:
        errors.append(
            "new root source-like files are forbidden; move them into a package "
            "or update PROJECT_LAYOUT.md intentionally: " + ", ".join(unexpected)
        )
    stale = sorted(allowed - root_source)
    if stale:
        errors.append(
            "root source allowlist entries must be removed when files move; "
            "stale entries: " + ", ".join(stale)
        )
    return errors


def check_public_package_root_freeze(
    package_root: pathlib.Path,
    allowed: set[str],
) -> list[str]:
    errors: list[str] = []
    direct_source = {
        path.name
        for path in package_root.iterdir()
        if path.is_file() and is_public_root_file(path)
    }
    unexpected = sorted(direct_source - allowed)
    if unexpected:
        errors.append(
            "new source-like files directly under src/ are forbidden; place "
            "implementation, tests, docs, or generated interfaces in a "
            "subpackage, or update PROJECT_LAYOUT.md intentionally: "
            + ", ".join(unexpected)
        )
    stale = sorted(allowed - direct_source)
    if stale:
        errors.append(
            "public package root allowlist entries must be removed in the same "
            "commit that moves files out of src/; stale entries: "
            + ", ".join(stale)
        )
    return errors


def check_source_root(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
    moon_mod: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    if not (package_root / "moon.pkg").exists():
        errors.append("src/moon.pkg: missing public package config")
    if (repo_root / "moon.pkg").exists():
        errors.append("moon.pkg: root package config is forbidden; use src/moon.pkg")
    if not (package_root / "pkg.generated.mbti").exists():
        errors.append("src/pkg.generated.mbti: missing generated public interface")
    moon_mod_text = moon_mod.read_text(encoding="utf-8") if moon_mod.exists() else ""
    target_markers = (
        ("preferred_target", 'preferred_target = "native"'),
        ("supported_targets", 'supported_targets = "native"'),
    )
    for field, marker in target_markers:
        if (
            re.search(
                rf"^{field}\s*=\s*\"native\"\s*$",
                moon_mod_text,
                re.MULTILINE,
            )
            is None
        ):
            errors.append(f"moon.mod: missing {marker}")
    if 'source = "src"' not in moon_mod_text:
        errors.append('moon.mod: missing source = "src"')
    if 'readme = "src/README.mbt.md"' not in moon_mod_text:
        errors.append('moon.mod: readme must point at src/README.mbt.md')
    exclude_match = re.search(
        r"exclude\s*:\s*\[(?P<entries>[^\]]*)\]",
        moon_mod_text,
        re.DOTALL,
    )
    if exclude_match is None or '"integration"' not in exclude_match.group("entries"):
        errors.append(
            'moon.mod: publishing must exclude the integration consumer fixture'
        )
    return errors


def markdown_level_two_section(text: str, title: str) -> str | None:
    heading = re.search(
        rf"^##[ \t]+{re.escape(title)}[ \t]*$",
        text,
        re.MULTILINE,
    )
    if heading is None:
        return None
    remainder = text[heading.end() :]
    next_heading = re.search(r"^##(?:[ \t]+|$)", remainder, re.MULTILINE)
    if next_heading is None:
        return remainder
    return remainder[: next_heading.start()]


def check_reference_docs(
    doc_package_dir: pathlib.Path,
    root_readme: pathlib.Path,
    public_readme: pathlib.Path,
    required_reference_docs: frozenset[str],
) -> list[str]:
    errors: list[str] = []
    if not doc_package_dir.is_dir():
        return [f"{doc_package_dir}: missing executable reference package"]

    for support_name in ("moon.pkg", "prelude.mbt"):
        support_path = doc_package_dir / support_name
        if not support_path.is_file():
            errors.append(f"{support_path}: missing documentation package support file")

    docs = {
        path.name: path
        for path in doc_package_dir.glob("*.mbt.md")
        if path.is_file()
    }
    for name in sorted(required_reference_docs - docs.keys()):
        errors.append(f"{doc_package_dir / name}: missing required reference document")

    readmes = ((root_readme, "repository"), (public_readme, "public package"))
    readme_indexes: dict[pathlib.Path, set[str]] = {}
    for path, label in readmes:
        if path.is_file():
            text = path.read_text(encoding="utf-8")
            section = markdown_level_two_section(text, "Documentation")
            if section is None:
                errors.append(
                    f"{path}: {label} README is missing a Documentation section"
                )
            else:
                readme_indexes[path] = {
                    match.group("path")
                    for match in REFERENCE_DOC_INDEX_ENTRY.finditer(section)
                }
        else:
            errors.append(f"{path}: missing {label} README documentation index")

    for name, path in sorted(docs.items()):
        text = path.read_text(encoding="utf-8")
        if re.search(r"^#\s+\S", text, re.MULTILINE) is None:
            errors.append(f"{path}: reference document must have a level-one title")
        executable_blocks = EXECUTABLE_MBT_CHECK_BLOCK.finditer(text)
        if not any(match.group("body").strip() for match in executable_blocks):
            errors.append(
                f"{path}: reference document must contain executable mbt check"
            )
        relative_path = f"src/docs/{name}"
        marker = f"`{relative_path}`"
        for readme_path, label in readmes:
            if (
                readme_path in readme_indexes
                and relative_path not in readme_indexes[readme_path]
            ):
                errors.append(
                    f"{readme_path}: {label} documentation index is missing {marker}"
                )

    return errors


def check_integration_fixture(
    repo_root: pathlib.Path,
    moon_mod: pathlib.Path,
    integration_workspace: pathlib.Path,
    consumer_module: pathlib.Path,
    consumer_package_config: pathlib.Path,
    consumer_test: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    required_files = (
        integration_workspace,
        consumer_module,
        consumer_package_config,
        consumer_test,
    )
    for path in required_files:
        if not path.exists():
            errors.append(
                f"{path.relative_to(repo_root)}: missing downstream consumer "
                "fixture file"
            )
    if errors:
        return errors

    workspace = integration_workspace.read_text(encoding="utf-8")
    workspace_members = set(re.findall(r'"([^"]+)"', workspace))
    if workspace_members != {"..", "./consumer"}:
        errors.append(
            "integration/moon.work: members must be exactly the relative "
            "cairoon root and isolated consumer module"
        )

    root_module = moon_mod.read_text(encoding="utf-8")
    version_match = re.search(r'^version\s*=\s*"([^"]+)"', root_module, re.MULTILINE)
    if version_match is None:
        errors.append("moon.mod: missing module version for consumer dependency check")
        expected_dependency = None
    else:
        expected_dependency = f'"CAIMEOX/cairoon@{version_match.group(1)}"'

    consumer_module_text = consumer_module.read_text(encoding="utf-8")
    module_markers = (
        'name = "cairoon-integration/consumer"',
        'preferred_target = "native"',
        'supported_targets = "native"',
        'source = "src"',
    )
    for marker in module_markers:
        if marker not in consumer_module_text:
            errors.append(
                f"integration/consumer/moon.mod: missing required marker {marker!r}"
            )
    if (
        expected_dependency is not None
        and expected_dependency not in consumer_module_text
    ):
        errors.append(
            "integration/consumer/moon.mod: cairoon dependency version must "
            f"match the root module ({expected_dependency})"
        )

    consumer_package = consumer_package_config.read_text(encoding="utf-8")
    if '"CAIMEOX/cairoon"' not in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: must import the public "
            "CAIMEOX/cairoon package"
        )
    cairoon_imports = set(
        re.findall(r'"(CAIMEOX/cairoon[^"]*)"', consumer_package)
    )
    if cairoon_imports != {"CAIMEOX/cairoon"}:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: must use only the public "
            "CAIMEOX/cairoon package, not implementation subpackages"
        )
    if 'for "test"' not in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: the fixture import must "
            "remain test-scoped"
        )
    if '"cc-link-flags"' in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: consumer must rely on "
            "cairoon's propagated native link configuration, not repeat "
            "cc-link-flags"
        )
    return errors
