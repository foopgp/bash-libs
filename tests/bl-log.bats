#!/usr/bin/env bats

# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

setup_file () {
	bats_require_minimum_version 1.5.0

	make -C "${BATS_TEST_DIRNAME}"/.. install DESTDIR="${BATS_FILE_TMPDIR}"
}

setup () {
	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
	TARGET="${BATS_FILE_TMPDIR}/usr/local/bin/"$(basename "${BATS_TEST_FILENAME}" .bats)
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
	TRESHOLD=3
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

@test "test_Fp_1_5_forward_to_syslog" {
	forward_to_syslog_test ()
	{
		printf "" | timeout 10s socat - UDP6-LISTEN:0 & TIMEOUT_PID=$!

		FAKE_SYSLOG_PORT=""
		while [[ "$FAKE_SYSLOG_PORT" = "" ]] && ps -p "$TIMEOUT_PID" > /dev/null
		do
			FAKE_SYSLOG_PID=$(ps --ppid "$TIMEOUT_PID" -o pid=)
			LSOF_RES=$(lsof -ai -p "$FAKE_SYSLOG_PID" || true)
			FAKE_SYSLOG_PORT=$(awk -F ':' '/UDP/ { print $NF }' <<< "$LSOF_RES")
		done

		"${TARGET}" --server ::1 --port "$FAKE_SYSLOG_PORT" debug "message"

		wait "$TIMEOUT_PID"
	}

	run --separate-stderr forward_to_syslog_test
	assert_success
	assert_equal "${#lines[@]}" '1'
	assert_regex "${lines[0]}"  '^<15>.* bl-log .* message$'
}

@test "test_Fc_1_1_linter" {
	shellcheck "${TARGET}"
}

@test "test_Fc_2_1_help_option # TODO" {
	target_base_name=$(basename "${TARGET}")

	run --separate-stderr "${TARGET}" -h
	assert_success
	assert_line --index 0 --regexp "^Usage: ${target_base_name}"
	assert_equal "${#stderr_lines[@]}" "0"

	run --separate-stderr "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: ${target_base_name}"
	assert_equal "${#stderr_lines[@]}" "0"
}

@test "test_Fc_2_2_version_option # TODO" {
	dirty_or_broken='\(dirty\|broken\)'
	commit_count='\([1-9][0-9]*\)'
	commit_hash='\(g[0-9a-f]\+\)'
	optional_dirty_or_broken='\(-dirty\|-broken\|\)'
	main_substit="s/-${commit_count}-${commit_hash}${optional_dirty_or_broken}\$/+\\1.\\2\\3/"
	dirty_broken_substit="s/-${dirty_or_broken}\$/+\\1/"
	git_desc=$(git describe --dirty --broken --always --match "v[0-9]*.[0-9]*.[0-9]*")
	version=$(sed "${main_substit}; ${dirty_broken_substit}" <<< "${git_desc}")
	target_base_name=$(basename "${TARGET}")
	expected="${target_base_name} ${version}"

	run --separate-stderr "${TARGET}" -V
	assert_success
	assert_equal "${lines[0]}"         "${expected}"
	assert_equal "${#lines[@]}"        "1"
	assert_equal "${#stderr_lines[@]}" "0"

	run --separate-stderr "${TARGET}" --version
	assert_success
	assert_equal "${lines[0]}"         "${expected}"
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
