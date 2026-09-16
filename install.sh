#!/bin/sh
# Overlay the kernel into a consuming repo. Never deletes dest-only files.
#
# Text files (SKILL.md and the rest): three-way merge with git merge-file
# against .agents/.factory-base (last installed kernel). Local edits and
# kernel updates both land in the dest file.
# --force: take the kernel file (discard dest edits on that path).
# --tracker github|pyramid writes .agents/binding.
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

command -v git >/dev/null 2>&1 || { printf 'install: git is required for SKILL.md merges\n' >&2; exit 1; }

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONFLICTS=0
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# kernel_file dest_file base_file
merge_one() {
    kernel=$1
    dest=$2
    base=$3
    mkdir -p "$(dirname "$dest")" "$(dirname "$base")"
    if test ! -f "$dest"; then
        cp "$kernel" "$dest"
        cp "$kernel" "$base"
        return 0
    fi
    if cmp -s "$kernel" "$dest"; then
        cp "$kernel" "$base"
        return 0
    fi
    if test "$FORCE" -eq 1; then
        cp "$kernel" "$dest"
        cp "$kernel" "$base"
        return 0
    fi
    if test ! -f "$base"; then
        printf 'install: skip %s (local file, no vendor base; --force to take kernel)\n' "$dest" >&2
        return 0
    fi
    set +e
    git merge-file "$dest" "$base" "$kernel"
    rc=$?
    set -e
    if test "$rc" -eq 0; then
        cp "$kernel" "$base"
        return 0
    fi
    if test "$rc" -gt 0 && test "$rc" -lt 128; then
        printf 'install: CONFLICT %s (%s hunks); resolve markers then commit .factory-base\n' "$dest" "$rc" >&2
        CONFLICTS=$((CONFLICTS + 1))
        return 0
    fi
    printf 'install: git merge-file failed on %s\n' "$dest" >&2
    return 1
}

for part in skills references bindings scripts; do
    srcroot="$HERE/.agents/$part"
    destroot="$DEST/.agents/$part"
    baseroot="$DEST/.agents/.factory-base/$part"
    find "$srcroot" -type f > "$TMP"
    while IFS= read -r kernel; do
        rel=${kernel#"$srcroot"/}
        merge_one "$kernel" "$destroot/$rel" "$baseroot/$rel"
    done < "$TMP"
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

mkdir -p "$DEST/.claude/skills"
for skill in "$DEST/.agents/skills"/*; do
    test -e "$skill" || continue
    name=$(basename "$skill")
    ln -sfn "../../.agents/skills/$name" "$DEST/.claude/skills/$name"
done

printf 'installed factory skills into %s/.agents (3-way merge; dest-only paths kept)\n' "$DEST"
printf 'tracker: '
sed -n 's/^tracker: //p' "$DEST/.agents/binding" | head -1
if test "$CONFLICTS" -gt 0; then
    printf 'install: %s file(s) have conflict markers; fix them before using the skills\n' "$CONFLICTS" >&2
    exit 1
fi
