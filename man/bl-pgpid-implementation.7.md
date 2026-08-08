<!--
© 2026 Jean-Jacques Brucker (u4sRyUhEbNU5OwyLEjfSwaXAe_42.17-002.76) <jjbrucker@foopgp.org>
© 2026 Mnêmê (u5001777236237.945e_43.30_005.38 claude-opus-5) <mneme@foopgp.org>

SPDX-License-Identifier: CC-BY-SA-4.0+
-->

---
title: BL-PGPID-IMPLEMENTATION
section: 7
header: Implementation notes
footer: bash-libs
---

# NAME

bl-pgpid-implementation - design choices and field experience behind bl-pgpid

# DESCRIPTION

**bl-pgpid**(1) is an interpreted script: every comment line is read at every
run, and nothing strips them. So the source keeps only what cannot be deduced
from the code itself — an external constraint, a non-obvious trap, an invariant
— and points here. The reasoning, the alternatives we rejected and the mistakes
we made live in this page.

One page per bash-libs domain, one section per subject.

# OPENPGP UID SHAPES

## What a foopgp certificate carries

| uid | Shape | Role |
|---|---|---|
| identity | `UID:urn:eid:u4…` / `UID:urn:eid:u5…` | The self-certified anchor. This is what the web of trust signs. **Not** the primary uid — see below. |
| name | `FN:Alice Martin` | vCard `FN` property. |
| note, phone, address, url, lang, geo | `NOTE:…`, `TEL:…`, `ADR:…`, … | vCard properties (RFC 6350), one uid each — independently certifiable and revocable. |
| address | `Alice Martin <alice@example.org>` | A **plain RFC 5322 name-addr uid**. Deliberately *not* a vCard-property uid. |

The last row is the exception, and it was learned the hard way.

## The EMAIL: <addr> false trail (July to August 2026)

Addresses were briefly minted as vCard-property uids too — `EMAIL:
<alice@example.org>` — so that every uid would follow one rule. GnuPG accepted
the string and the suite was green, but a mail client does not read a uid as a
structured record: it parses RFC 5322 *name-addr*, so the display name came out
literally `EMAIL:`. Evolution could not send to the address at all; Thunderbird
pasted `EMAIL:` into the `To:` field. An earlier bench had already found that
*discovery by email* failed for every shape but a bare addr-spec — the same root
cause one layer earlier, which we read as a lookup quirk and papered over with a
space after the colon.

Addresses went back to `Name <addr>` (JJB, 2026-08-02); every other property
stayed. What survives is the substantial half: the eid now has its **own
self-certified uid** instead of squatting the comment field of an address uid,
so the anchor is a first-class identity that the web of trust signs directly.

