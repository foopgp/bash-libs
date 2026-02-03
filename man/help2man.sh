#!/bin/bash

# Generate draft for manual pages (using help2man).

set -eo pipefail

versionstring=$(git describe --tag | sed -E ' s:.*([0-9]+\.[0-9]+\.[0-9]+).*:\1: ')

usage="Usage: $BASH_SOURCE [OPTIONS]..."
helpmsg="
Internal tool for this git repository: Generates man pages.

Options:
  -v, --target-version     set target version (default: $versionstring)
  -h, --help               show help and exit
  -V, --version            show version and exit ($(git describe --tag))
"

for ((;$#;)) ; do
	case "$1" in
		-v|--target-version) shift ; versionstring="$1" ;;
		-h|--help) printf "%s\n%s\n" "$usage" "$helpmsg" ; exit ;;
		-V|--version) printf "%s %s\n" "$BASH_SOURCE" "$(git describe --tag)" ; exit ;;
		--) shift ; break ;;
		-*) printf "%s: Error: unrecognized option '%s'\nTry '%s --help' for more information.\n" "$BASH_SOURCE" "$1" "$BASH_SOURCE" >&2 ; return 2 ;;
		*) break ;;
	esac
	shift
done

bashlibs="${@:-bl*}"

cd "$(dirname "$0")"

PATH="../bin:$PATH"

for bl in ../bin/$bashlibs ; do
	namedesc=$(LANG=C.UTF-8 $bl --help | sed -n '/^$/ {n;p;q}')
	blname=$(basename "$bl")
	cat <<EOF > "${blname}.1.md.draft"
<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: ${blname^^}
section: 1
header: User Commands
footer: bash-libs $versionstring
---

EOF
	echo "help2man --no-info $blname --locale C.UTF-8 ... | pandoc -f man -t markdown >> ${blname}.1.md.draft" >&2
	help2man --no-info "$blname" --locale "C.UTF-8" --version-string "$versionstring" --name "$namedesc"  | pandoc -f man -t markdown >> "${blname}.1.md.draft"

	cat "${blname}.1.md.extra" >> "${blname}.1.md.draft" || true
	cat <<EOF >> "${blname}.1.md.draft"

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

EOF

	# Fix 2 artefacts.
	sed -i ' s, \.\./bin/bl-, bl-, ; /All actions .*/i \\ ' "${blname}.1.md.draft"
	# Fix 2 more artefacts.
	sed -i 's,(É.),(Ɉ), ; s,^Main options:,## Main options:,' "${blname}.1.md.draft"

	# Ask for erasing previous man
	if ! colordiff --report-identical-files --unified "${blname}.1.md" "${blname}.1.md.draft" ; then
		mv -i "${blname}.1.md.draft" "${blname}.1.md" || true
	else
		rm -v "${blname}.1.md.draft"
	fi
done
