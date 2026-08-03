#!/usr/bin/env bats

# © 2026 Mnêmê (u5001777236237.945e_43.30_005.38) <mneme@foopgp.org>
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

	# T7 : primary key revoked (pub:r), via 'revkey' in its own homedir before import.
	# The 'revoked' verdict is reached only with --no-check-eid : in default mode a
	# revoked key's uids show validity 'r', so it classifies 'broken' (no non-revoked eid).
	_gen "Rev7 (u4=$EID1) <rev7@example.org>" ; T7=$RF
	gpg "${B[@]}" --homedir "$RH" --command-fd 0 --edit-key "$T7" >/dev/null 2>&1 <<-EOF
	revkey
	y
	0

	y
	save
	EOF
	_imp "$RH" "$T7" ; rm -rf "$RH"

	# cert_check is a pure read : settle the trustdb once here (as a real caller would
	# via update_trustdb) so verdicts don't ride on GnuPG's throttled auto-recompute.
	gpg "${B[@]}" --homedir "$HA" --check-trustdb >/dev/null 2>&1

	{ for v in HA T1 T2 T3 T4 T4s T5 T6 T7 ; do printf '%s=%q\n' "$v" "${!v}" ; done ; } > "$WOT/fprs.env"
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
	assert_success
	assert_output --regexp "u4${EID1} +uncertified$"
}

@test "cert_check -c : counts distinct external certifiers before the verdict" {
	wot
	# T1 is certified by the anchor only → exactly one external certifier.
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -c "0x$T1"
	assert_success
	assert_output --regexp "u4${EID1} +1 +certified$"
	# T2 is unsigned → zero external certifiers.
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -c "0x$T2"
	assert_success
	assert_output --regexp "u4${EID1} +0 +uncertified$"
	# The count sits between the email column and the verdict under -E too.
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -c -E "0x$T1"
	assert_success
	assert_output --regexp "alice@example.org.* u4${EID1} +1 +certified$"
}

@test "cert_check broken : conflicting eids on non-revoked uids" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T3"
	assert_success
	assert_output --regexp " - +broken$"
}

@test "cert_check broken : no eid at all" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T4"
	assert_success
	assert_output --regexp " - +broken$"
}

@test "cert_check broken : no email on any presentable uid" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T5"
	assert_success
	assert_output --regexp " - +broken$"
}

@test "cert_check eid on a non-f/u uid → uncertified (default)" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T6"
	assert_success
	assert_output --regexp "uncertified$"
}

@test "cert_check --no-check-eid : no-eid unsigned stays uncertified" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T4"
	assert_success
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
	assert_success
	assert_output --regexp "broken$"
}

@test "cert_check hides the email column by default (one line per cert)" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T1"
	assert_success
	assert_equal "${#lines[@]}" "1"
	refute_output --partial "alice@example.org"
	assert_output --regexp "certified$"
}

@test "cert_check -E renders the email column as '-' when no email is presentable" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -E "0x$T5"
	assert_success
	assert_output --regexp "^[0-9A-F]{40} -.*broken$"
}

@test "cert_check -q : no per-line output, exit code 0 when certified" {
	wot
	run --separate-stderr "${TARGET}" cert_check -q -H "$HA" "0x$T1"
	assert_success
	refute_output --partial "certified"
}

@test "cert_check -q : uncertified is exit code 196" {
	wot
	run --separate-stderr "${TARGET}" cert_check -q -H "$HA" "0x$T2"
	assert_failure 196
}

@test "cert_check -q : aggregate exit code, broken (198) dominates" {
	wot
	run --separate-stderr "${TARGET}" cert_check -q -H "$HA" "0x$T1" "0x$T3"
	assert_failure 198
}

@test "cert_check : a revoked key classifies broken by default (uids show 'r')" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" "0x$T7"
	assert_success
	assert_output --regexp "broken$"
}

@test "cert_check -L : a revoked key is 'revoked'" {
	wot
	run --separate-stderr "${TARGET}" cert_check -H "$HA" -L "0x$T7"
	assert_success
	assert_output --regexp "revoked$"
}

