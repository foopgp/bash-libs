#!/usr/bin/env bats

# © 2026 Mnêmê (u5=001777236237.945e_43.30_005.38) <mneme@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

load ./setup_teardown.bash

@test "linter: shellcheck clean under the global .shellcheckrc" {
	shellcheck -x "${BATS_TEST_DIRNAME}/../bin/bl-foopgp"
}

@test "--help exits 0 with a usage line" {
	run --separate-stderr "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: "
}

@test "unknown action fails with 2" {
	run -2 "${TARGET}" frobnicate_xyz
	assert_output --partial "Error:"
}
