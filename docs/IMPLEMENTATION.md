<!--
© 2026 Jean-Jacques Brucker (u4sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76) <jjbrucker@foopgp.org>
© 2026 Mnêmê Opus-5 (u5001777236237.945e_43.30_005.38) <mneme@foopgp.org>

SPDX-License-Identifier: CC-BY-SA-4.0+
-->

# Implementation notes

Design choices and field experience that do not belong in the sources.

These are interpreted scripts: every comment line is read at every run, and
nothing strips them. So the code keeps only what cannot be deduced from the
code itself — an external constraint, a non-obvious trap, an invariant. The
reasoning, the alternatives we rejected and the mistakes we made live here.

One section per subject. When this file outgrows ~2000 lines, split it.

---

## OpenPGP uid shapes (`bl-pgpid`)

### What a foopgp certificate carries

| uid | Shape | Role |
|---|---|---|
| identity | `UID:urn:eid:u4…` / `UID:urn:eid:u5…` | The self-certified anchor. Primary uid. This is what the web of trust signs. |
| name | `FN:Alice Martin` | vCard `FN` property. |
| note, phone, address, url, lang, geo | `NOTE:…`, `TEL:…`, `ADR:…`, … | vCard properties (RFC 6350), one uid each — independently certifiable and revocable. |
| address | `Alice Martin <alice@example.org>` | A **plain RFC 5322 name-addr uid**. Deliberately *not* a vCard-property uid. |

The last row is the exception, and it was learned the hard way.

### The `EMAIL: <addr>` false trail (July → August 2026)

**The idea.** One uid per piece of information, every uid aligned on a vCard
property. It is a good model: it makes each fact separately certifiable, gives
`--to-vcard` a trivial mapping, and frees the uid comment field — which the eid
had been squatting as `Alice (u4=…) <alice@example.org>`. Addresses were made to
follow the same rule, as `EMAIL: <alice@example.org>`.

**Why it looked fine.** GnuPG accepts the string, the uid appears in listings,
key lookup by fingerprint works, and the test suite was green. Nothing in the
OpenPGP layer objects.

**Why it broke.** A mail client does not read a uid as a structured record. It
parses it as an RFC 5322 *name-addr*: display-name followed by `<addr-spec>`.
`EMAIL: <alice@example.org>` therefore parses as a display name literally equal
to `EMAIL:`. Observed on real clients:

- **Evolution** — could not send to the address at all.
- **Thunderbird** (desktop and mobile) — sent, but pasted `EMAIL:` into the
  `To:` field.

**The warning we under-weighted.** An earlier bench test had already found that
*discovery by email* failed for every shape except a bare addr-spec. We read it
as a lookup quirk and worked around it by putting a space after the colon. It
was the same root cause, showing up one layer earlier.

**The decision** (JJB, 2026-08-02). Addresses leave the vCard-property family
and go back to `Name <addr>`. Every other property stays as it is.

**What survives from the experiment** — and it is the substantial part: the eid
now has its **own self-certified uid** instead of living in a comment field. The
address uid no longer has to carry `(u4=…)`, and the anchor is a first-class
identity that the web of trust signs directly.

**Consequences in the code.** `bl_pgpid_property` no longer knows about email;
`bl_pgpid_email` mints the uid itself (`--name`, else the certificate's `FN:`,
else the local part); the legacy upgrade stopped minting an address uid, since a
legacy uid is already name-addr and a second one would only split its
third-party certifications; `--revoke` drains the deprecated `EMAIL:` shape
first; `--to-vcard` sources its `EMAIL` lines from name-addr uids, so the
emitted vCard is unchanged. Storage shape and output format are now independent.

**What to take away.** An OpenPGP uid is not a free-form record. Anything
containing an address will be parsed as a name-addr by third-party software, so
the display-name slot is not ours to repurpose. Test a new uid shape **in a real
mail client** before minting it on a published certificate: a uid revocation is
permanent, and the exact revoked string can never be added again.

