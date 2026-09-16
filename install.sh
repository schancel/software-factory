#!/bin/sh
# Copy the kernel into a consuming repo. Does not overwrite an existing binding.
# Refuses an existing skills tree unless --force is given.
set -eu

usage() {
    printf 'usage: %s [--force] <consuming-repo-root>\n' "$0" >&2
    exit 2
}

FORCE=0
DEST=
for arg in "$@"; do
    case $arg in
        --force) FORCE=1 ;;
        -*) usage ;;
        *)
            test -z "$DEST" || usage
            DEST=$arg
            ;;
    esac
done

test -n "$DEST" || usage
test -d "$DEST" || { printf 'install: not a directory: %s\n' "$DEST" >&2; exit 1; }

if test "$FORCE" -eq 0 && test -e "$DEST/.agents/skills"; then
    printf 'install: %s already exists; pass --force to replace skills, references, bindings, and scripts\n' "$DEST/.agents/skills" >&2
    exit 1
fi

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$DEST/.agents" "$DEST/.claude/skills"

for part in skills references bindings scripts; do
    rm -rf "$DEST/.agents/$part"
    cp -R "$HERE/.agents/$part" "$DEST/.agents/$part"
done

if test ! -f "$DEST/.agents/binding"; then
    cp "$HERE/.agents/binding" "$DEST/.agents/binding"
fi

for skill in "$DEST/.agents/skills"/*; do
    name=$(basename "$skill")
    ln -sfn "../../.agents/skills/$name" "$DEST/.claude/skills/$name"
done

printf 'installed factory skills into %s/.agents\n' "$DEST"
printf 'tracker: see %s/.agents/binding\n' "$DEST"
