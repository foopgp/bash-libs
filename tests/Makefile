# © 2024 Henri GEIST <geist.henri@laposte.net>
# © 2026 Mnèmê (u5=001777236237.945e_43.30_005.38) <mneme@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only
#
# Plain bats runner. The reqflow / tappy requirement-traceability machinery was
# dropped 2026-07-07 (heavy, uninstalled, and broke `make check`) — cf. JJB.

BATS       := bats
SHELLCHECK := shellcheck
SUITES     := $(wildcard *.bats)

.POSIX:
.PHONY: all build check clean

all: check

build:

check:
	@if command -v $(SHELLCHECK) >/dev/null ; then $(SHELLCHECK) setup_teardown.bash $(SUITES) ; else echo "note: $(SHELLCHECK) not installed, skipping lint" ; fi
	$(BATS) $(SUITES)

clean:
	$(RM) -r results
