#!/bin/sh
# Copy the kernel into a consuming repo.
# --tracker github|pyramid selects the ticket tracker (writes .agents/binding).
# --force replaces skills/references/bindings/scripts. Binding is left alone
# unless --tracker is also passed.
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
    name=$(basename "$skill")
    ln -sfn "../../.agents/skills/$name" "$DEST/.claude/skills/$name"
done

printf 'installed factory skills into %s/.agents\n' "$DEST"
printf 'tracker: '
sed -n 's/^tracker: //p' "$DEST/.agents/binding" | head -1
