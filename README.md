<!--
© 2024 Henri GEIST <geist.henri@laposte.net>

SPDX-License-Identifier: CC-BY-SA-4.0+
-->

# Prerequisites

## For just installing and using the bash-libs

```sh
sudo apt install logger bash-completion
```

## To generate the specification documentation as HTML and PDF.

You need to install also:

```sh
sudo apt install asciidoctor ruby-asciidoctor-pdf ditaa graphviz ruby-rubygems
gem install asciidoctor-diagram

```

## To be able to run the units tests

You also need:

```sh
sudo apt install shellcheck bats bats-assert bats-file tappy gawk socat lsof
git clone https://github.com/goeb/reqflow.git
cd reqflow
./configure
make
make install
```

## Before committing something

Please before committing anything ensure the tests are executed and passed.

To not forget it install the git 'pre-commit' hook by running:

```sh
make install-pre-commit-hook
```

# Installation

Just type:

```sh
make
sudo make install
```

For uninstalling type:

```sh
sudo make uninstall
```

# Usage

[Please read the bash-libs 3 manpage](man/bash-libs.7.md)
