# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

TARGETS            := $(patsubst %.bats, %.tap, $(wildcard *.bats))
SPECS_DIR          := ../specs
RESULTS_DIR        := results

SHELL              := /bin/sh
REQFLOW            := reqflow stat -s
TAP_CONSUMER       := tappy --verbose
SHELLCHECK         := shellcheck --enable all

BATS_FLAGS         := -F tap13
REQFLOW_COMMON_OPT := -type        "txt"
REQFLOW_COMMON_OPT += -sort        "alphanum"
REQFLOW_SPECS_OPT  := $(REQFLOW_COMMON_OPT)
REQFLOW_SPECS_OPT  += -start-after "^\\\s*== Requirements"
REQFLOW_SPECS_OPT  += -req         "^\\\|\\\s*<<(F[pc]_[1-9]([0-9_]*[0-9])?)>>"
REQFLOW_SPECS_OPT  += -end-req     "^\\\|==="
REQFLOW_SPECS_OPT  += -stop-after  "^\\\s*== Rationals"
REQFLOW_TESTS_OPT  := $(REQFLOW_COMMON_OPT)
REQFLOW_TESTS_OPT  += -stop-after  "^Bail out!"
REQFLOW_TESTS_OPT  += -req         "^((not )?ok\\\s+\\\d+)\\\s"
REQFLOW_TESTS_OPT  += -end-req     "^1[.][.]"
REQFLOW_TESTS_OPT  += -ref         "^[no][ok].*\\\s+\\\d+\\\stest_(F[pc]_[1-9]([0-9_]*[0-9])?)"
REQFLOW_TESTS_OPT  += -nocov

.POSIX:
.SUFFIXES:
.SECONDARY:
.DELETE_ON_ERROR:

all: check

build: $(addprefix $(RESULTS_DIR)/, $(TARGETS))

check: $(patsubst %.tap, check_%, $(TARGETS))
	$(SHELLCHECK)   $(TARGETS:.tap=.bats)
	$(TAP_CONSUMER) $(RESULTS_DIR)

clean:
	$(RM) $(addprefix $(RESULTS_DIR)/, $(TARGETS))
	$(RM) $(TARGETS:.tap=.req)

.PHONY: all build check clean phony

# CAUTION: you need to keep the two blank line between 'define' and 'endef'
define NEWLINE


endef

$(foreach ITEM, $(TARGETS), check_$(ITEM:.tap=): $(RESULTS_DIR)/$(ITEM)$(NEWLINE))

check_%: %.req phony
	RESULT=$$($(REQFLOW) -c $< 2>&1) || (printf "%s\n" "$$RESULT" && exit 1)

$(RESULTS_DIR)/%.tap: %.bats ../bin/% Makefile | $(RESULTS_DIR)
	-./$< $(BATS_FLAGS) > $@

%.req: Makefile
	echo 'document $(@:.req=-specs) -path   "$(SPECS_DIR)/$(@:.req=.adoc)" $(REQFLOW_SPECS_OPT)' >  $@
	echo 'document $(@:.req=-tests) -path "$(RESULTS_DIR)/$(@:.req=.tap)"  $(REQFLOW_TESTS_OPT)' >> $@

$(RESULTS_DIR):
	mkdir -p $@