In the code, `property` no longer knows about email; `email` mints the uid
itself (`--name`, else the certificate's `FN:`, else the local part); the legacy
upgrade stopped minting an address uid, a legacy uid being name-addr already;
`--revoke` drains the deprecated `EMAIL:` shape first; `to_vcard` sources its
EMAIL lines from name-addr uids, so the emitted vCard never changed.

**The lesson.** An OpenPGP uid is not a free-form record: anything containing an
address gets parsed as a name-addr by third-party software, so the display-name
slot is not ours to repurpose. Try a new uid shape **in a real mail client**
before minting it on a published certificate — a uid revocation is permanent,
and the exact revoked string can never be added again.

# UNIX USER IDS DERIVED FROM AN EID

`gen_uid` maps an eid onto an almost-unique Unix user ID. Choosing the usable
range took some measuring — hence `BL_PGPID_XUID_MIN` and `BL_PGPID_XUID_MAX`.

## What the system allows

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

## What it actually accepts

```
$ LANG=C.UTF-8 sudo useradd -u 4294967295 test
useradd: invalid user ID '4294967295'                      → exit 3

$ LANG=C.UTF-8 sudo useradd -u 4294967294 test
useradd warning: test's uid -2 outside of the UID_MIN 1000
                 and UID_MAX 60000 range.                  → exit 0
```

Note the warning: `useradd` already prints that uid back as **-2**. The 32-bit
value is being handled as signed somewhere.

## The range we settled on

Reserving 4294967294 and 4294967293, plus everything under 2^18 (262144), for
future use or convention leaves 262144 … 4294967292 — 4294705148 slots, about
half the current human population (~8 billion).

That is the theory. In practice **anything at or above 2^31 causes trouble**,
almost certainly because a lot of software manipulates uids as signed rather
than unsigned integers. `BL_PGPID_XUID_MAX` was therefore lowered to
2^31-2 = 2147483646, which still leaves ~2.15 billion slots.

# CERTIFICATION

## What gets signed

By default, **only the identity uid** (`UID:urn:eid:…`).

A name may be a pseudonym, and certifying an address is a claim that you
verified *the address* — which calls for a proof-of-control challenge, not the
in-person fingerprint check that a certification party provides. Signing the
anchor says "this key belongs to this entity", which is exactly what was
verified and no more.

Certificates with no identity uid (legacy shape) fall back to every uid matching
the target identifier, as before.

## -E, --all-emails

Some software judges trust by looking at whether the uid *carrying the address*
is signed. This flag appends every non-revoked address-bearing uid to the signed
set, deduplicated against what was already selected. It applies to `--revoke`
symmetrically, so a certification can be withdrawn the same way it was made.

It became more useful once addresses went back to plain name-addr uids: they are
now fully visible to third-party tooling, which will judge them by their
certifications.

## Counting certifications (email --certs-count)

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

## Options that were removed

- `--vouch` / `--vouch-for` — stubs that always returned "Not implemented yet".
- `--force-sign-key` — existed to unrevoke or change vouching; it lost its
  purpose with them, and overwriting an existing certification sits badly with a
  web of trust where certifying is meant to be deliberate.
- `ultimate` as an `--ownertrust` value — ultimate trust is what you assign to
  your *own* keys; offering it when certifying someone else invites a mistake
  that silently widens the trust anchor.
- `--only-email` — certifying the address while deliberately leaving the eid
  anchor out. Written, then reverted before any release (JJB, 2026-08-06).

# PROPERTIES, AND THE VCARD VIEWS

One action does one thing (JJB, 2026-08-07). `property` handles one property
of one certificate ; the views that span the whole certificate belong to
`to_vcard`, which offers three:

| command | scope |
|---|---|
| `to_vcard` | the vCard itself — uats plus the recognized uids |
| `to_vcard --raw` | every uid, transposable or not |
| `property <p> --info` | the values of *that* property, as `key=value` |
| `email --info` | the addresses, as `key=value` |

`to_vcard` briefly had an `--info` of its own. It answered the wrong question —
the vCard's EMAIL lines come from name-addr uids, which are not properties — and
was removed rather than fixed. Addresses are `email`'s business, which is where
`--info` and `--show-unusable` went.

## The default output is for the eye

`property <p>` prints the values themselves, one per line. `--info` is what
makes the output parseable, and it alone marks the uids that no longer stand,
by a `_UNUSABLE` suffix on the variable name. A multi-line note therefore prints
across several lines under the default: making it unambiguous is `--info`'s
job, not the default's.

## Usable, or not — nothing finer

Field 2 of `gpg --with-colons` mixes two axes: web-of-trust validity
(`o i n m f u q -`) and lifecycle (`r e d`). GnuPG's DETAILS spells the letters
out for *keys*, leaves their meaning on uids and uats largely implicit, and
warns that "additional information may follow" one we already know. We first
split the output into `_REVOKED` and `_EXPIRED`; the honest reading is coarser
(JJB, 2026-08-08) — a uid either still stands or it does not. One suffix,
`_UNUSABLE`, one flag, `--show-unusable`.

`_bl_pgpid_uid_stands()` is therefore an **allow** list, not a deny list: a
letter we have never seen counts as unusable, because defaulting to "usable" is
the dangerous side to be wrong on. `m` belongs in it — marginal validity says
the web of trust vouches for the key weakly, not that the uid is dead. Leaving
it out hid a third of the addresses on a real contact's certificate.

## Two traps for anyone calling this from outside bash

**`${value@Q}` quotes two ways.** Plain `'value'` most of the time, but bash
ANSI-C `$'value'` as soon as the value holds a newline or a quote — which a
NOTE routinely does. A parser that reads only the first form sees an empty
list where a multi-line note sits, and an empty list is indistinguishable
from an empty certificate. This cost an afternoon in the Tauri application;
it is the reason the default output is now the bare value.

**Omitting the key selector costs ~415 ms.** Without a trailing
NAME|EMAIL|KEYID|U4|U5, bl-pgpid asks scdaemon which key to work on: ~660 ms
against ~245 ms with the certificate fingerprint, measured. An interface that
reads six properties per refresh pays it six times over. Pass the fingerprint
whenever you already hold one — and note that `pgpid_Ckeyfpr` is read from
the certificate, so it can be missing offline, where the scdaemon path is the
correct fallback.

## Key resolution, in two levels

"Take the target, else the key on the connected token, else ask" was written
out at five call sites, and they were not all doing the same thing: only
`email` and `property` went on to resolve the answer to exactly one
certificate. Hence two helpers rather than one — `_bl_pgpid_default_key` for
the choice, `_bl_pgpid_resolve_key` for the choice plus the resolution.

The card field is a parameter, not a hidden default: `certify` wants
`pgpid_Ckeyfpr` because the certification key is precisely what it needs,
where the others want `pgpid_Skeyfpr`. Written out five times that difference
read as an inconsistency; as an argument it reads as the intent it is.

# THE PRIMARY-USER-ID FLAG BELONGS TO THE MAIN ADDRESS

Subpacket 25 marks, by long-standing OpenPGP convention, the holder's **main
email address**. Mail clients read the signer's identity there. Point it at an
address-less uid and they report a sender/signer mismatch — Evolution does,
verbatim: *« les adresses de l'expéditeur et du signataire ne correspondent
pas »*.

Between 2026-07-17 and 2026-08-05 we pinned it on the eid anchor instead, for
one reason: the anchor is minted first, so it is the oldest uid, and a
keyserver's FIFO uid cap evicts oldest-first. The primary flag was the only
thing keeping it. That is now onak's job — `cap_packet_type()` shields one uid
matching `^UID:urn:` on its own — so the flag went back where it belongs.

What that means per function:

| function | primary flag |
|---|---|
| `gen_key` | set once, on the `Name <addr>` uid |
| `_bl_pgpid_upgrade_uids` | untouched — a legacy cert already has it where its holder wants it |
| `email --add` | untouched — adding an address is not a claim about which one is main |
| `email --revoke` | re-pinned on the newest remaining address, but only when the revocation left a non-address uid in charge (see below) |
| `property` | untouched — a vCard property has no business moving it |

`email` deliberately has **no --primary option**: whoever wants to move the flag
has `gpg --quick-set-primary-uid`, and an extra option here would be API
surface, hence bug surface, for no gain (JJB, 2026-08-05).

## Revoking an address does not move the flag

Measured on gpg 2.4.7, 2026-08-06. Revoke the uid carrying subpacket 25 and:

1. **The flag does not move.** It stays frozen in the self-signature of the
   now-revoked uid, where it is inert but still visible in `--list-packets`.
2. **gpg silently falls back on the newest remaining uid** — whatever its shape.
   Not "the next one", and not the eid anchor either (which is minted first, so
   it never rises). What rises is the *last property minted*:

| certificate | main identity after revoking the primary address |
|---|---|
| eid + `FN:` + address | `FN:Alice` |
| eid + `FN:` + address + `NOTE:` | `NOTE:…` — the holder's motto, shown as their identity |
| eid + `FN:` + address + 2nd address | the 2nd address, *only* because it happened to be the newest |

`_bl_pgpid_fix_primary()` closes this. It reads the **first uid gpg lists** —
which is what every tool takes as the main identity, whether that comes from the
flag or from the fallback — and, when that uid carries no address, re-pins the
flag on the newest remaining address. No-op otherwise, so revoking a secondary
address leaves the operator's choice alone.

The keep-one guard guarantees there is always an address left to re-pin on.

## Never trust gpg's uid listing order

Never assert the primary flag through gpg's **listing order**. Several uids
minted within the same second come back in an unstable order, which makes such a
test pass and fail on alternate runs — measured. Read subpacket 25 out of
`gpg --list-packets` instead; the bats suite does.

The same instability reaches `--edit-key`, where `uid N` is an **index** into
that very listing (a string matches nothing). gpg promotes the effective primary
uid to the front, so uids minted back to back keep their packet order only as
long as they land in the same second: let the clock tick between two mints and
every hardcoded index shifts. Read the index back from `--with-colons` right
before the edit-key session — `bl_pgpid_image` does, and the T6 test fixture now
does too. `ksprefrd`'s `uid 1` is safe for the opposite reason: it means
*whatever gpg currently considers primary*, which is exactly what that code
wants.

# SEE ALSO

[**bl-pgpid**](bl-pgpid.1.md)(1), [**bash-libs**](bash-libs.7.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.
