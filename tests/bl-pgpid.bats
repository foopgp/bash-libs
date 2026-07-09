#!/usr/bin/env bats

# © 2026 Mnèmê (u5=001777236237.945e_43.30_005.38) <mneme@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

# shellcheck disable=SC2154
# shellcheck source=/dev/null

load ./setup_teardown.bash

# A throwaway Web of Trust, built once for the whole file:
#   Anchor holds the only SECRET key (→ ultimate). Targets are PUBLIC-only imports,
#   so their uid validity comes solely from the anchor's certifications.
# --no-options everywhere so the system-wide shared keyring (/etc/gnupg → a *.kbx)
# never leaks into fingerprint extraction. Verdicts are queried by fingerprint, so
# they stay deterministic whether or not that shared keyring exists.
EID1='sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76'
EID2='AAAAAAAAAAAAAAAAAAAAAAe_42.17-002.76'

build_wot () {
	# Outside BATS_FILE_TMPDIR so teardown_file's "no leftover files" audit stays clean.
	WOT="${BATS_RUN_TMPDIR}/pgpid-wot"
	[[ -f "$WOT/fprs.env" ]] && return 0
	HA="$WOT/ha" ; mkdir -p "$HA" ; chmod 700 "$HA"
	local B=(--no-options --batch --pinentry-mode loopback --passphrase '')
	local RH RF u

	_gen () { RH=$(mktemp -d) ; chmod 700 "$RH"
		gpg "${B[@]}" --homedir "$RH" --quick-generate-key "$1" ed25519 sign 0 >/dev/null 2>&1
		RF=$(gpg --no-options --homedir "$RH" --with-colons -k | awk -F: '$1=="pub"{p=1} $1=="fpr"&&p{print $10;exit}')
		shift ; for u in "$@" ; do gpg "${B[@]}" --homedir "$RH" --quick-add-uid "$RF" "$u" >/dev/null 2>&1 ; done ; }
	_imp ()  { gpg --no-options --homedir "$1" --export "$2" 2>/dev/null | gpg --no-options --homedir "$HA" --import >/dev/null 2>&1 ; }
	# Exportable certification (not lsign): only public sigs count — cert_check ignores local ones.
	_sign () { gpg "${B[@]}" --homedir "$HA" --yes --quick-sign-key "$1" >/dev/null 2>&1 ; }

	gpg "${B[@]}" --homedir "$HA" --quick-generate-key "Anchor <anchor@example.org>" ed25519 sign 0 >/dev/null 2>&1

	_gen "Alice (u4=$EID1) <alice@example.org>" ; T1=$RF ; _imp "$RH" "$T1" ; rm -rf "$RH" ; _sign "$T1"
	_gen "Bob (u4=$EID1) <bob@example.org>"     ; T2=$RF ; _imp "$RH" "$T2" ; rm -rf "$RH"
	_gen "Carol (u4=$EID1) <carol@example.org>" "Carol2 (u4=$EID2) <carol2@example.org>" ; T3=$RF ; _imp "$RH" "$T3" ; rm -rf "$RH"
	_gen "Dan <dan@example.org>"                ; T4=$RF ; _imp "$RH" "$T4" ; rm -rf "$RH"
	_gen "Dave <dave@example.org>"              ; T4s=$RF; _imp "$RH" "$T4s"; rm -rf "$RH" ; _sign "$T4s"
	_gen "Eve (u4=$EID1)"                        ; T5=$RF ; _imp "$RH" "$T5" ; rm -rf "$RH"

	# T6 : eid on a NON-f/u uid ; the f/u uid (the plain one) has no eid.
	_gen "Al6 (u4=$EID1) <a6@example.org>" "Plain6 <b6@example.org>" ; T6=$RF ; _imp "$RH" "$T6" ; rm -rf "$RH"
	gpg "${B[@]}" --homedir "$HA" --command-fd 0 --edit-key "$T6" >/dev/null 2>&1 <<-EOF
	uid 2
	sign
	y
	save
	EOF

	{ for v in HA T1 T2 T3 T4 T4s T5 T6 ; do printf '%s=%q\n' "$v" "${!v}" ; done ; } > "$WOT/fprs.env"
}

# Load only the fingerprints/HA path into the test shell (NOT the lib: sourcing it
# inside a function would make its `declare -r` constants function-local). cert_check
# is exercised as the installed program instead.
wot () { build_wot ; source "${BATS_RUN_TMPDIR}/pgpid-wot/fprs.env" ; }

@test "cert_check help exits 0" {
	run --separate-stderr "${TARGET}" cert_check --help
	assert_success
	assert_line --index 0 --regexp "^Usage: "
}

@test "cert_check unknown option is error 2" {
	run "${TARGET}" cert_check --bogus
	assert_failure 2
}

@test "cert_check -E shows email : anchor-signed, single eid+email" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -E "0x$T1"
	assert_success
	assert_output --regexp "alice@example.org.* u4${EID1} +certified$"
}

@test "cert_check uncertified : unsigned, single eid+email" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T2"
	assert_failure 1
	assert_output --regexp "u4${EID1} +uncertified$"
}

@test "cert_check broken : conflicting eids on non-revoked uids" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T3"
	assert_failure 196
	assert_output --regexp " - +broken$"
}

@test "cert_check broken : no eid at all" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T4"
	assert_failure 196
	assert_output --regexp " - +broken$"
}

@test "cert_check broken : no email on any presentable uid" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T5"
	assert_failure 196
	assert_output --regexp " - +broken$"
}

@test "cert_check eid on a non-f/u uid → uncertified (default)" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T6"
	assert_failure 1
	assert_output --regexp "uncertified$"
}

@test "cert_check --no-check-eid : no-eid unsigned stays uncertified" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T4"
	assert_failure 1
	assert_output --regexp "uncertified$"
}

@test "cert_check --no-check-eid : no-eid anchor-signed becomes certified" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T4s"
	assert_success
	assert_output --regexp "certified$"
}

@test "cert_check --no-check-eid : eid-on-non-f/u uid becomes certified" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T6"
	assert_success
	assert_output --regexp "certified$"
}

@test "cert_check --no-check-eid still breaks on missing email" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T5"
	assert_failure 196
}

@test "cert_check hides the email column by default (one line per cert)" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T1"
	assert_success
	assert_equal "${#lines[@]}" "1"
	refute_output --partial "alice@example.org"
	assert_output --regexp "certified$"
}

@test "cert_check aggregate exit status: broken dominates (196)" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T1" "0x$T3"
	assert_failure 196
}