---

## Unix user IDs derived from an eid (`bl-pgpid gen_uid`)

`gen_uid` maps an OpenPGP eid onto an almost-unique Unix user ID. Choosing the
usable range took some measuring — hence `BL_PGPID_XUID_MIN` and
`BL_PGPID_XUID_MAX`.

### What the system allows

Since Linux 2.6 a uid is coded on 32 bits, so it should range from 0 (root) to
2^32-1 = 4294967295. Older Unix systems used 16 bits (0 to 65535), with the
conventions that still hold today:

- `0` — root
- under `1000` — "system" users
- `1000` — the main "human" user (often also the first administrator)
- above `1000` — other "human" users
- `65534` — `nobody`, by convention

See the [Debian policy on users and
groups](https://www.debian.org/doc/debian-policy/ch-opersys.html#users-and-groups).

### What it actually accepts

```
$ LANG=C.UTF-8 sudo useradd -u 4294967295 test
useradd: invalid user ID '4294967295'                      → exit 3

$ LANG=C.UTF-8 sudo useradd -u 4294967294 test
useradd warning: test's uid -2 outside of the UID_MIN 1000
                 and UID_MAX 60000 range.                  → exit 0
```

Note the warning: `useradd` already prints that uid back as **-2**. The 32-bit
value is being handled as signed somewhere.

### The range we settled on

Reserving 4294967294 and 4294967293, plus everything under 2^18 (262144), for
future use or convention leaves 262144 … 4294967292 — 4294705148 slots, about
half the current human population (~8 billion).

That is the theory. In practice **anything at or above 2^31 causes trouble**,
almost certainly because a lot of software manipulates uids as signed rather
than unsigned integers. `BL_PGPID_XUID_MAX` was therefore lowered to
2^31-2 = 2147483646, which still leaves ~2.15 billion slots.

---

## Certification (`bl-pgpid certify`)

### What gets signed

By default, **only the identity uid** (`UID:urn:eid:…`).

A name may be a pseudonym, and certifying an address is a claim that you
verified *the address* — which calls for a proof-of-control challenge, not the
in-person fingerprint check that a certification party provides. Signing the
anchor says "this key belongs to this entity", which is exactly what was
verified and no more.

Certificates with no identity uid (legacy shape) fall back to every uid matching
the target identifier, as before.

### `-E, --all-emails`

Some software judges trust by looking at whether the uid *carrying the address*
is signed. This flag appends every non-revoked address-bearing uid to the signed
set, deduplicated against what was already selected. It applies to `--revoke`
symmetrically, so a certification can be withdrawn the same way it was made.

It became more useful once addresses went back to plain name-addr uids: they are
now fully visible to third-party tooling, which will judge them by their
certifications.

### Counting certifications (`email --certs-count`)

The count must reflect what a *third party* can verify, so it uses
`--check-sigs` rather than `--list-sigs`: gpg then actually verifies each
signature and tags the valid ones `!`. Unknown signers (`?`), bad signatures
(`-`) and errors (`%`) are not counted, and neither are self-signatures.

**Local signatures inflate the count** (found 2026-06-23). A non-exportable
`lsign` — sigclass ending in `l`, e.g. `10l` — looks like a certification in
your own keyring but exists nowhere else; it was one of us local-signing another
member's certificate that surfaced this. They are filtered out.

When the same address appears on several uids, the maximum is kept: what matters
is how well vouched the address is, not how many uids happen to carry it.

### Options that were removed

- `--vouch` / `--vouch-for` — stubs that always returned "Not implemented yet".
- `--force-sign-key` — existed to unrevoke or change vouching; it lost its
  purpose with them, and overwriting an existing certification sits badly with a
  web of trust where certifying is meant to be deliberate.
- `ultimate` as an `--ownertrust` value — ultimate trust is what you assign to
  your *own* keys; offering it when certifying someone else invites a mistake
  that silently widens the trust anchor.