@test "cert_check -q -L : revoked is exit code 197" {
	wot
	run --separate-stderr "${TARGET}" cert_check -q -L -H "$HA" "0x$T7"
	assert_failure 197
}

# --- update_trustdb ---------------------------------------------------------
# Built once (cached in BATS_RUN_TMPDIR): an Anchor SECRET key (→ ultimate) and a
# Friend PUBLIC key, exported so each test can rebuild a fresh MUTABLE homedir, plus
# the ownertrust files update_trustdb consumes — signed/valid, unsigned, and
# signed-but-not-ownertrust.
build_utdb () {
	UTD="${BATS_RUN_TMPDIR}/pgpid-utdb"
	[[ -f "$UTD/utdb.env" ]] && return 0
	mkdir -p "$UTD"
	local B=(--no-options --batch --pinentry-mode loopback --passphrase '')
	local AH FH
	AH=$(mktemp -d) ; chmod 700 "$AH"
	gpg "${B[@]}" --homedir "$AH" --quick-generate-key "Anchor <anchor@example.org>" ed25519 sign 0 >/dev/null 2>&1
	AFPR=$(gpg --no-options --homedir "$AH" --with-colons -k | awk -F: '$1=="pub"{p=1} $1=="fpr"&&p{print $10;exit}')
	FH=$(mktemp -d) ; chmod 700 "$FH"
	gpg "${B[@]}" --homedir "$FH" --quick-generate-key "Friend <friend@example.org>" ed25519 sign 0 >/dev/null 2>&1
	FFPR=$(gpg --no-options --homedir "$FH" --with-colons -k | awk -F: '$1=="pub"{p=1} $1=="fpr"&&p{print $10;exit}')
	gpg "${B[@]}" --homedir "$AH" --export-secret-keys "$AFPR" > "$UTD/anchor-sec.gpg" 2>/dev/null
	gpg --no-options --homedir "$FH" --export "$FFPR" > "$UTD/friend-pub.gpg" 2>/dev/null
	printf '%s:5:\n' "$FFPR" > "$UTD/deleg.txt" ; gpg "${B[@]}" --homedir "$AH" --sign --output "$UTD/deleg.gpg" "$UTD/deleg.txt" 2>/dev/null
	printf '%s:4:\n' "$AFPR" > "$UTD/self.txt"  ; gpg "${B[@]}" --homedir "$AH" --sign --output "$UTD/self.gpg"  "$UTD/self.txt"  2>/dev/null
	printf '%s:5:\n' "$FFPR" > "$UTD/plain.txt"                                 # unsigned
	printf 'not ownertrust at all\n' > "$UTD/junk.txt" ; gpg "${B[@]}" --homedir "$AH" --sign --output "$UTD/junk.gpg" "$UTD/junk.txt" 2>/dev/null
	rm -rf "$AH" "$FH"
	{ for v in AFPR FFPR ; do printf '%s=%q\n' "$v" "${!v}" ; done ; } > "$UTD/utdb.env"
}

# Fresh mutable homedir : Anchor (secret → pinned ultimate) + Friend (public).
utdb_home () {
	build_utdb ; UTD="${BATS_RUN_TMPDIR}/pgpid-utdb" ; source "$UTD/utdb.env"
	UH="$BATS_TEST_TMPDIR/uh" ; mkdir -p "$UH" ; chmod 700 "$UH"
	gpg --no-options --batch --homedir "$UH" --import "$UTD/anchor-sec.gpg" "$UTD/friend-pub.gpg" 2>/dev/null
	gpg --no-options --batch --homedir "$UH" --import-ownertrust <<<"$AFPR:6:" 2>/dev/null
}

# update_trustdb writes everything to stderr : merge it so assert_output sees it.
# Force the C locale : these tests assert the English (source) messages, which are
# translated at runtime on a localized host once the .mo files are installed.
ut () { LC_ALL=C "${TARGET}" update_trustdb "$@" 2>&1 ; }

@test "update_trustdb help exits 0" {
	run --separate-stderr "${TARGET}" update_trustdb --help
	assert_success
	assert_line --index 0 --regexp "^Usage: "
}

