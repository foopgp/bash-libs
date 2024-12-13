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

@test "test_Fp_1_1_log_to_stderr" {
	for ITEM in Debug Info Notice Warning Error Crit Alert Emerg
	do
		item=$(echo "${ITEM}" | tr '[:upper:]' '[:lower:]')

		run --separate-stderr "${TARGET}" --no-act "${item}" "message"
		assert_equal "${#lines[@]}"        "0"
		assert_equal "${#stderr_lines[@]}" "1"
		assert_regex "${stderr_lines[0]}"  "${ITEM}: message$"
	done
}

@test "test_Fp_1_2_exit_on_level_above_threshold" {
	LOG_LEVELS=(emerg alert crit err warning notice info debug)
	LEVEL_INDEXS="  0     1    2   3       4      5    6     7"

	for TRESHOLD in $LEVEL_INDEXS
	do
		threshold="${LOG_LEVELS[$TRESHOLD]}"

		for LEVEL in $LEVEL_INDEXS
		do
			level="${LOG_LEVELS[$LEVEL]}"

			echo "${TARGET}" --no-act --log-exit "${threshold}" "${level}"
			run --separate-stderr "${TARGET}" --no-act --log-exit "${threshold}" "${level}" "message"
			if [[ "$LEVEL" -le "$TRESHOLD" ]]
			then
				assert_equal "$status" $(( 168 + LEVEL ))
			else
				assert_success
			fi
			assert_equal "${#lines[@]}"        "0"
			assert_equal "${#stderr_lines[@]}" "1"
		done
	done
}

@test "test_Fp_1_3_do_not_log_low_criticality" {
	LOG_LEVELS=(emerg alert crit err warning notice info debug)
	LEVEL_INDEXS="  0     1    2   3       4      5    6     7"

	for TRESHOLD in $LEVEL_INDEXS
	do
		for LEVEL in $LEVEL_INDEXS
		do
			level="${LOG_LEVELS[$LEVEL]}"

			echo "${TARGET}" --no-act --log-level "${TRESHOLD}" "${level}"
			run --separate-stderr "${TARGET}" --no-act --log-level "${TRESHOLD}" "${level}" "message"
			assert_equal "${#lines[@]}"        "0"
			if [[ "$LEVEL" -le "$TRESHOLD" ]]
			then
				assert_equal "${#stderr_lines[@]}" "1"
			else
				assert_equal "${#stderr_lines[@]}" "0"
			fi
		done
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
	run --separate-stderr ptywrap "${TARGET}" --no-act notice "message"
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  ".\[33mNotice:.\[0m message$"
}

@test "test_Fc_3_2_no_color" {
	run --separate-stderr "${TARGET}" --no-act notice "message"
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  "Notice: message$"
}
