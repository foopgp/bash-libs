#!/usr/bin/env bats

# © 2026 Mnêmê (u5001777236237.945e_43.30_005.38) <mneme@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

load ./setup_teardown.bash

@test "linter: shellcheck clean under the global .shellcheckrc" {
	# lint the repo source: the .shellcheckrc lookup starts from the script dir
	shellcheck -x "${BATS_TEST_DIRNAME}/../bin/$(basename "${TARGET}")"
}

U4=sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76

# Build a minimal instance holding one canonical by-eid/ leaf (record only, no
# manifests yet) by sourcing the lib to reach its internal helpers.
build_tree () {
	local R="$1"
	source "${TARGET}" -- 2>/dev/null
	local L="$R/by-eid/u4/sR/sRyU/$U4"
	_bl_uetree_write_format_chain "$R" "$L" "*"
	cat > "$L/entity.vcf" <<-VCF
	BEGIN:VCARD
	VERSION:4.0
	UID:urn:eid:u4$U4
	KIND:individual
	FN:Jean-Jacques Brucker
	EMAIL:jjbrucker@foopgp.org
	TEL;TYPE=voice:+33612345678
	END:VCARD
	VCF
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

@test "test_Fc_unknown_action_is_error_2" {
	run "${TARGET}" bogus
	assert_failure 2
}

@test "test_Fp_aliases_rebuild_gives_identical_manifests_and_clean_check" {
	R="${BATS_TEST_TMPDIR}/t1"; mkdir -p "$R"; build_tree "$R"
	run "${TARGET}" aliases --rebuild "$R"
	assert_success
	# every position of the entity carries a byte-identical manifest
	mapfile -t als < <(find "$R" -name .ALIASES)
	n=$(md5sum "${als[@]}" | awk '{print $1}' | sort -u | wc -l)
	assert_equal "$n" "1"
	run "${TARGET}" check "$R"
	assert_success
}

@test "test_Fp_resolve_by_email_follows_alias_to_canonical" {
	R="${BATS_TEST_TMPDIR}/t2"; mkdir -p "$R"; build_tree "$R"
	"${TARGET}" aliases --rebuild "$R"
	run "${TARGET}" resolve -t "$R" -q jjbrucker@foopgp.org
	assert_success
	assert_output --partial "/by-eid/u4/sR/sRyU/$U4/"
}

@test "test_Fp_resolve_annotates_trust_certified_for_by_eid" {
	R="${BATS_TEST_TMPDIR}/t3"; mkdir -p "$R"; build_tree "$R"
	"${TARGET}" aliases --rebuild "$R"
	run "${TARGET}" resolve -t "$R" "u4=$U4"
	assert_success
	assert_output --regexp "^certified[[:space:]]"
}

@test "test_Fp_leaves_branch_filter" {
	R="${BATS_TEST_TMPDIR}/t4"; mkdir -p "$R"; build_tree "$R"
	"${TARGET}" aliases --rebuild "$R"
	run "${TARGET}" leaves -b eid "$R"
	assert_success
	assert_output --partial "/by-eid/u4/sR/sRyU/$U4"
	# an alias branch holds no canonical leaf
	run "${TARGET}" leaves -b email "$R"
	assert_success
	assert_output ""
}

@test "test_Fp_check_detects_missing_FN" {
	R="${BATS_TEST_TMPDIR}/t5"; mkdir -p "$R"; build_tree "$R"
	"${TARGET}" aliases --rebuild "$R"
	sed -i '/^FN:/d' "$R/by-eid/u4/sR/sRyU/$U4/entity.vcf"
	run "${TARGET}" check "$R"
	assert_failure
}

@test "test_Fp_check_detects_divergent_manifest" {
	R="${BATS_TEST_TMPDIR}/t6"; mkdir -p "$R"; build_tree "$R"
	"${TARGET}" aliases --rebuild "$R"
	echo "uetree 1.2 - /by-name/fr/x/xx/xxx/" >> "$(find "$R/by-email" -name .ALIASES | head -1)"
	run "${TARGET}" check "$R"
	assert_failure
}

@test "test_Fc_source_in_bash_with_double_dash" {
	run --separate-stderr bash -c "source '${TARGET}' -- && type -t _bl_uetree_slugify"
	assert_success
	assert_output "function"
}
