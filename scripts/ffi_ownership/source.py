"""Small source-body extractors shared by FFI cleanup audits."""

from __future__ import annotations

import re


def braced_body(text: str, start: int) -> str | None:
    depth = 0
    for index in range(start, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1 : index]
    return None


def c_function_body(text: str, symbol: str) -> str | None:
    match = re.search(rf"\b{re.escape(symbol)}\s*\([^{{]*\)\s*{{", text)
    if match is None:
        return None
    return braced_body(text, text.find("{", match.start()))


def mbt_method_body(text: str, symbol: str) -> str | None:
    match = re.search(
        rf"^\s*pub\s+fn(?:\[[^]]+\])?\s+{re.escape(symbol)}\s*\(",
        text,
        re.MULTILINE,
    )
    if match is None:
        return None
    start = text.find("{", match.end())
    if start < 0:
        return None
    return braced_body(text, start)


def mbt_handler_body(text: str, binding: str) -> str | None:
    match = re.search(rf"\b{re.escape(binding)}\s*=>\s*\{{", text)
    if match is None:
        return None
    return braced_body(text, text.find("{", match.start()))


def c_statement_is_unconditional(body: str, match: re.Match[str]) -> bool:
    """Return whether a matched statement is at function-body top level."""
    before = body[: match.start()]
    if before.count("{") != before.count("}"):
        return False
    boundary = max(
        before.rfind(";"),
        before.rfind("{"),
        before.rfind("}"),
    )
    return before[boundary + 1 :].strip() == ""
