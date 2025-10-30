#!/bin/bash

# Generate draft for manual pages (using help2man).

set -eo pipefail

bashlibs="${@:-bl*}"

cd "$(dirname "$0")"

PATH="../bin:$PATH"

versionstring=$(git describe --tag | sed -E ' s:^([0-9]+\.[0-9]+\.[0-9]+).*:\1: ')

for bl in ../bin/$bashlibs ; do
	blname="$(basename "$bl")"
	cat <<EOF > "${blname}.1.md.draft"
<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: ${blname^^}
section: 1
header: User Commands
footer: bash-libs
---

EOF
	echo "help2man --no-info $blname --locale C.UTF-8 | pandoc -f man -t markdown >> ${blname}.1.md.draft" >&2
	help2man --no-info "$blname" --locale "C.UTF-8" --version-string "$versionstring" | pandoc -f man -t markdown >> "${blname}.1.md.draft"

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

	# Ask for erasing previous man
	if ! colordiff --report-identical-files --unified "${blname}.1.md" "${blname}.1.md.draft" ; then
		mv -i "${blname}.1.md.draft" "${blname}.1.md" || true
	else
		rm -v "${blname}.1.md.draft"
	fi
done
