#!/bin/sh
# Regression: merge keeps dest-only skills; default skips existing files;
# --force overwrites kernel-owned files; binding stays unless --tracker.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INSTALL="$HERE/install.sh"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
ok() { printf 'ok %s\n' "$1"; }

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

DEST="$WORKDIR/dest"
mkdir -p "$DEST/.agents/skills/implement" "$DEST/.agents/references" "$DEST/.agents/bindings" "$DEST/.agents/scripts"
printf 'custom-skill\n' > "$DEST/.agents/skills/implement/SKILL.md"
printf 'local-only\n' > "$DEST/.agents/skills/local-marker"
printf 'custom-ref\n' > "$DEST/.agents/references/keep.md"
printf 'custom-binding-doc\n' > "$DEST/.agents/bindings/keep.md"
printf 'custom-script\n' > "$DEST/.agents/scripts/keep.sh"
printf 'tracker: pyramid\n' > "$DEST/.agents/binding"

sh "$INSTALL" "$DEST" >/dev/null
grep -q 'custom-skill' "$DEST/.agents/skills/implement/SKILL.md" || fail "default merge overwrote customized implement"
test -f "$DEST/.agents/skills/local-marker" || fail "default merge dropped dest-only skill"
test -f "$DEST/.agents/references/keep.md" || fail "default merge dropped dest-only reference"
test -f "$DEST/.agents/bindings/keep.md" || fail "default merge dropped dest-only binding doc"
test -f "$DEST/.agents/scripts/keep.sh" || fail "default merge dropped dest-only script"
test -f "$DEST/.agents/skills/ticket-creation/SKILL.md" || fail "default merge should add factory skills"
grep -q 'tracker: pyramid' "$DEST/.agents/binding" || fail "default merge overwrote binding"
ok "default merge adds factory skills and keeps dest-only + custom files"

sh "$INSTALL" --force "$DEST" >/dev/null
if grep -q 'custom-skill' "$DEST/.agents/skills/implement/SKILL.md"; then
    fail "--force should overwrite kernel-owned implement/SKILL.md"
fi
test -f "$DEST/.agents/skills/local-marker" || fail "--force deleted dest-only skill"
test -f "$DEST/.agents/references/keep.md" || fail "--force deleted dest-only reference"
test -f "$DEST/.agents/bindings/keep.md" || fail "--force deleted dest-only binding doc"
test -f "$DEST/.agents/scripts/keep.sh" || fail "--force deleted dest-only script"
grep -q 'tracker: pyramid' "$DEST/.agents/binding" || fail "--force overwrote binding"
ok "--force overwrites kernel-owned files; keeps dest-only; preserves binding"

EMPTY="$WORKDIR/empty"
mkdir -p "$EMPTY"
sh "$INSTALL" "$EMPTY" >/dev/null
test -f "$EMPTY/.agents/binding" || fail "first install should write binding"
grep -q 'tracker: github' "$EMPTY/.agents/binding" || fail "default tracker should be github"
test -d "$EMPTY/.agents/skills" || fail "first install should copy skills"
ok "first install into empty dest succeeds"

PYR="$WORKDIR/pyr"
mkdir -p "$PYR"
sh "$INSTALL" --tracker pyramid "$PYR" >/dev/null
grep -q 'tracker: pyramid' "$PYR/.agents/binding" || fail "--tracker pyramid should write pyramid"
ok "--tracker pyramid on first install"

mkdir -p "$WORKDIR/empty2"
set +e
bad_out=$(sh "$INSTALL" --tracker jira "$WORKDIR/empty2" 2>&1)
bad_rc=$?
set -e
test "$bad_rc" -ne 0 || fail "unknown tracker should fail"
printf '%s\n' "$bad_out" | grep -q 'unknown tracker' || fail "unknown tracker message missing"
ok "unknown tracker refused"

FORCE_TRACKER="$WORKDIR/force-tracker"
mkdir -p "$FORCE_TRACKER"
sh "$INSTALL" --tracker pyramid "$FORCE_TRACKER" >/dev/null
sh "$INSTALL" --force --tracker github "$FORCE_TRACKER" >/dev/null
grep -q 'tracker: github' "$FORCE_TRACKER/.agents/binding" || fail "--force --tracker should rewrite binding"
ok "--force --tracker rewrites binding"

printf 'PASS: install.sh merge contract\n'