@test "update_trustdb --batch applies a signed ownertrust, backs up, reports a diff" {
	utdb_home
	run ut --batch -H "$UH" "$UTD/deleg.gpg"
	assert_success
	assert_output --partial "backed up"
	assert_output --partial "+$FFPR:5:"
	assert_equal "$(gpg --no-options --homedir "$UH" --export-ownertrust | grep -c "^$FFPR:5:")" "1"
	assert_equal "$(ls "$UH"/ownertrust-backups/ | wc -l)" "1"
}

@test "update_trustdb is idempotent : re-applying leaves the ownertrust unchanged" {
	utdb_home
	ut --batch -H "$UH" "$UTD/deleg.gpg" >/dev/null
	run ut --batch -H "$UH" "$UTD/deleg.gpg"
	assert_success
	assert_output --partial "already applied"
}

@test "update_trustdb refuses a missing file" {
	utdb_home
	run ut --batch -H "$UH" "$UTD/nope.gpg"
	assert_failure 1
	assert_output --partial "cannot read or verify"
}

@test "update_trustdb refuses an unsigned file" {
	utdb_home
	run ut --batch -H "$UH" "$UTD/plain.txt"
	assert_failure 1
	assert_output --partial "cannot read or verify"
}

@test "update_trustdb refuses a signed file that is not ownertrust" {
	utdb_home
	run ut --batch -H "$UH" "$UTD/junk.gpg"
	assert_failure 1
	assert_output --partial "is not a valid ownertrust file"
}

@test "update_trustdb never overrides the anchor's own ownertrust" {
	utdb_home
	run ut --batch -H "$UH" "$UTD/self.gpg"
	assert_success
	assert_equal "$(gpg --no-options --homedir "$UH" --export-ownertrust | grep -c "^$AFPR:6:")" "1"
	refute_output --partial "$AFPR:4:"
}

@test "update_trustdb --batch with no file recomputes with check-trustdb" {
	utdb_home
	run ut --batch -H "$UH"
	assert_success
}

@test "update_trustdb without --batch runs the interactive gpg --update-trustdb" {
	utdb_home
	ut --batch -H "$UH" "$UTD/deleg.gpg" >/dev/null   # define every key's ownertrust first
	run ut -H "$UH" </dev/null                          # nothing left undefined → no prompt
	assert_success
}

# --- property : vCard-property uids (FN/NOTE/ADR/TEL/URL/LANG/GEO/EMAIL) ---

vkey () {	# a fresh throwaway vCard-uid key (secret, passphrase-less) per test
	VH="$BATS_TEST_TMPDIR/vh" ; mkdir -p "$VH" ; chmod 700 "$VH"
	local B=(gpg --no-options --batch --pinentry-mode loopback --passphrase '' --homedir "$VH")
	"${B[@]}" --allow-freeform-uid --quick-generate-key "UID:urn:eid:u4$EID1" ed25519 cert 0 2>/dev/null
	VFPR=$(gpg --no-options --homedir "$VH" --with-colons -K 2>/dev/null | awk -F: '$1=="fpr"{print $10;exit}')
	"${B[@]}" --quick-add-uid "$VFPR" 'FN:Alice Test' 2>/dev/null
	"${B[@]}" --quick-add-uid "$VFPR" 'Alice Test <alice@example.org>' 2>/dev/null
	"${B[@]}" --quick-add-uid "$VFPR" 'TEL;TYPE=home:+33612345678' 2>/dev/null
}

@test "property help exits 0" {
	run --separate-stderr "${TARGET}" property --help
	assert_success
	assert_line --index 0 --regexp "^Usage: "
}

@test "property unknown property is error 2" {
	run "${TARGET}" property bogus 0xDEADBEEF
	assert_failure 2
}

@test "email : eval-friendly output" {
	vkey
	run --separate-stderr "${TARGET}" email -H "$VH" "0x$VFPR"
	assert_success
	assert_output "alice@example.org"
}

