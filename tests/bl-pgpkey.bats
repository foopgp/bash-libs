#!/usr/bin/env bats

# © 2026 Mnêmê (u5=001777236237.945e_43.30_005.38) <mneme@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

load ./setup_teardown.bash

BIN="${BATS_TEST_DIRNAME}/../bin"

@test "linter: bl-pgpkey shellcheck clean under the global .shellcheckrc" {
	shellcheck -x "${BIN}/bl-pgpkey"
}

@test "linter: bl-qrkey deprecation shim shellcheck clean" {
	shellcheck -x "${BIN}/bl-qrkey"
}

@test "bl-pgpkey --help lists the actions" {
	run --separate-stderr "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: .*bl-pgpkey"
	assert_output --partial "totoken"
	assert_output --partial "scan"
	assert_output --partial "change_token_code"
}

@test "bl-qrkey wrapper: program mode execs bl-pgpkey (same version, deprecation warning)" {
	run --separate-stderr "${BIN}/bl-qrkey" --version
	assert_success
	assert_output --regexp "^bl-pgpkey "
	# the warning goes to stderr
	[ -n "$stderr" ]
}

@test "bl-qrkey wrapper: sourced mode exposes bl_qrkey_* shims delegating to bl_pgpkey_*" {
	run bash -c 'source "'"${BIN}"'/bl-qrkey" -- 2>/dev/null
		for f in totoken scan change_token_code change_token_meta print token_retries change_passphrase ; do
			[[ "$(type -t bl_qrkey_$f)" == function ]] || { echo "MISSING bl_qrkey_$f" ; exit 1 ; }
		done
		bl_qrkey_totoken --version'
	assert_success
	assert_output --regexp "bl_pgpkey_totoken "
}

@test "bl-qrkey wrapper: the frozen consumer contract is present" {
	# pgpid-qrscan sources and calls these ; djibian-onboarding runs the last two.
	run bash -c 'source "'"${BIN}"'/bl-pgpkey" -- 2>/dev/null
		for f in bl_pgpkey_scan bl_pgpkey_totoken bl_pgpkey_change_token_code bl_pgpkey_change_token_meta ; do
			[[ "$(type -t $f)" == function ]] || { echo "MISSING $f" ; exit 1 ; }
		done ; echo ok'
	assert_success
	assert_output --partial ok
}
