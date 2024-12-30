#!/usr/bin/env bats

# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2046
# shellcheck disable=SC2154

load ./setup_teardown.bash

@test "test_Fc_1_1_linter" {
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

@test "test_Fc_2_2_version_option" {
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
