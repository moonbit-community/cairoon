"""Fail-closed ownership checks for borrowed Cairo object returns."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
import pathlib
import re

from .source import c_function_body, c_statement_is_unconditional


@dataclass(frozen=True)
class BorrowedWrapperContract:
    wrapper: str
    reference: str
    owned_call: str


@dataclass(frozen=True)
class BorrowedReturnContract:
    filename: str
    wrapper: str
    producer: str
    producer_call: str
    borrowed_call: str


@dataclass(frozen=True)
class BorrowedArgumentContract:
    filename: str
    wrapper: str
    borrowed_call: str


EXPECTED_BORROWED_WRAPPERS = frozenset(
    {
        "cairoon_surface_wrap_borrowed",
        "cairoon_surface_wrap_borrowed_with_base",
        "cairoon_device_wrap_borrowed",
        "cairoon_pattern_wrap_borrowed",
        "cairoon_font_face_wrap_borrowed",
        "cairoon_scaled_font_wrap_borrowed",
    }
)

EXPECTED_BORROWED_PRODUCERS = frozenset(
    {
        "cairo_get_target",
        "cairo_get_source",
        "cairo_get_group_target",
        "cairo_pattern_get_surface",
        "cairo_get_font_face",
        "cairo_get_scaled_font",
        "cairo_scaled_font_get_font_face",
        "cairo_surface_get_device",
        "cairo_tee_surface_index",
    }
)


BORROWED_WRAPPERS = (
    BorrowedWrapperContract(
        "cairoon_surface_wrap_borrowed",
        "cairo_surface_reference",
        "return cairoon_surface_wrap_owned(ptr);",
    ),
    BorrowedWrapperContract(
        "cairoon_surface_wrap_borrowed_with_base",
        "cairo_surface_reference",
        "return cairoon_surface_wrap_owned_with_base(ptr, base);",
    ),
    BorrowedWrapperContract(
        "cairoon_device_wrap_borrowed",
        "cairo_device_reference",
        "return cairoon_device_wrap_owned(ptr);",
    ),
    BorrowedWrapperContract(
        "cairoon_pattern_wrap_borrowed",
        "cairo_pattern_reference",
        "return cairoon_pattern_wrap_owned(ptr, NULL);",
    ),
    BorrowedWrapperContract(
        "cairoon_font_face_wrap_borrowed",
        "cairo_font_face_reference",
        "return cairoon_font_face_wrap_owned(ptr);",
    ),
    BorrowedWrapperContract(
        "cairoon_scaled_font_wrap_borrowed",
        "cairo_scaled_font_reference",
        "return cairoon_scaled_font_wrap_owned(ptr);",
    ),
)

BORROWED_RETURNS = (
    BorrowedReturnContract(
        "cairoon_context.c",
        "cairoon_context_get_target",
        "cairo_get_target",
        "cairo_surface_t *surface = cairo_get_target(ctx->ptr);",
        "return cairoon_surface_wrap_borrowed_with_base("
        "surface, ctx->target_surface);",
    ),
    BorrowedReturnContract(
        "cairoon_context.c",
        "cairoon_context_get_source",
        "cairo_get_source",
        "cairo_pattern_t *pattern = cairo_get_source(ctx->ptr);",
        "return cairoon_pattern_wrap_borrowed(pattern);",
    ),
    BorrowedReturnContract(
        "cairoon_context.c",
        "cairoon_context_get_group_target",
        "cairo_get_group_target",
        "cairo_surface_t *surface = cairo_get_group_target(ctx->ptr);",
        "return cairoon_surface_wrap_borrowed_with_base(surface, ctx);",
    ),
    BorrowedReturnContract(
        "cairoon_pattern.c",
        "cairoon_pattern_get_surface",
        "cairo_pattern_get_surface",
        "status = cairo_pattern_get_surface(pattern->ptr, &surface);",
        "return cairoon_surface_wrap_borrowed(surface);",
    ),
    BorrowedReturnContract(
        "cairoon_context_font_text.c",
        "cairoon_context_get_font_face",
        "cairo_get_font_face",
        "cairo_font_face_t *font_face = cairo_get_font_face(ctx->ptr);",
        "return cairoon_font_face_wrap_borrowed(font_face);",
    ),
    BorrowedReturnContract(
        "cairoon_context_font_text.c",
        "cairoon_context_get_scaled_font",
        "cairo_get_scaled_font",
        "cairo_scaled_font_t *scaled_font = cairo_get_scaled_font(ctx->ptr);",
        "return cairoon_scaled_font_wrap_borrowed(scaled_font);",
    ),
    BorrowedReturnContract(
        "cairoon_scaled_font.c",
        "cairoon_scaled_font_get_font_face",
        "cairo_scaled_font_get_font_face",
        "cairo_font_face_t *font_face = "
        "cairo_scaled_font_get_font_face(scaled_font->ptr);",
        "return cairoon_font_face_wrap_borrowed(font_face);",
    ),
    BorrowedReturnContract(
        "cairoon_device.c",
        "cairoon_surface_get_device",
        "cairo_surface_get_device",
        "cairo_device_t *device = cairo_surface_get_device(surface->ptr);",
        "return cairoon_device_wrap_borrowed(device);",
    ),
    BorrowedReturnContract(
        "cairoon_tee_surface.c",
        "cairoon_tee_surface_index",
        "cairo_tee_surface_index",
        "cairo_surface_t *indexed = "
        "cairo_tee_surface_index(surface->ptr, (unsigned int)index);",
        "return cairoon_surface_wrap_borrowed_with_base("
        "indexed, cairoon_tee_base_for_indexed_surface(surface, indexed));",
    ),
)

BORROWED_ARGUMENTS = (
    BorrowedArgumentContract(
        "cairoon_raster_source_callbacks.c",
        "cairoon_raster_source_acquire",
        "CairoonSurface *target_wrapper = cairoon_surface_wrap_borrowed(target);",
    ),
)

BORROWED_WRAPPER_PATTERN = re.compile(
    r"\b(cairoon_[A-Za-z0-9_]+_wrap_borrowed(?:_with_base)?)\s*\("
)
DISABLED_PREPROCESSOR_PATTERN = re.compile(
    r"^[ \t]*#[ \t]*if[ \t]+(?:\([ \t]*)?0\b",
    re.MULTILINE,
)


def normalize(text: str) -> str:
    normalized = re.sub(r"\s+", " ", text).strip()
    return re.sub(r"\s*([(),;{}])\s*", r"\1", normalized)


def c_code_only(text: str) -> str:
    """Replace comments and literals with whitespace while preserving layout."""
    chars = list(text)
    index = 0
    while index < len(chars):
        if chars[index : index + 2] == ["/", "/"]:
            end = text.find("\n", index + 2)
            if end < 0:
                end = len(chars)
            for cursor in range(index, end):
                chars[cursor] = " "
            index = end
            continue
        if chars[index : index + 2] == ["/", "*"]:
            end = text.find("*/", index + 2)
            end = len(chars) if end < 0 else end + 2
            for cursor in range(index, end):
                if chars[cursor] != "\n":
                    chars[cursor] = " "
            index = end
            continue
        if chars[index] not in {'"', "'"}:
            index += 1
            continue
        quote = chars[index]
        chars[index] = " "
        index += 1
        while index < len(chars):
            current = chars[index]
            if current == "\\":
                chars[index] = " "
                if index + 1 < len(chars) and chars[index + 1] != "\n":
                    chars[index + 1] = " "
                index += 2
                continue
            if current == quote:
                chars[index] = " "
                index += 1
                break
            if current != "\n":
                chars[index] = " "
            index += 1
    return "".join(chars)


def without_preprocessor_directives(text: str) -> str:
    return re.sub(
        r"^[ \t]*#[^\n]*",
        lambda match: " " * len(match.group(0)),
        text,
        flags=re.MULTILINE,
    )


def code_statement_pattern(statement: str) -> re.Pattern[str]:
    tokens = re.findall(
        r"[A-Za-z_][A-Za-z0-9_]*|(?:->|==|!=|<=|>=|&&|\|\||\+\+|--)|[^\s]",
        statement,
    )
    parts = []
    for token in tokens:
        escaped = re.escape(token)
        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", token):
            parts.append(rf"\b{escaped}\b")
        else:
            parts.append(escaped)
    return re.compile(r"\s*".join(parts))


def top_level_statement_matches(body: str, statement: str) -> list[re.Match[str]]:
    return [
        match
        for match in code_statement_pattern(statement).finditer(body)
        if c_statement_is_unconditional(body, match)
    ]


def borrowed_wrapper_symbol(statement: str) -> str:
    match = BORROWED_WRAPPER_PATTERN.search(statement)
    if match is None:
        raise ValueError(f"borrowed-wrapper contract has no helper call: {statement}")
    return match.group(1)


def check_contract_inventory(
    native_root: pathlib.Path,
    source: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    wrapper_contracts = {contract.wrapper for contract in BORROWED_WRAPPERS}
    if wrapper_contracts != EXPECTED_BORROWED_WRAPPERS:
        errors.append(
            f"{native_root}: borrowed-wrapper contract inventory must be exactly "
            + ", ".join(sorted(EXPECTED_BORROWED_WRAPPERS))
        )

    producer_contracts = {contract.producer for contract in BORROWED_RETURNS}
    if producer_contracts != EXPECTED_BORROWED_PRODUCERS:
        errors.append(
            f"{native_root}: borrowed-producer contract inventory must be exactly "
            + ", ".join(sorted(EXPECTED_BORROWED_PRODUCERS))
        )

    expected_wrapper_uses = Counter(contract.wrapper for contract in BORROWED_WRAPPERS)
    expected_wrapper_uses.update(
        borrowed_wrapper_symbol(contract.borrowed_call)
        for contract in BORROWED_RETURNS
    )
    expected_wrapper_uses.update(
        borrowed_wrapper_symbol(contract.borrowed_call)
        for contract in BORROWED_ARGUMENTS
    )
    actual_wrapper_uses = Counter(
        match.group(1)
        for text in source.values()
        for match in BORROWED_WRAPPER_PATTERN.finditer(text)
    )
    if actual_wrapper_uses != expected_wrapper_uses:
        for wrapper in sorted(actual_wrapper_uses.keys() | expected_wrapper_uses.keys()):
            actual = actual_wrapper_uses[wrapper]
            expected = expected_wrapper_uses[wrapper]
            if actual != expected:
                errors.append(
                    f"{native_root}: borrowed-wrapper contract inventory claims "
                    f"{expected} occurrence(s) of '{wrapper}'; found {actual}"
                )
    return errors


def check_disabled_preprocessor_branches(
    native_root: pathlib.Path,
    source: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    for filename, text in source.items():
        for match in DISABLED_PREPROCESSOR_PATTERN.finditer(text):
            line = text.count("\n", 0, match.start()) + 1
            errors.append(
                f"{native_root / filename}:{line}: disabled preprocessor branch "
                "'#if 0' is forbidden in production ownership evidence"
            )
    return errors


def check_borrowed_helpers(
    native_root: pathlib.Path,
    source: dict[str, str],
) -> list[str]:
    path = native_root / "cairoon_objects.c"
    errors: list[str] = []
    text = source.get(path.name)
    if text is None:
        return [f"{path}: missing borrowed-wrapper source"]
    text = without_preprocessor_directives(text)
    for contract in BORROWED_WRAPPERS:
        body = c_function_body(text, contract.wrapper)
        if body is None:
            errors.append(f"{path}: cannot find complete body for '{contract.wrapper}'")
            continue
        normalized = normalize(body)
        reference_call = normalize(f"{contract.reference}(ptr);")
        guarded_reference = normalize(f"if (ptr != NULL) {{ {reference_call} }}")
        if normalized.count(reference_call) != 1 or guarded_reference not in normalized:
            errors.append(
                f"{path}: '{contract.wrapper}' must call {reference_call} exactly "
                "once under a non-null guard"
            )
        guard_statement = (
            f"if (ptr != NULL) {{ {contract.reference}(ptr); }}"
        )
        if len(top_level_statement_matches(body, guard_statement)) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' non-null reference guard must be "
                "a top-level success-path statement"
            )
        owned_call = normalize(contract.owned_call)
        if normalized.count(owned_call) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' must transfer the referenced pointer "
                f"with '{contract.owned_call}'"
            )
        if len(top_level_statement_matches(body, contract.owned_call)) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' owned-wrapper transfer must be "
                "a top-level success-path statement"
            )
        reference_at = normalized.find(reference_call)
        wrap_at = normalized.find(owned_call)
        if reference_at >= 0 and wrap_at >= 0 and reference_at > wrap_at:
            errors.append(
                f"{path}: '{contract.wrapper}' must reference before wrapping"
            )
    return errors


def check_borrowed_paths(
    native_root: pathlib.Path,
    source: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    expected_producers = Counter(contract.producer for contract in BORROWED_RETURNS)
    for producer, expected in sorted(expected_producers.items()):
        actual = sum(
            len(re.findall(rf"\b{re.escape(producer)}\s*\(", text))
            for text in source.values()
        )
        if actual != expected:
            expected_text = (
                "exactly once" if expected == 1 else f"exactly {expected} times"
            )
            errors.append(
                f"{native_root}: borrowed producer '{producer}' must appear "
                f"{expected_text} across production stubs; found {actual}"
            )

    for contract in BORROWED_RETURNS:
        path = native_root / contract.filename
        text = source.get(contract.filename)
        if text is None:
            errors.append(f"{path}: missing borrowed-return source")
            continue
        body = c_function_body(without_preprocessor_directives(text), contract.wrapper)
        if body is None:
            errors.append(f"{path}: cannot find complete body for '{contract.wrapper}'")
            continue
        normalized = normalize(body)
        producer_call = normalize(contract.producer_call)
        borrowed_call = normalize(contract.borrowed_call)
        if normalized.count(producer_call) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' must contain the claimed borrowed "
                f"producer call '{producer_call}' exactly once"
            )
        if len(top_level_statement_matches(body, contract.producer_call)) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' borrowed producer call must be "
                "a top-level success-path statement"
            )
        if normalized.count(borrowed_call) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' must return through borrowed wrapper "
                f"'{borrowed_call}' exactly once"
            )
        if len(top_level_statement_matches(body, contract.borrowed_call)) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' borrowed wrapper return must be "
                "a top-level success-path statement"
            )
        producer_at = normalized.find(producer_call)
        wrapper_at = normalized.find(borrowed_call)
        if producer_at >= 0 and wrapper_at >= 0 and producer_at > wrapper_at:
            errors.append(
                f"{path}: '{contract.wrapper}' must acquire before wrapping"
            )
    return errors


def check_borrowed_arguments(
    native_root: pathlib.Path,
    source: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    for contract in BORROWED_ARGUMENTS:
        path = native_root / contract.filename
        text = source.get(contract.filename)
        if text is None:
            errors.append(f"{path}: missing borrowed-argument source")
            continue
        body = c_function_body(
            without_preprocessor_directives(text),
            contract.wrapper,
        )
        if body is None:
            errors.append(f"{path}: cannot find complete body for '{contract.wrapper}'")
            continue
        borrowed_call = normalize(contract.borrowed_call)
        if normalize(body).count(borrowed_call) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' must contain borrowed argument wrap "
                f"'{borrowed_call}' exactly once"
            )
        if len(top_level_statement_matches(body, contract.borrowed_call)) != 1:
            errors.append(
                f"{path}: '{contract.wrapper}' borrowed argument wrap must be "
                "a top-level call-path statement"
            )
    return errors


def check_borrowed_returns(native_root: pathlib.Path) -> list[str]:
    source = {
        path.name: c_code_only(path.read_text(encoding="utf-8"))
        for path in sorted(native_root.glob("*.c"))
    }
    return (
        check_disabled_preprocessor_branches(native_root, source)
        + check_contract_inventory(native_root, source)
        + check_borrowed_helpers(native_root, source)
        + check_borrowed_paths(native_root, source)
        + check_borrowed_arguments(native_root, source)
    )
