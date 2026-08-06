#!/usr/bin/env bats

# © 2024 Henri GEIST <geist.henri@laposte.net>
# © 2026 Jean-Jacques Brucker (u4=sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76) <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154

load ./setup_teardown.bash

# Re-enabled 2026-07-14: the library is clean under the global .shellcheckrc.
@test "test_Fc_1_1_linter" {
	# lint the repo source: the .shellcheckrc lookup starts from the script dir
	shellcheck -x "${BATS_TEST_DIRNAME}/../bin/$(basename "${TARGET}")"
}

@test "test_Fc_help_option" {
	run --separate-stderr "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: $(basename "${TARGET}")"
	assert_equal "${#stderr_lines[@]}" "0"

	run "${TARGET}" -h
	assert_success
	assert_line --index 0 --regexp "^Usage: $(basename "${TARGET}")"
	assert_equal "${#stderr_lines[@]}" "0"
}

@test "test_Fc_version_option" {
	run --separate-stderr "${TARGET}" --version
	assert_success
	assert_line --index 0 --regexp "^$(basename "${TARGET}") "
	assert_equal "${#lines[@]}"        "1"
	assert_equal "${#stderr_lines[@]}" "0"

	run --separate-stderr "${TARGET}" -V
	assert_success
	assert_line --index 0 --regexp "^$(basename "${TARGET}") "
	assert_equal "${#lines[@]}"        "1"
	assert_equal "${#stderr_lines[@]}" "0"
}

