#!/bin/sh
# Copy the kernel into a consuming repo. Does not overwrite an existing binding.
set -eu

usage() {
    printf 'usage: %s <consuming-repo-root>\n' "$0" >&2
    exit 2
}

case $# in
    1) DEST=$1 ;;
    *) usage ;;
esac

test -d "$DEST" || { printf 'install: not a directory: %s\n' "$DEST" >&2; exit 1; }

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
