"""Parse the small fail-closed YAML subset used by cairoon's CI policy."""

from __future__ import annotations

import re


def yaml_job_section(text: str, job: str) -> str:
    return yaml_mapping_section(text, 2, job)


def yaml_mapping_section(text: str, indent: int, key: str) -> str:
    lines = text.splitlines()
    entries = yaml_structural_lines(text)
    matches = [
        line_no
        for line_no, line_indent, content in entries
        if line_indent == indent
        and not content.startswith("- ")
        and yaml_key_value(content) == (key, "")
    ]
    if len(matches) != 1:
        return ""
    start = matches[0]
    end = len(lines)
    for line_no, line_indent, content in entries:
        if (
            line_no > start
            and line_indent <= indent
            and yaml_key_value(content) is not None
        ):
            end = line_no
            break
    return "\n".join(lines[start:end])


def yaml_step_section(job_section: str, run_line: str) -> str:
    lines = job_section.splitlines()
    expected_command = yaml_key_value(run_line)
    if expected_command is None or expected_command[0] != "run":
        return ""
    entries = yaml_structural_lines(job_section)
    run_indexes = [
        line_no
        for line_no, indent, content in entries
        if indent == 8 and yaml_key_value(content) == expected_command
    ]
    if len(run_indexes) != 1:
        return ""

    run_index = run_indexes[0]
    starts = [
        line_no
        for line_no, indent, content in reversed(entries)
        if line_no <= run_index and indent == 6 and content.startswith("- ")
    ]
    if not starts:
        return ""
    start = starts[0]
    end = len(lines)
    for line_no, indent, content in entries:
        if line_no > start and indent == 6 and content.startswith("- "):
            end = line_no
            break
    return "\n".join(lines[start:end])


def yaml_step_sections(steps_section: str) -> list[str]:
    lines = steps_section.splitlines()
    starts = [
        line_no
        for line_no, indent, content in yaml_structural_lines(steps_section)
        if indent == 6 and content.startswith("- ")
    ]
    return [
        "\n".join(lines[start : starts[index + 1] if index + 1 < len(starts) else None])
        for index, start in enumerate(starts)
    ]


def yaml_step_names(steps_section: str) -> list[str]:
    names = []
    sections = yaml_step_sections(steps_section)
    section_starts = {
        line_no
        for line_no, indent, content in yaml_structural_lines(steps_section)
        if indent == 6 and content.startswith("- ")
    }
    for line_no, indent, content in yaml_structural_lines(steps_section):
        if indent == 6 and line_no not in section_starts:
            names.append("<non-step>")
    for section in sections:
        entries = yaml_structural_lines(section)
        first = entries[0][2] if entries else ""
        key_value = yaml_key_value(first)
        if key_value is None or key_value[0] != "name":
            names.append("<unnamed>")
        else:
            names.append(key_value[1])
    return names


def yaml_named_step_section(steps_section: str, name: str) -> str:
    matches = []
    for section in yaml_step_sections(steps_section):
        entries = yaml_structural_lines(section)
        if entries and yaml_key_value(entries[0][2]) == ("name", name):
            matches.append(section)
    return matches[0] if len(matches) == 1 else ""


def yaml_run_commands(step_section: str) -> tuple[str, ...]:
    lines = step_section.splitlines()
    runs = [
        (line_no, value)
        for line_no, indent, content in yaml_structural_lines(step_section)
        if indent == 8
        and (key_value := yaml_key_value(content)) is not None
        and key_value[0] == "run"
        for value in (key_value[1],)
    ]
    if len(runs) != 1:
        return ()
    line_no, value = runs[0]
    if not yaml_is_block_scalar(value):
        return (value,) if value else ()

    block = []
    for line in lines[line_no + 1 :]:
        content = line.lstrip(" ")
        indent = len(line) - len(content)
        if content and indent <= 8:
            break
        if content:
            block.append(content.rstrip())
    if not block:
        return ()
    return tuple(block)


def active_yaml_lines(text: str) -> set[str]:
    return {content for _, _, content in yaml_structural_lines(text)}


def yaml_noncomment_lines(text: str) -> list[str]:
    return [
        content
        for line in text.splitlines()
        if (content := line.lstrip(" \t")) and not content.startswith("#")
    ]


def yaml_key_value(content: str) -> tuple[str, str] | None:
    candidate = content[2:].lstrip() if content.startswith("- ") else content
    match = re.match(
        r'^(?:"([^"]+)"|\'([^\']+)\'|([A-Za-z0-9_<>-]+))\s*:(?=$|[ \t])(.*)$',
        candidate,
    )
    if match is None:
        return None
    key = next(group for group in match.groups()[:3] if group is not None)
    return key, match.group(4).strip()


def yaml_structural_lines(text: str) -> list[tuple[int, int, str]]:
    entries: list[tuple[int, int, str]] = []
    block_parent_indent: int | None = None
    for line_no, line in enumerate(text.splitlines()):
        content = line.lstrip(" ")
        indent = len(line) - len(content)
        if block_parent_indent is not None:
            if not content or indent > block_parent_indent:
                continue
            block_parent_indent = None
        if not content or content.startswith("#"):
            continue

        entries.append((line_no, indent, content))
        key_value = yaml_key_value(content)
        if key_value is not None and yaml_is_block_scalar(key_value[1]):
            block_parent_indent = indent
    return entries


def yaml_is_block_scalar(value: str) -> bool:
    value_without_comment = re.sub(r"\s+#.*$", "", value).rstrip()
    return re.search(r"(?:^|\s)[>|][0-9+-]*$", value_without_comment) is not None


def yaml_has_key(text: str, key: str, *, indent: int | None = None) -> bool:
    for _, line_indent, content in yaml_structural_lines(text):
        if indent is not None and line_indent != indent:
            continue
        key_value = yaml_key_value(content)
        if key_value is not None and key_value[0] == key:
            return True
    return False


def yaml_keys_at_indent(text: str, indent: int) -> list[str]:
    keys = []
    for _, line_indent, content in yaml_structural_lines(text):
        if line_indent != indent or content.startswith("- "):
            continue
        key_value = yaml_key_value(content)
        keys.append("<unparsed>" if key_value is None else key_value[0])
    return keys


def yaml_sequence_scalars_at_indent(text: str, indent: int) -> list[str]:
    values = []
    for _, line_indent, content in yaml_structural_lines(text):
        if line_indent != indent or not content.startswith("- "):
            continue
        value = content[2:].strip()
        values.append("<mapping>" if yaml_key_value(value) is not None else value)
    return values