@test "property phone : vCard parameters ignored, kept under --raw" {
	vkey
	run --separate-stderr "${TARGET}" property phone -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_TEL[0]='+33612345678'"
	run --separate-stderr "${TARGET}" property phone --raw -H "$VH" "0x$VFPR"
	assert_success
	assert_line --index 0 "TEL;TYPE=home:+33612345678"
}

@test "property --show-all : every property and the identity eid uid" {
	vkey
	run --separate-stderr "${TARGET}" property --show-all -H "$VH" "0x$VFPR"
	assert_success
	assert_line "pgpid_UID='urn:eid:u4$EID1'"
	assert_line "pgpid_FN='Alice Test'"
	# no EMAIL here : an address is not a vCard-property uid any more
	refute_line --partial "alice@example.org"
	assert_line "pgpid_TEL[0]='+33612345678'"
}

@test "property name --add : mono, previous FN revoked, eid uid stays primary" {
	vkey
	run --separate-stderr "${TARGET}" property name -y -A 'Alice Renamed' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_FN='Alice Renamed'"
	sleep 1
	run --separate-stderr "${TARGET}" property name --show-revoked -H "$VH" "0x$VFPR"
	assert_success
	assert_line "pgpid_FN_REVOKED[0]='Alice Test'"
	assert_line "pgpid_FN='Alice Renamed'"
	# set-primary pinned the eid uid back : gpg lists the primary uid first
	run bash -c "gpg --no-options --homedir '$VH' -k 2>/dev/null | grep -m1 '^uid'"
	assert_output --partial "UID:urn:eid:u4$EID1"
}

@test "email --revoke : the last usable email is retained" {
	vkey
	run --separate-stderr env LC_ALL=C "${TARGET}" email -R alice@example.org -K '' -H "$VH" "0x$VFPR"
	assert_failure 1
	[[ "$stderr" == *"must be retained"* ]]
}

@test "email : add then revoke roundtrip (bracketed input accepted)" {
	vkey
	run --separate-stderr "${TARGET}" email -A bob@example.org -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_line "bob@example.org"
	sleep 1
	run --separate-stderr "${TARGET}" email -y -R '<alice@example.org>' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "bob@example.org"
}

@test "property phone --revoke-all : no keeper, then 'Nothing to revoke' warning" {
	vkey
	run --separate-stderr env LC_ALL=C "${TARGET}" property phone -y --revoke-all -K '' -H "$VH" "0x$VFPR"
	assert_success
	refute_output --partial "pgpid_TEL["
	run --separate-stderr env LC_ALL=C "${TARGET}" property phone -y --revoke-all -K '' -H "$VH" "0x$VFPR"
	assert_success
	[[ "$stderr" == *"Nothing to revoke"* ]]
}

@test "email --revoke-all keeps the newest" {
	vkey
	"${TARGET}" email -A bob@example.org -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	sleep 1
	run --separate-stderr "${TARGET}" email -y --revoke-all -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "bob@example.org"
}

@test "property : invalid values and a double mono --add are rejected with error 2" {
	vkey
	local bad
	for bad in "email -A not-an-email" "phone -A 12345" "url -A notaurl" "lang -A x" "geo -A geo:abc" "name -A One -A Two" ; do
		run "${TARGET}" property $bad -K '' -H "$VH" "0x$VFPR"
		assert_failure 2
	done
}

@test "property note : multiline value survives the RFC 6350 backslash-n roundtrip" {
	vkey
	run --separate-stderr "${TARGET}" property note -A $'line1\nline2 : gnop' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_NOTE=$'line1\nline2 : gnop'"
	# stored form : ONE uid line, the newline RFC 6350-escaped
	run --separate-stderr "${TARGET}" property note --raw -H "$VH" "0x$VFPR"
	assert_success
	assert_output --partial 'NOTE:line1\nline2 : gnop'
	sleep 1
	run --separate-stderr "${TARGET}" property note -y -R $'line1\nline2 : gnop' -K '' -H "$VH" "0x$VFPR"
	assert_success
	refute_output --partial "pgpid_NOTE="
}

