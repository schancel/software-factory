#!/bin/sh
# Regression for install.sh: refuse reinstall without --force; --force replaces dirs, not binding.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INSTALL="$HERE/install.sh"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
ok() { printf 'ok %s\n' "$1"; }

tree_state() {
    (CDPATH= cd -- "$1" && find . \( -type f -o -type l \) -print | sort | while IFS= read -r path; do
        printf '%s\t' "$path"
        if test -L "$path"; then
            readlink "$path"
            printf '\n'
        else
            cksum < "$path"
        fi
    done)
}

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
BEFORE=$(tree_state "$DEST")

set +e
refuse_out=$(sh "$INSTALL" "$DEST" 2>&1)
refuse_rc=$?
set -e
test "$refuse_rc" -ne 0 || fail "reinstall without --force should exit nonzero, got $refuse_rc"
printf '%s\n' "$refuse_out" | grep -q -- '--force' || fail "refuse message should mention --force"
AFTER=$(tree_state "$DEST")
test "$BEFORE" = "$AFTER" || fail "reinstall without --force changed dest"
test ! -e "$DEST/.claude" || fail "refuse path created .claude"
ok "refuse without --force leaves dest unchanged"

set +e
force_out=$(sh "$INSTALL" --force "$DEST" 2>&1)
force_rc=$?
set -e
test "$force_rc" -eq 0 || fail "--force should succeed, got $force_rc: $force_out"
test ! -e "$DEST/.agents/skills/local-marker" || fail "--force should replace dest skills"
test ! -e "$DEST/.agents/references/keep.md" || fail "--force should replace dest references"
test ! -e "$DEST/.agents/bindings/keep.md" || fail "--force should replace dest bindings"
test ! -e "$DEST/.agents/scripts/keep.sh" || fail "--force should replace dest scripts"
test -f "$DEST/.agents/skills/implement/SKILL.md" || fail "--force should copy factory skills"
if grep -q 'custom-skill' "$DEST/.agents/skills/implement/SKILL.md"; then
    fail "--force left custom skill"
fi
grep -q 'tracker: pyramid' "$DEST/.agents/binding" || fail "--force overwrote binding"
ok "--force replaces four dirs and preserves binding"

EMPTY="$WORKDIR/empty"
mkdir -p "$EMPTY"
sh "$INSTALL" "$EMPTY" >/dev/null
test -f "$EMPTY/.agents/binding" || fail "first install should write binding"
test -d "$EMPTY/.agents/skills" || fail "first install should copy skills"
ok "first install into empty dest succeeds"

printf 'PASS: install.sh reinstall contract\n'
