#!/usr/bin/env bats

# © 2024 Henri GEIST <geist.henri@laposte.net>
# © 2026 Jean-Jacques Brucker (u4=sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76) <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

load ./setup_teardown.bash

@test "linter: shellcheck clean under the global .shellcheckrc" {
	# lint the repo source: the .shellcheckrc lookup starts from the script dir
	shellcheck -x "${BATS_TEST_DIRNAME}/../bin/$(basename "${TARGET}")"
}

@test "test_Fp_1_1_log_to_stderr" {
	LOG_LEVELS=(Emerg Alert Crit Error Warning Notice Info Debug)
	LEVEL_INDEXS="  0     1    2     3       4      5    6     7"

	for ITEM in "${LOG_LEVELS[@]}"
	do
		item=$(echo "${ITEM}" | tr '[:upper:]' '[:lower:]')

		run --separate-stderr "${TARGET}" --no-act "${item}" "message"
		assert_equal "${#lines[@]}"        "0"
		assert_equal "${#stderr_lines[@]}" "1"
		assert_regex "${stderr_lines[0]}"  "${ITEM}: message$"
	done

	for ITEM in ${LEVEL_INDEXS}
	do
		run --separate-stderr "${TARGET}" --no-act "${ITEM}" "message"
		assert_equal "${#lines[@]}"        "0"
		assert_equal "${#stderr_lines[@]}" "1"
		assert_regex "${stderr_lines[0]}"  "${LOG_LEVELS[$ITEM]}: message$"
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

			run --separate-stderr "${TARGET}" --no-act --log-exit "${threshold}" "${level}" "message"
			echo "$BATS_RUN_COMMAND"
			if [[ "$LEVEL" -le "$TRESHOLD" ]]
			then
				assert_equal "$status" $(( 168 + LEVEL ))
			else
				assert_success
			fi
			assert_equal "${#lines[@]}"        "0"
			assert_equal "${#stderr_lines[@]}" "1"

			run --separate-stderr "${TARGET}" --no-act --log-exit "${TRESHOLD}" "${level}" "message"
			echo "$BATS_RUN_COMMAND"
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
		threshold="${LOG_LEVELS[$TRESHOLD]}"

		for LEVEL in $LEVEL_INDEXS
		do
			level="${LOG_LEVELS[$LEVEL]}"

			run --separate-stderr "${TARGET}" --no-act --log-level "${threshold}" "${level}" "message"
			echo "$BATS_RUN_COMMAND"
			assert_equal "${#lines[@]}"        "0"
			if [[ "$LEVEL" -le "$TRESHOLD" ]]
			then
				assert_equal "${#stderr_lines[@]}" "1"
			else
				assert_equal "${#stderr_lines[@]}" "0"
			fi

			run --separate-stderr "${TARGET}" --no-act --log-level "${TRESHOLD}" "${level}" "message"
			echo "$BATS_RUN_COMMAND"
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

@test "test_Fp_1_4_default_exit_level" {
	LOG_LEVELS=(emerg alert crit err warning notice info debug)
	LEVEL_INDEXS="  0     1    2   3       4      5    6     7"
	TRESHOLD=0
	threshold="${LOG_LEVELS[$TRESHOLD]}"

	for LEVEL in $LEVEL_INDEXS
	do
		level="${LOG_LEVELS[$LEVEL]}"

		run --separate-stderr "${TARGET}" --no-act "${level}" "message"
		echo "$BATS_RUN_COMMAND"
		if [[ "$LEVEL" -le "$TRESHOLD" ]]
		then
			assert_equal "$status" $(( 168 + LEVEL ))
		else
			assert_success
		fi
		assert_equal "${#lines[@]}"        "0"
		assert_equal "${#stderr_lines[@]}" "1"
	done
}

# Disabled 2026-07-07 (JJB): kept for reference (socat is a useful, widespread tool) —
# re-enable when bl-log is put back in service.
# @test "test_Fp_1_5_forward_to_syslog" {
# 	forward_to_syslog_test ()
# 	{
# 		printf "" | timeout 10s socat - UDP6-LISTEN:0 & TIMEOUT_PID=$!
#
# 		FAKE_SYSLOG_PORT=""
# 		while [[ "$FAKE_SYSLOG_PORT" = "" ]] && ps -p "$TIMEOUT_PID" > /dev/null
# 		do
# 			FAKE_SYSLOG_PID=$(ps --ppid "$TIMEOUT_PID" -o pid=)
# 			LSOF_RES=$(lsof -ai -p "$FAKE_SYSLOG_PID" || true)
# 			FAKE_SYSLOG_PORT=$(awk -F ':' '/UDP/ { print $NF }' <<< "$LSOF_RES")
# 		done
#
# 		"${TARGET}" --server ::1 --port "$FAKE_SYSLOG_PORT" debug "message"
#
# 		wait "$TIMEOUT_PID"
# 	}
#
# 	run --separate-stderr forward_to_syslog_test
# 	assert_success
# 	assert_equal "${#lines[@]}" '1'
# 	assert_regex "${lines[0]}"  '^<15>.* bl-log .* message$'
# }


# Disabled 2026-07-08 (JJB): Until code is ready for a well configured shellcheck (cf: .shellcheckrc)
# @test "test_Fc_1_1_linter" {
## 	shellcheck "${TARGET}"
# }

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

@test "test_Fc_2_3_source_in_bash_with_any_options" {
	source "${TARGET}"

	run --separate-stderr bash -s << EOF
	source "${TARGET}"
	bl_log --no-act Notice "message"
EOF
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  "Notice: message$"
}

@test "test_Fc_3_2_no_color" {
	run --separate-stderr "${TARGET}" --no-act notice "message"
	assert_success
	assert_equal "${#lines[@]}"        "0"
	assert_equal "${#stderr_lines[@]}" "1"
	assert_regex "${stderr_lines[0]}"  "Notice: message$"
}
