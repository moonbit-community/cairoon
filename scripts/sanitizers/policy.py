"""Platform policy shared by cairoon's sanitizer runner and its tests."""

from __future__ import annotations


LEAK_MODES = ("auto", "on", "off")


def leak_detection_enabled(mode: str, system: str) -> bool:
    if mode not in LEAK_MODES:
        raise ValueError(f"unsupported leak mode: {mode}")
    if mode == "on":
        return True
    if mode == "off":
        return False
    return system == "Linux"


def asan_options(leaks_enabled: bool) -> str:
    detect_leaks = "1" if leaks_enabled else "0"
    return (
        f"detect_leaks={detect_leaks}:"
        "fast_unwind_on_malloc=0:halt_on_error=1"
    )


def ubsan_options() -> str:
    return "halt_on_error=1:print_stacktrace=1"


def policy_description(system: str, leaks_enabled: bool) -> str:
    if leaks_enabled:
        return f"ASan, LSan, and UBSan enabled on {system}"
    if system == "Darwin":
        return (
            "ASan and UBSan enabled; LSan deferred to the authoritative "
            "Linux matrix"
        )
    return f"ASan and UBSan enabled; LSan explicitly disabled on {system}"