@test "property note : comma and semicolon are RFC 6350-escaped, decoded on display" {
	vkey
	run --separate-stderr "${TARGET}" property note -A 'a, b; c' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_NOTE='a, b; c'"
	run --separate-stderr "${TARGET}" property note --raw -H "$VH" "0x$VFPR"
	assert_success
	assert_output --partial 'NOTE:a\, b\; c'
}

@test "property address : structural ';' kept, literal ',' escaped" {
	vkey
	run --separate-stderr "${TARGET}" property address -A ';;1 rue A, B;Ville;;75000;FR' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_ADR[0]=';;1 rue A, B;Ville;;75000;FR'"
	run --separate-stderr "${TARGET}" property address --raw -H "$VH" "0x$VFPR"
	assert_success
	assert_output --partial 'ADR:;;1 rue A\, B;Ville;;75000;FR'
}

@test "gen_key pins the identity eid uid as the primary user ID" {
	local H="${BATS_TEST_TMPDIR}/genh" ; mkdir -p "$H" ; chmod 700 "$H"
	run "${TARGET}" gen_key -N Alice -E "u4$EID1" -C 'hi, there; ok' -p x -H "$H" alice@example.org
	assert_success
	local F ; F=$(gpg --no-options --homedir "$H" --with-colons -K | awk -F: '$1=="fpr"{print $10;exit}')
	# the eid uid's self-sig must carry the primary-user-id subpacket (25)…
	run bash -c "gpg --no-options --homedir '$H' --export '$F' | gpg --list-packets 2>/dev/null | awk '/user ID packet: .UID:urn:eid:/{f=1;next} /user ID packet:/{f=0} f&&/subpkt 25/{print \"PRIMARY\";exit}'"
	assert_output "PRIMARY"
	# …and the gen_key NOTE went through the same vCard escaping.
	run bash -c "gpg --no-options --homedir '$H' --export '$F' | gpg --list-packets 2>/dev/null | grep -o 'NOTE:[^\"]*'"
	assert_output 'NOTE:hi\, there\; ok'
}

@test "property note : a colon inside the value survives the x3a escaping roundtrip" {
	vkey
	run --separate-stderr "${TARGET}" property note -A 'see: https://foopgp.org' -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_output "pgpid_NOTE='see: https://foopgp.org'"
	sleep 1
	run --separate-stderr "${TARGET}" property note -y -R 'see: https://foopgp.org' -K '' -H "$VH" "0x$VFPR"
	assert_success
	refute_output --partial "pgpid_NOTE="
}

@test "property ksprefrd : add/replace the primary uid's preferred keyserver, read it back, guards" {
	vkey
	# none yet on the primary (the UID:urn:eid: uid)
	run --separate-stderr "${TARGET}" property ksprefrd --raw -H "$VH" "0x$VFPR"
	assert_success ; assert_output ""
	# add → subpacket 24 on the primary uid only, read back (eval then --raw)
	"${TARGET}" property ksprefrd --add hkps://keys.foopgp.org -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	run --separate-stderr "${TARGET}" property ksprefrd -H "$VH" "0x$VFPR"
	assert_output "pgpid_ksprefrd='hkps://keys.foopgp.org'"
	# only ONE uid (the primary) carries it, and the primary flag survives
	run bash -c "gpg --no-options --homedir '$VH' --export '0x$VFPR' 2>/dev/null | gpg --no-options --list-packets 2>/dev/null | grep -c 'preferred keyserver'"
	assert_output "1"
	run bash -c "gpg --no-options --homedir '$VH' --export '0x$VFPR' 2>/dev/null | gpg --no-options --list-packets 2>/dev/null | grep -c 'primary user ID'"
	assert_output "1"
	# --replace-to (synonym of --add) swaps it (sleep : distinct self-sig second)
	sleep 1
	"${TARGET}" property ksprefrd --replace-to hkp://foopgp.org:11371 -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	run --separate-stderr "${TARGET}" property ksprefrd --raw -H "$VH" "0x$VFPR"
	assert_output "hkp://foopgp.org:11371"
	# a non-hkp(s) value is refused
	run --separate-stderr env LC_ALL=C "${TARGET}" property ksprefrd --add https://foo -K '' -H "$VH" "0x$VFPR"
	assert_failure 2
	# --revoke is meaningless here
	run --separate-stderr env LC_ALL=C "${TARGET}" property ksprefrd --revoke x -H "$VH" "0x$VFPR"
	assert_failure 2
	# it is not a uid : never shown by --show-all
	run --separate-stderr "${TARGET}" property --show-all -H "$VH" "0x$VFPR"
	refute_output --partial "ksprefrd"
}

