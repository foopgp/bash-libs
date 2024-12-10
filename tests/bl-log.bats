#!/usr/bin/env bats

# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2046
# shellcheck disable=SC2154

setup () {
	bats_require_minimum_version 1.5.0

	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
	TARGET="${BATS_TEST_DIRNAME}"/../bin/$(basename "${BATS_TEST_FILENAME}" .bats)
}

@test "test_Fp_1_1_log_to_stderr # TODO" {
	for ITEM in Debug Info Notice Warning Error Crit Alert Emerg
	do
		item=$(echo "${ITEM}" | tr '[:upper:]' '[:lower:]')

		run --separate-stderr "${TARGET}" "${item}" "message"
		assert_success
		assert_equal "${#lines[@]}"        "0"
		assert_equal "${#stderr_lines[@]}" "1"
		assert_regex "${stderr_lines[0]}"  "${ITEM}: message$"
	done
}

@test "test_Fc_1_1_coding_style # TODO" {
	shfmt --space-redirects --diff "${TARGET}"
}

@test "test_Fc_1_2_linter # TODO" {
	shellcheck "${TARGET}"
}

@test "test_Fc_2_1_help_option # TODO" {
	run --separate-stderr "${TARGET}" -h
	assert_success
	assert_line --index 0 --regexp "^Usage: "$(basename "${TARGET}")
	assert_equal "${#stderr_lines[@]}" "0"

	run "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: "$(basename "${TARGET}")
	assert_equal "${#stderr_lines[@]}" "0"
}

@test "test_Fc_3_1_color" {
	run --separate-stderr ptywrap "${TARGET}" notice "message"
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  ".\[33mNotice:.\[0m message$"
}

@test "test_Fc_3_2_no_color" {
	run --separate-stderr "${TARGET}" notice "message"
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  "Notice: message$"
}
