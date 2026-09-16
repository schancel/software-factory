#!/bin/sh
# Overlay the kernel into a consuming repo. Never deletes dest-only files.
# Default: copy missing paths; skip files that already exist.
# --force: overwrite files the kernel also has; still keep dest-only skills.
# --tracker github|pyramid writes .agents/binding (otherwise leave it, or
# create github if missing).
set -eu

usage() {
    printf 'usage: %s [--force] [--tracker github|pyramid] <consuming-repo-root>\n' "$0" >&2
    exit 2
}

FORCE=0
TRACKER=
DEST=
while test $# -gt 0; do
    case $1 in
        --force) FORCE=1 ;;
        --tracker)
            test $# -ge 2 || usage
            TRACKER=$2
            shift
            ;;
        --tracker=*)
            TRACKER=${1#--tracker=}
            ;;
        -*) usage ;;
        *)
            test -z "$DEST" || usage
            DEST=$1
            ;;
    esac
    shift
done

test -n "$DEST" || usage
test -d "$DEST" || { printf 'install: not a directory: %s\n' "$DEST" >&2; exit 1; }

case ${TRACKER:-github} in
    github|pyramid) ;;
    *)
        printf 'install: unknown tracker %s (github or pyramid)\n' "$TRACKER" >&2
        exit 1
        ;;
esac

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Overlay src onto dest. Directories are created. Dest-only names stay.
# Files: copy if missing; with --force, overwrite kernel-owned paths.
merge_tree() {
    # local: nested calls must not clobber the caller's for-loop.
    local src dest item name target
    src=$1
    dest=$2
    mkdir -p "$dest"
    for item in "$src"/*; do
        test -e "$item" || continue
        name=$(basename "$item")
        target="$dest/$name"
        if test -d "$item" && test ! -L "$item"; then
            merge_tree "$item" "$target"
        elif test -e "$target" && test "$FORCE" -eq 0; then
            continue
        else
            cp -f "$item" "$target"
        fi
    done
}

mkdir -p "$DEST/.agents" "$DEST/.claude/skills"

for part in skills references bindings scripts; do
    merge_tree "$HERE/.agents/$part" "$DEST/.agents/$part"
done

write_binding() {
    printf '# Which tracker this checkout uses. Every factory skill reads this file first.\n' > "$DEST/.agents/binding"
    printf '# github (default) | pyramid\n' >> "$DEST/.agents/binding"
    printf 'tracker: %s\n' "$1" >> "$DEST/.agents/binding"
}

if test -n "$TRACKER"; then
    write_binding "$TRACKER"
elif test ! -f "$DEST/.agents/binding"; then
    write_binding github
fi

for skill in "$DEST/.agents/skills"/*; do
    test -e "$skill" || continue
    name=$(basename "$skill")
    ln -sfn "../../.agents/skills/$name" "$DEST/.claude/skills/$name"
done

printf 'installed factory skills into %s/.agents (merge; dest-only paths kept)\n' "$DEST"
printf 'tracker: '
sed -n 's/^tracker: //p' "$DEST/.agents/binding" | head -1