@test "property --to-vcard : vCard 4.0 wrapper, EMAIL;PREF, KEY;MEDIATYPE from subpacket 24, KEY inline" {
	vkey
	"${TARGET}" property ksprefrd --add hkp://foopgp.org:11371 -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	# strip CRLF and unfold (CRLF + leading space) so whole-line asserts work
	run bash -c "'${TARGET}' property --to-vcard -H '$VH' '0x$VFPR' 2>/dev/null | tr -d '\r' | sed ':a;N;\$!ba;s/\n //g'"
	assert_success
	assert_line "BEGIN:VCARD"
	assert_line "VERSION:4.0"
	assert_line "UID:urn:eid:u4$EID1"
	assert_line "FN:Alice Test"
	assert_line "EMAIL;PREF=1:alice@example.org"
	assert_line "KEY;MEDIATYPE=application/pgp-keys:http://foopgp.org:11371/pks/lookup?op=get&search=0x${VFPR,,}"
	assert_output --partial "KEY:data:application/pgp-keys;base64,"
	assert_line "END:VCARD"
}

@test "property ksprefrd : divergent keyservers across uids warn, primary kept" {
	vkey
	# keyserver A pinned on the primary (uid 1) …
	"${TARGET}" property ksprefrd --add hkps://keys.foopgp.org -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	sleep 1
	# … a different one planted on another (non-revoked) uid, uid 3
	printf 'uid 3\nkeyserver\nhkp://foopgp.org:11371\ny\nsave\n' | gpg --no-options --batch --pinentry-mode loopback --passphrase '' --homedir "$VH" --command-fd 0 --edit-key "0x$VFPR" >/dev/null 2>&1
	run --separate-stderr env LC_ALL=C "${TARGET}" property ksprefrd --raw -H "$VH" "0x$VFPR"
	assert_success
	assert_output "hkps://keys.foopgp.org"                 # the primary's value wins
	[[ "$stderr" == *"Several preferred keyservers"* ]]    # divergence flagged
}

@test "email --add delegates to property : both emails listed, eid uid stays primary" {
	vkey
	run --separate-stderr "${TARGET}" email -A bob@example.org -K '' -H "$VH" "0x$VFPR"
	assert_success
	assert_line "alice@example.org"
	assert_line "bob@example.org"
	run bash -c "gpg --no-options --homedir '$VH' -k 2>/dev/null | grep -m1 '^uid'"
	assert_output --partial "UID:urn:eid:u4$EID1"
}

@test "email --revoke keep-one : refuses to drop the last email-bearing uid" {
	vkey
	run --separate-stderr env LC_ALL=C "${TARGET}" email -R alice@example.org -K '' -H "$VH" "0x$VFPR"
	assert_failure 1
	[[ "$stderr" == *"must be retained"* ]]
}

lkey () {	# a fresh throwaway LEGACY key (name (u4=…) <email> uids) per test
	LH="$BATS_TEST_TMPDIR/lh" ; mkdir -p "$LH" ; chmod 700 "$LH"
	local B=(gpg --no-options --batch --pinentry-mode loopback --passphrase '' --homedir "$LH")
	"${B[@]}" --quick-generate-key "Alice Legacy (u4=$EID1) <alice@example.org>" ed25519 cert 0 2>/dev/null
	LFPR=$(gpg --no-options --homedir "$LH" --with-colons -K 2>/dev/null | awk -F: '$1=="fpr"{print $10;exit}')
	"${B[@]}" --quick-add-uid "$LFPR" "Alice Legacy (u4=$EID1) <alice.pro@example.org>" 2>/dev/null
}

