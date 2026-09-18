#!/bin/sh
# Merge keeps dest-only names; SKILL.md is 3-way merged against .factory-base.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INSTALL="$HERE/install.sh"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
ok() { printf 'ok %s\n' "$1"; }

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

EMPTY="$WORKDIR/empty"
mkdir -p "$EMPTY"
sh "$INSTALL" "$EMPTY" >/dev/null
test -f "$EMPTY/.agents/skills/implement/SKILL.md" || fail "empty dest should get factory skills"
test -f "$EMPTY/.agents/.factory-base/skills/implement/SKILL.md" || fail "should record vendor base"
grep -q 'tracker: github' "$EMPTY/.agents/binding" || fail "default tracker github"
ok "first install into empty dest"

test -f "$EMPTY/.agents/harnesses/claude-code.md" || fail "empty dest should get harness lane-resolution docs"
test -f "$EMPTY/.agents/harnesses/codex.md" || fail "empty dest should get harness lane-resolution docs"
test -f "$EMPTY/.agents/harnesses/grok-build.md" || fail "empty dest should get harness lane-resolution docs"
sh "$EMPTY/.agents/scripts/test-skill-docs" "$EMPTY" >/dev/null || fail "installed test-skill-docs should pass standalone against the installed copy"
ok "harnesses/ installs and the installed lint passes standalone"

# Local line in SKILL.md must survive a second install (kernel unchanged).
printf '\nLOCAL_EDIT\n' >> "$EMPTY/.agents/skills/implement/SKILL.md"
sh "$INSTALL" "$EMPTY" >/dev/null
grep -q 'LOCAL_EDIT' "$EMPTY/.agents/skills/implement/SKILL.md" || fail "second install dropped local SKILL.md edit"
grep -q 'Implement one unit of work' "$EMPTY/.agents/skills/implement/SKILL.md" || fail "second install dropped kernel SKILL.md"
ok "reinstall 3-way-merges local SKILL.md edits"

DEST="$WORKDIR/dest"
mkdir -p "$DEST/.agents/skills/implement" "$DEST/.agents/references" "$DEST/.agents/scripts"
printf 'custom-skill\n' > "$DEST/.agents/skills/implement/SKILL.md"
printf 'local-only\n' > "$DEST/.agents/skills/local-marker"
printf 'custom-ref\n' > "$DEST/.agents/references/keep.md"
printf 'custom-script\n' > "$DEST/.agents/scripts/keep.sh"
printf 'tracker: pyramid\n' > "$DEST/.agents/binding"

sh "$INSTALL" "$DEST" >/dev/null
grep -q 'custom-skill' "$DEST/.agents/skills/implement/SKILL.md" || fail "no-base dest SKILL.md should be skipped"
test -f "$DEST/.agents/skills/local-marker" || fail "dropped dest-only skill"
test -f "$DEST/.agents/references/keep.md" || fail "dropped dest-only reference"
test -f "$DEST/.agents/scripts/keep.sh" || fail "dropped dest-only script"
test -f "$DEST/.agents/skills/ticket-creation/SKILL.md" || fail "should add factory skills"
grep -q 'tracker: pyramid' "$DEST/.agents/binding" || fail "overwrote binding"
ok "dest-only names kept; unmatched SKILL.md skipped without base"

sh "$INSTALL" --force "$DEST" >/dev/null
if grep -q 'custom-skill' "$DEST/.agents/skills/implement/SKILL.md"; then
    fail "--force should take kernel SKILL.md"
fi
test -f "$DEST/.agents/skills/local-marker" || fail "--force deleted dest-only skill"
test -f "$DEST/.agents/references/keep.md" || fail "--force deleted dest-only reference"
grep -q 'tracker: pyramid' "$DEST/.agents/binding" || fail "--force overwrote binding"
ok "--force takes kernel files; keeps dest-only; preserves binding"

PYR="$WORKDIR/pyr"
mkdir -p "$PYR"
sh "$INSTALL" --tracker pyramid "$PYR" >/dev/null
grep -q 'tracker: pyramid' "$PYR/.agents/binding" || fail "--tracker pyramid"
ok "--tracker pyramid"

LIN="$WORKDIR/lin"
mkdir -p "$LIN"
sh "$INSTALL" --tracker linear "$LIN" >/dev/null
grep -q 'tracker: linear' "$LIN/.agents/binding" || fail "--tracker linear"
ok "--tracker linear"

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

printf 'PASS: install.sh SKILL.md merge contract\n'
