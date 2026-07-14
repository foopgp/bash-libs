#!/usr/bin/env bats

# © 2026 Mnêmê (u5=001777236237.945e_43.30_005.38) <mneme@foopgp.org>
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
U5=001777236237.945e_43.30_005.38

# Every test runs against its own throwaway tree (outside BATS_FILE_TMPDIR so
# teardown_file's "no leftover files" audit stays clean). The common setup()
# from setup_teardown.bash is redefined by this one, so re-do its work first.
setup () {
	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
	TARGET="${BATS_FILE_TMPDIR}/usr/local/bin/"$(basename "${BATS_TEST_FILENAME}" .bats)
	TREE="${BATS_TEST_TMPDIR}/tree"
}

ct () { LC_ALL=C "${TARGET}" "$@" 2>&1 ; }

### CLI scaffolding ###

@test "--help lists the 4 actions" {
	run --separate-stderr "${TARGET}" --help
	assert_success
	assert_line --index 0 --regexp "^Usage: $(basename "${TARGET}")"
	assert_output --partial " new "
	assert_output --partial " check "
	assert_output --partial " checknfix "
	assert_output --partial " properties "
}

@test "unrecognized action fails with 2" {
	run -2 "${TARGET}" frobnicate
	assert_output --partial "Error:"
}

### new ###

@test "new (u4): path output, CRLF, UID, KIND:individual" {
	run --separate-stderr "${TARGET}" new --path "$TREE" --eid "u4=$U4" --email jj@example.org Alice
	assert_success
	assert_output "$TREE/by-name/Alice/entity.vcf"
	# CRLF endings on every line
	run -1 grep -c $'[^\r]$' "$TREE/by-name/Alice/entity.vcf"
	run cat "$TREE/by-name/Alice/entity.vcf"
	assert_line $'BEGIN:VCARD\r'
	assert_line $'VERSION:4.0\r'
	assert_line $'FN:Alice\r'
	assert_line $'UID:urn:eid:u4'"$U4"$'\r'
	assert_line $'KIND:individual\r'
	assert_line $'EMAIL:jj@example.org\r'
	assert_line $'END:VCARD\r'
}

@test "new (u5): GEO derived from coord14, no KIND" {
	run --separate-stderr "${TARGET}" new --path "$TREE" --eid "$U5" Mnemo
	assert_success
	run cat "$TREE/by-name/Mnemo/entity.vcf"
	assert_line $'UID:urn:eid:u5'"$U5"$'\r'
	assert_line $'GEO:geo:43.30,5.38\r'
	refute_output --partial "KIND:"
}

@test "new: long UTF-8 FN folds at 75 octets on a character boundary" {
	local fn="Mnémosyne Ἑλληνική Déesse-Mémoire Antérieure-À-Hésiode Test-Pliage-Long"
	run --separate-stderr "${TARGET}" new --path "$TREE" "$fn"
	assert_success
	# no physical line exceeds 76 octets (75 + the folding space is on the next line)
	run -1 env LC_ALL=C grep -E -c '^.{77,}' "$TREE/by-name/$fn/entity.vcf"
	# an independent parser unfolds the very same FN back
	if command -v python3 >/dev/null && python3 -c 'import vobject' 2>/dev/null ; then
		run python3 -c "import vobject,sys; print(vobject.readOne(open(sys.argv[1],encoding='utf-8').read()).fn.value)" "$TREE/by-name/$fn/entity.vcf"
		assert_output "$fn"
	fi
}

@test "new: invalid eid fails with 2, existing file fails with 17" {
	run -2 --separate-stderr "${TARGET}" new --path "$TREE" --eid "u4=NOT_AN_EID" Bob
	run --separate-stderr "${TARGET}" new --path "$TREE" Carol
	assert_success
	run -17 --separate-stderr "${TARGET}" new --path "$TREE" Carol
}

@test "new --json: jCard with version/fn/uid/kind" {
	run --separate-stderr "${TARGET}" new --path "$TREE" --json --eid "u4=$U4" Dave
	assert_success
	assert_output "$TREE/by-name/Dave/entity.json"
	run python3 -c "
import json,sys
d=json.load(open(sys.argv[1]))
assert d[0]=='vcard', 'jCard tag'
assert ['version',{},'text','4.0'] in d[1]
assert ['fn',{},'text','Dave'] in d[1]
assert ['uid',{},'uri','urn:eid:u4$U4'] in d[1]
assert ['kind',{},'text','individual'] in d[1]
print('ok')" "$TREE/by-name/Dave/entity.json"
	assert_output "ok"
}

### check ###

@test "check: valid v4 file → 'valid' line with eid and FN, rc 0" {
	"${TARGET}" new --path "$TREE" --eid "u4=$U4" Alice >/dev/null
	run --separate-stderr "${TARGET}" check "$TREE/by-name/Alice/entity.vcf"
	assert_success
	assert_output --regexp "^urn:eid:u4$U4 +valid +4\.0 +Alice$"
}

