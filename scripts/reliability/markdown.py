"""Markdown parsing helpers for reliability evidence."""

from __future__ import annotations

import pathlib
import re
from collections.abc import Iterator


def table_cells(line: str) -> list[str] | None:
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return None
    cells = [cell.strip() for cell in stripped.strip("|").split("|")]
    if len(cells) < 3:
        return None
    return cells


def is_separator(cells: list[str]) -> bool:
    return all(re.fullmatch(r":?-+:?", cell.replace(" ", "")) for cell in cells)


def markdown_indent_columns(line: str) -> int:
    columns = 0
    for character in line:
        if character == " ":
            columns += 1
        elif character == "\t":
            columns += 4 - (columns % 4)
        else:
            break
    return columns


def markdown_fence_opener(line: str) -> tuple[str, int] | None:
    body = line.rstrip("\r\n")
    match = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", body)
    if match is None:
        return None
    marker, info = match.groups()
    if marker[0] == "`" and "`" in info:
        return None
    return marker[0], len(marker)


def markdown_fence_closes(line: str, character: str, length: int) -> bool:
    body = line.rstrip("\r\n")
    return re.fullmatch(
        rf" {{0,3}}{re.escape(character)}{{{length},}}[ \t]*",
        body,
    ) is not None


def mask_markdown_content(text: str) -> str:
    """Hide comments and Markdown code while preserving source line numbers."""
    characters = list(text)
    search_from = 0
    while (start := text.find("<!--", search_from)) != -1:
        closing = text.find("-->", start + 4)
        end = len(text) if closing == -1 else closing + 3
        for index in range(start, end):
            if characters[index] not in "\r\n":
                characters[index] = " "
        search_from = end

    without_comments = "".join(characters)
    visible_lines: list[str] = []
    fence_character: str | None = None
    fence_length = 0
    for line in without_comments.splitlines(keepends=True):
        if fence_character is not None:
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            if markdown_fence_closes(line, fence_character, fence_length):
                fence_character = None
                fence_length = 0
            continue
        opener = markdown_fence_opener(line)
        if opener is not None:
            fence_character, fence_length = opener
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            continue
        if markdown_indent_columns(line) >= 4:
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            continue
        visible_lines.append(line)
    return "".join(visible_lines)


def inventory_rows(
    api_inventory: pathlib.Path,
    section: str | None = None,
) -> Iterator[tuple[int, str, str, str]]:
    text = mask_markdown_content(api_inventory.read_text(encoding="utf-8"))
    lines = text.splitlines()
    start = 0
    section_level = 0
    if section is not None:
        try:
            start = lines.index(section) + 1
        except ValueError:
            return
        section_level = len(section) - len(section.lstrip("#"))

    in_status_table = False
    section_end = re.compile(rf"^#{{1,{section_level}}}\s") if section else None
    for line_no, line in enumerate(lines[start:], start + 1):
        if section_end is not None and section_end.match(line):
            break
        cells = table_cells(line)
        if cells is None:
            in_status_table = False
            continue
        if is_separator(cells):
            continue

        second_header = cells[1].lower()
        if second_header in {"status", "cairoon status"}:
            in_status_table = True
            continue
        if not in_status_table:
            continue

        label = cells[0]
        status = cells[1]
        notes = " | ".join(cells[2:])
        yield line_no, label, status, notes


def contains_any(text: str, markers: tuple[str, ...]) -> bool:
    lowered = text.lower()
    return any(marker in lowered for marker in markers)


def markdown_section(text: str, heading: str) -> str:
    lines = mask_markdown_content(text).splitlines()
    matches = [index for index, line in enumerate(lines) if line == heading]
    if len(matches) != 1:
        return ""
    start = matches[0]

    level = len(heading) - len(heading.lstrip("#"))
    end = len(lines)
    heading_pattern = re.compile(rf"^#{{1,{level}}}\s")
    for index in range(start + 1, len(lines)):
        if heading_pattern.match(lines[index]):
            end = index
            break
    return "\n".join(lines[start:end])


def markdown_paragraphs(text: str) -> tuple[str, ...]:
    paragraphs = []
    for block in re.split(r"\n\s*\n", text):
        normalized = re.sub(r"\s+", " ", block).strip()
        if normalized and not re.match(r"^#{1,6}\s", normalized):
            paragraphs.append(normalized)
    return tuple(paragraphs)
