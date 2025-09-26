# © 2024 Henri GEIST <geist.henri@laposte.net>
#
# SPDX-License-Identifier: LGPL-3.0-only

DOCUMENTS             := $(wildcard bl-*.adoc)

PDF_THEME             := pdf-theme.yml
IMAGES_DIR            := images

SHELL                 := /bin/sh
ASCIIDOCTOR           := asciidoctor
ASCIIDOCTOR_PDF       := asciidoctor-pdf
DOCBOOK_TO_MARKDOWN   := pandoc -f docbook -t markdown
REQFLOW               := reqflow stat -s

GIT_DATE              := git log -n 1
GIT_DATE              += --date=format:"%-d/%-m/%-Y"
GIT_DATE              += --pretty=format:"%cd"
COMMIT_DATE           := $(shell $(GIT_DATE))

GIT_DESCRIBE          := git describe --dirty --broken --always --match "v[0-9]*.[0-9]*.[0-9]*"
DIRTY_BROKEN          := \(dirty\|broken\)
COMMIT_COUNT          := \([1-9][0-9]*\)
COMMIT_HASH           := \(g[0-9a-f]\+\)
OPTIONAL_DIRTY_BROKEN := \(-$(DIRTY_BROKEN)\|\)
PLUS_POST_TAG_ID      := -e 's/-$(COMMIT_COUNT)-$(COMMIT_HASH)$(OPTIONAL_DIRTY_BROKEN)$$/+\1.\2\3/1'
PLUS_DIRTY_BROKEN     := -e 's/-$(DIRTY_BROKEN)$$/+\1/1'
COMMIT_DESCRIPTION    := $(shell $(GIT_DESCRIBE) | sed $(PLUS_POST_TAG_ID) $(PLUS_DIRTY_BROKEN))

ASCIIDOCTOR_FLAGS     := -a revdate='$(COMMIT_DATE)'
ASCIIDOCTOR_FLAGS     += -a docdate='$(COMMIT_DATE)'
ASCIIDOCTOR_FLAGS     += -a revnumber='$(COMMIT_DESCRIPTION)'
ASCIIDOCTOR_FLAGS     += -a source-highlighter=rouge
ASCIIDOCTOR_FLAGS     += -a imagesdir=$(IMAGES_DIR)
ASCIIDOCTOR_FLAGS     += -r asciidoctor-diagram

ASCIIDOCTOR_PDF_FLAGS := $(ASCIIDOCTOR_FLAGS)
ASCIIDOCTOR_PDF_FLAGS += -a pdf-theme=$(PDF_THEME)
ASCIIDOCTOR_PDF_FLAGS += -a autofit-option

REQFLOW_COMMON_FLAGS  := -type        "txt"
REQFLOW_COMMON_FLAGS  += -sort        "alphanum"
REQUIREMENTS_OPT      := $(REQFLOW_COMMON_FLAGS)
REQUIREMENTS_OPT      += -start-after "^\\\s*== Requirements"
REQUIREMENTS_OPT      += -req         "^\\\|\\\s*<<(F[pc]_[1-9]([0-9_]*[0-9])?)>>"
REQUIREMENTS_OPT      += -end-req     "^\\\|==="
REQUIREMENTS_OPT      += -stop-after  "^\\\s*== Rationals"
RATIONALS_OPT         := $(REQFLOW_COMMON_FLAGS)
RATIONALS_OPT         += -start-after "^\\\s*== Rational"
RATIONALS_OPT         += -req         "^\\\s*={4,5} (.*) \\\(\\\)$$"
RATIONALS_OPT         += -end-req     "^\\\s*={3,4} .*"
RATIONALS_OPT         += -ref         "(F[pc]_[1-9]([0-9_]*[0-9])?)"
RATIONALS_OPT         += -nocov

.POSIX:
.SUFFIXES:
.SECONDARY:
.DELETE_ON_ERROR:

all: build

build:

pdf:      $(DOCUMENTS:.adoc=.pdf)

html:     $(DOCUMENTS:.adoc=.html)

docbook:  $(DOCUMENTS:.adoc=.xml)

markdown: $(DOCUMENTS:.adoc=.md)

check:

clean:
	$(RM)  $(DOCUMENTS:.adoc=.pdf)
	$(RM)  $(DOCUMENTS:.adoc=.html)
	$(RM)  $(DOCUMENTS:.adoc=.xml)
	$(RM)  $(DOCUMENTS:.adoc=.md)
	$(RM)  $(DOCUMENTS:.adoc=.req)
	$(RM) -r $(IMAGES_DIR)
	$(RM) -r .asciidoctor

.PHONY: all build pdf html docbook markdown check clean phony

check_%: %.req phony
	RESULT=$$($(REQFLOW) -c $< 2>&1) || (printf "%s\n" "$$RESULT" && exit 1)

%.pdf:  %.adoc Makefile $(PDF_THEME)
	$(ASCIIDOCTOR_PDF) $(ASCIIDOCTOR_PDF_FLAGS)     $<

%.html: %.adoc Makefile
	$(ASCIIDOCTOR)     $(ASCIIDOCTOR_FLAGS)         $<

%.xml:  %.adoc Makefile
	$(ASCIIDOCTOR)  -b docbook $(ASCIIDOCTOR_FLAGS) $<

%.md:   %.xml
	$(DOCBOOK_TO_MARKDOWN) $< > $@

%.req: Makefile
	echo 'document $(@:.req=-requirements) -path "$(@:.req=.adoc)" $(REQUIREMENTS_OPT)' >  $@
	echo 'document $(@:.req=-rationals)    -path "$(@:.req=.adoc)" $(RATIONALS_OPT)'    >> $@