@test "check: missing FN → invalid (quiet rc 197)" {
	run --separate-stderr "${TARGET}" check < <(printf 'BEGIN:VCARD\r\nVERSION:4.0\r\nEND:VCARD\r\n')
	assert_success
	assert_output --regexp "^- +invalid +4\.0 +$"
	run -197 "${TARGET}" check --quiet < <(printf 'BEGIN:VCARD\r\nVERSION:4.0\r\nEND:VCARD\r\n')
}

@test "check: version 3.0 → unsupported (quiet rc 196)" {
	run --separate-stderr "${TARGET}" check < <(printf 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Old\r\nEND:VCARD\r\n')
	assert_success
	assert_output --regexp "^- +unsupported +3\.0 +Old$"
	run -196 "${TARGET}" check --quiet < <(printf 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Old\r\nEND:VCARD\r\n')
}

@test "check: one summary line per card in a multi-card stream" {
	run --separate-stderr "${TARGET}" check < <(printf 'BEGIN:VCARD\r\nVERSION:4.0\r\nFN:One\r\nEND:VCARD\r\nBEGIN:VCARD\r\nVERSION:4.0\r\nFN:Two\r\nEND:VCARD\r\n')
	assert_success
	assert_line --index 0 --regexp "valid +4\.0 +One$"
	assert_line --index 1 --regexp "valid +4\.0 +Two$"
}

@test "check: empty input fails with 141" {
	run -141 --separate-stderr "${TARGET}" check < /dev/null
}

### checknfix ###

@test "checknfix: v3 → v4 (bare TYPE, CHARSET dropped, FN from N) passes check" {
	local v3='BEGIN:VCARD\nVERSION:3.0\nN:Brucker;Jean-Jacques;;;\nTEL;HOME;VOICE:+33612345678\nEMAIL;INTERNET;CHARSET=UTF-8:jj@example.org\nEND:VCARD\n'
	run --separate-stderr "${TARGET}" checknfix < <(printf "$v3")
	assert_success
	assert_line $'VERSION:4.0\r'
	assert_line $'FN:Jean-Jacques Brucker\r'
	assert_line $'TEL;TYPE=home;TYPE=voice:+33612345678\r'
	assert_line $'EMAIL;TYPE=internet:jj@example.org\r'
	run --separate-stderr bash -c "printf '$v3' | '${TARGET}' checknfix 2>/dev/null | '${TARGET}' check"
	assert_success
	assert_output --regexp "valid +4\.0 +Jean-Jacques Brucker$"
}

@test "checknfix: no FN nor N → fails" {
	run -1 --separate-stderr "${TARGET}" checknfix < <(printf 'BEGIN:VCARD\r\nVERSION:4.0\r\nTEL:+33612345678\r\nEND:VCARD\r\n')
}

@test "checknfix --in-place repairs the file itself" {
	mkdir -p "$TREE"
	printf 'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEND:VCARD\n' > "$TREE/fix.vcf"
	run --separate-stderr "${TARGET}" checknfix --in-place "$TREE/fix.vcf"
	assert_success
	run --separate-stderr "${TARGET}" check "$TREE/fix.vcf"
	assert_output --regexp "valid +4\.0 +John Doe$"
}

### properties ###

@test "properties: default listing excludes BEGIN/END, unfolds" {
	"${TARGET}" new --path "$TREE" --eid "u4=$U4" --url https://foopgp.org/ Alice >/dev/null
	run --separate-stderr "${TARGET}" properties "$TREE/by-name/Alice/entity.vcf"
	assert_success
	assert_line "VERSION:4.0"
	assert_line "FN:Alice"
	assert_line "URL:https://foopgp.org/"
	refute_output --partial "BEGIN:VCARD"
	refute_output --partial "END:VCARD"
}

@test "properties --add/--remove edit the file in place" {
	"${TARGET}" new --path "$TREE" --url https://foopgp.org/ Alice >/dev/null
	local f="$TREE/by-name/Alice/entity.vcf"
	run --separate-stderr "${TARGET}" properties --add 'TEL;TYPE=cell:+33612345678' --remove URL "$f"
	assert_success
	run --separate-stderr "${TARGET}" properties "$f"
	assert_line "TEL;TYPE=cell:+33612345678"
	refute_output --partial "URL:"
	# value-targeted removal, whatever the parameters
	run --separate-stderr "${TARGET}" properties --remove 'TEL:+33612345678' "$f"
	assert_success
	run --separate-stderr "${TARGET}" properties "$f"
	refute_output --partial "TEL"
	# still a valid vCard after the edits
	run --separate-stderr "${TARGET}" check "$f"
	assert_output --partial " valid "
}

@test "properties --add: malformed content line fails with 2" {
	run -2 --separate-stderr "${TARGET}" properties --add 'no colon here' /dev/null
}
