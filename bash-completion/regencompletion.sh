#!/bin/bash

# Generate files to be installed in /usr/share/bash-completion/completions/ .

set -eo pipefail

bashlibs="${@:-bl*}"

cd "$(dirname "$0")"

PATH="../bin:$PATH"

for bl in ../bin/$bashlibs ; do
	blname="$(basename "$bl")"
	echo "$0: generate ${blname}-completion ..." >&2
	cat <<EOF > "${blname}-completion"
# © 2025 foopgp <info@foopgp.org>
# SPDX-License-Identifier: LGPL-3.0-only

if ${blname} --help > /dev/null ; then
  source ${blname} --bash-completion
fi
EOF

done
