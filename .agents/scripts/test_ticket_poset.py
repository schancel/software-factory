#!/usr/bin/env python3
"""Pure-function checks for ticket_poset.waves. Does not call gh."""

from __future__ import annotations

from ticket_poset import CycleError, waves


def test_empty() -> None:
    assert waves({}) == []


def test_single() -> None:
    assert waves({7: []}) == [[7]]


def test_two_wave() -> None:
    assert waves({2: [1], 1: []}) == [[1], [2]]


def test_out_of_scope_blocker() -> None:
    assert waves({2: [1], 3: []}) == [[3]]


def test_cycle() -> None:
    try:
        waves({1: [2], 2: [1]})
    except CycleError:
        return
    raise AssertionError("expected CycleError")


def main() -> int:
    test_empty()
    test_single()
    test_two_wave()
    test_out_of_scope_blocker()
    test_cycle()
    print("ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
