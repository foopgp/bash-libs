# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

# This is a common file only meant to be included in a dedicated test suit.

# shellcheck disable=SC2154
# shellcheck disable=SC2034

setup_file () {
	bats_require_minimum_version 1.5.0

	make -C "${BATS_TEST_DIRNAME}"/..   install DESTDIR="${BATS_FILE_TMPDIR}"
}

teardown_file () {
	make -C "${BATS_TEST_DIRNAME}"/.. uninstall DESTDIR="${BATS_FILE_TMPDIR}"
	file_list=$(ls -ARp1 "${BATS_FILE_TMPDIR}")
	run -1 grep '[^:/]$' <<< "${file_list}"
}

setup () {
	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
	TARGET="${BATS_FILE_TMPDIR}/usr/local/bin/"$(basename "${BATS_TEST_FILENAME}" .bats)
}