@test "email --add upgrades a legacy certificate first : identity uid + FN: minted, legacy uids kept" {
	lkey
	run --separate-stderr "${TARGET}" email -A carol@example.org -K '' -H "$LH" "0x$LFPR"
	assert_success
	assert_line "alice.pro@example.org"
	assert_line "alice@example.org"
	assert_line "carol@example.org"
	run --separate-stderr "${TARGET}" property --show-all -H "$LH" "0x$LFPR"
	assert_line "pgpid_UID='urn:eid:u4$EID1'"
	assert_line "pgpid_FN='Alice Legacy'"
	# the legacy uids are NOT revoked (the web of trust rests on them)
	run bash -c "gpg --no-options --homedir '$LH' --with-colons -k 2>/dev/null | grep -c '^uid:u:.*Alice Legacy (u4='"
	assert_output "2"
	# the identity eid uid took the primary flag (listed first)
	run bash -c "gpg --no-options --homedir '$LH' -k 2>/dev/null | grep -m1 '^uid'"
	assert_output --partial "UID:urn:eid:u4$EID1"
}

@test "email --revoke retires a legacy address in a single call" {
	lkey
	"${TARGET}" email -A carol@example.org -K '' -H "$LH" "0x$LFPR" >/dev/null 2>&1
	run --separate-stderr "${TARGET}" email -y -R alice@example.org -K '' -H "$LH" "0x$LFPR"
	assert_success
	run --separate-stderr "${TARGET}" email -H "$LH" "0x$LFPR"
	refute_line "alice@example.org"
	assert_line "alice.pro@example.org"
	assert_line "carol@example.org"
	run bash -c "gpg --no-options --homedir '$LH' --with-colons -k 2>/dev/null | grep -c '^uid:r:.*<alice@example.org>'"
	assert_output "1"
}

@test "email --revoke drains the deprecated 'EMAIL:' shape before the name-addr one" {
	vkey
	# A certificate minted during the EMAIL: experiment carries both shapes for
	# the same address.
	gpg --no-options --batch --pinentry-mode loopback --passphrase '' --homedir "$VH" \
		--quick-add-uid "$VFPR" 'EMAIL: <alice@example.org>' 2>/dev/null
	run --separate-stderr "${TARGET}" email -y -R alice@example.org -K '' -H "$VH" "0x$VFPR"
	assert_success
	# the deprecated uid went first ; the name-addr one still carries the address
	run bash -c "gpg --no-options --homedir '$VH' --with-colons -k 2>/dev/null | grep -c '^uid:u:.*Alice Test <alice@example.org>'"
	assert_output "1"
	run bash -c "gpg --no-options --homedir '$VH' --with-colons -k 2>/dev/null | grep -c '^uid:r:.*EMAIL'"
	assert_output "1"
	run --separate-stderr "${TARGET}" email -H "$VH" "0x$VFPR"
	assert_line "alice@example.org"
}

@test "email --revoke keep-one counts legacy uids too" {
	lkey   # two legacy email uids (alice@, alice.pro@), no vCard, no upgrade
	# Peeling the first legacy email is allowed : a second one remains.
	run --separate-stderr "${TARGET}" email -y -R alice@example.org -K '' -H "$LH" "0x$LFPR"
	assert_success
	# The last remaining email is legacy-shaped : keep-one must still refuse it.
	run --separate-stderr env LC_ALL=C "${TARGET}" email -R alice.pro@example.org -K '' -H "$LH" "0x$LFPR"
	assert_failure 1
	[[ "$stderr" == *"must be retained"* ]]
}

ckey () {	# an anchor key (CH/AF) + an imported vCard-uid target (TH2/TF) per test
	CH="$BATS_TEST_TMPDIR/ch" ; TH2="$BATS_TEST_TMPDIR/th2"
	mkdir -p "$CH" "$TH2" ; chmod 700 "$CH" "$TH2"
	local B=(gpg --no-options --batch --pinentry-mode loopback --passphrase '')
	"${B[@]}" --homedir "$TH2" --allow-freeform-uid --quick-generate-key "UID:urn:eid:u4$EID1" ed25519 sign 0 2>/dev/null
	TF=$(gpg --no-options --homedir "$TH2" --with-colons -K 2>/dev/null | awk -F: '$1=="fpr"{print $10;exit}')
	"${B[@]}" --homedir "$TH2" --quick-add-uid "$TF" 'FN:Bob' 2>/dev/null
	"${B[@]}" --homedir "$TH2" --quick-add-uid "$TF" 'Bob <bob@example.org>' 2>/dev/null
	"${B[@]}" --homedir "$CH" --quick-generate-key 'Anchor <anchor@example.org>' ed25519 sign 0 2>/dev/null
	AF=$(gpg --no-options --homedir "$CH" --with-colons -K 2>/dev/null | awk -F: '$1=="fpr"{print $10;exit}')
	gpg --no-options --homedir "$TH2" --export "$TF" 2>/dev/null | gpg --no-options --homedir "$CH" --import 2>/dev/null
}

signed_uids () {	# uids of $TF carrying a signature from the anchor $AF
	gpg --no-options --homedir "$CH" --with-colons --check-sigs "0x$TF" 2>/dev/null \
		| awk -F: -v a="${AF: -16}" '$1=="uid"{u=$10} $1=="sig" && $5==a {print u}'
}

@test "certify signs only the identity uid of a vCard-uid certificate" {
	ckey
	run --separate-stderr "${TARGET}" certify -u "$AF" -K '' -H "$CH" "$EID1" "$TF" </dev/null
	assert_success
	run signed_uids
	assert_output --partial "UID\x3aurn\x3aeid\x3au4$EID1"
	refute_output --partial "FN"
	refute_output --partial "bob@example.org"
}

@test "certify --all-emails also signs the uids carrying an address" {
	ckey
	run --separate-stderr "${TARGET}" certify -E -u "$AF" -K '' -H "$CH" "$EID1" "$TF" </dev/null
	assert_success
	run signed_uids
	assert_output --partial "UID\x3aurn\x3aeid\x3au4$EID1"
	assert_output --partial "bob@example.org"
	refute_output --partial "FN"
}

@test "property revoke asks for irreversible-revocation confirmation ; declining keeps the uid" {
	vkey
	# TEL is not a keep-one property, so the revoke reaches the confirmation.
	run bash -c "echo n | env LC_ALL=C BL_INTERACTIVE_FRONTEND= '${TARGET}' property phone -R '+33612345678' -K '' -H '$VH' '0x$VFPR' 2>&1"
	assert_output --partial "IRREVERSIBLE"
	assert_output --partial "Revocation cancelled"
	# the phone survived : nothing was revoked
	run --separate-stderr "${TARGET}" property phone -H "$VH" "0x$VFPR"
	assert_line "pgpid_TEL[0]='+33612345678'"
}

@test "property revoke -y skips the confirmation and revokes" {
	vkey
	run --separate-stderr "${TARGET}" property phone -y -R '+33612345678' -K '' -H "$VH" "0x$VFPR"
	assert_success
	refute_output --partial "pgpid_TEL["
}

@test "email --add of a revoked address reports it is unaddable, not a PIN error" {
	vkey
	# a second usable email so keep-one lets us revoke the first
	"${TARGET}" email -A bob@example.org -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	sleep 1
	"${TARGET}" email -y -R alice@example.org -K '' -H "$VH" "0x$VFPR" >/dev/null 2>&1
	# re-adding it : OpenPGP keeps the revoked uid, gpg would refuse an identical
	# one — say so clearly instead of blaming the PIN.
	run --separate-stderr env LC_ALL=C "${TARGET}" email -A alice@example.org -K '' -H "$VH" "0x$VFPR"
	assert_success
	[[ "$stderr" == *"revoked earlier and cannot be added again"* ]]
	[[ "$stderr" != *"PIN"* ]]
	# the address did not come back to life
	refute_output --partial "alice@example.org"
}
