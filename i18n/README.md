
# About using gettext to internationalize bash-written software

I really plan to use this bash feature:

>       A double-quoted string preceded by a dollar sign ($"string") will cause the string to be translated according to the current locale.  The gettext infrastructure performs the mes‐
>       sage catalog lookup and translation, using the LC_MESSAGES and TEXTDOMAIN shell variables.  If the current locale is C or POSIX, or if there are no  translations  available,  the
>       dollar sign is ignored.  If the string is translated and replaced, the replacement is double-quoted.

even if it is **discouraged** by GNU gettext, cf.:
https://www.gnu.org/software/gettext/manual/gettext.html#bash

> GNU bash 2.0 or newer has a special shorthand for translating a string and substituting variable values in it: $"msgid". But the use of this construct is discouraged, due to the security holes it opens and due to its portability problems.
>
> The security holes of $"..." come from the fact that after looking up the translation of the string, bash processes it like it processes any double-quoted string: dollar and backquote processing, like ‘eval’ does.
>
>     In a locale whose encoding is one of BIG5, BIG5-HKSCS, GBK, GB18030, SHIFT_JIS, JOHAB, some double-byte characters have a second byte whose value is 0x60. For example, the byte sequence \xe0\x60 is a single character in these locales. Many versions of bash (all versions up to bash-2.05, and newer versions on platforms without mbsrtowcs() function) don’t know about character boundaries and see a backquote character where there is only a particular Chinese character. Thus it can start executing part of the translation as a command list. This situation can occur even without the translator being aware of it: if the translator provides translations in the UTF-8 encoding, it is the gettext() function which will, during its conversion from the translator’s encoding to the user’s locale’s encoding, produce the dangerous \x60 bytes.
>     A translator could - voluntarily or inadvertently - use backquotes "`...`" or dollar-parentheses "$(...)" in her translations. The enclosed strings would be executed as command lists by the shell.
>
> The portability problem is that bash must be built with internationalization support; this is normally not the case on systems that don’t have the gettext() function in libc.


Today (2021, bash 5 released more than a year ago), are this reasons still
actual or quite deprecated ?

## Is there a portability problem ?

If this feature is deactivated when bash is built without internationalization
support, that sounds the expected behaviour and... What is the problem ?

Indeed, I really expect bash to contain such kind of code:
```c
#ifdef HAVE_DGETTEXT
if is_env_set("TEXTDOMAIN")
{
	str_parse=dgettext(env("TEXTDOMAIN"),str_read) ;
}
else
#endif
{
	str_parse=str_read;
}
```
**TODO**: check for it.

*NOTE: bash should maybe manage also a TEXTCATEGORY env variable, to map
the dcgettext() function.*

## Security problems may be mitigated and avoided.

For the previously stated security issues, GNU gettext recommends to use, instead
of this *$"string"* feature, an ugly workaround which is certainly more portable,
but decrease greatly code readability (while increasing greatly required code to
be interpreted...) :

```shell
#!/bin/sh
# Example for use of GNU gettext.
# This file is in the public domain.
#
# Source code of the POSIX sh program.

. gettext.sh

TEXTDOMAIN=hello-sh
export TEXTDOMAIN
TEXTDOMAINDIR='@localedir@'
export TEXTDOMAINDIR

gettext "Hello, world!"; echo

pid=$$
eval_gettext "This program is running as process number \$pid."; echo
```

I agree to see such "horror" in file like /usr/lib/git-core/git-sh-i18n which
must be portable. I am more disturbed to see people wasting time writing such
patch: https://sourceware.org/legacy-ml/libc-alpha/2012-11/msg00712.html

*Note: I wrote also such code before finalizing my reflection*

To be honest the only reason for this security issues, is that bash (like other
shells) parse and act upon translated string like on any other normal strings
defined between double quotes « " ».

Then translators which use to follow non-developers processes (eg: less git
or review), have the power to do - voluntarily or inadvertently - very nasty
things in a bash program that use the *$"string"* feature.

Moreover hackers may also do very nasty things to such program, by changing
TEXTDOMAINDIR or TEXTDOMAIN environment variables to make any bash code using
that feature running some malevolent code placed into forged \*.mo files.


Then the workaround I plan to use, is to:
 * Forbid any «`» or «$» in strings-to-be-translated
 * Manage \*.po files like source code, using the same git repository
 * check and forbid any presence of «`» or «$» in \*.po files
 * set TEXTDOMAIN and unset TEXTDOMAINDIR when used as an executable
 * add a security paragraph in manuals to care about \*.mo files when used as a
   library
 * maybe add an option to manage TEXTDOMAINDIR when sourced or invoked


Shellcheck already have https://github.com/koalaman/shellcheck/wiki/SC2059
> SC2059: Don't use variables in the printf format string. Use printf '..%s..' "$foo".

Why not having ? :
> Don't use variables in strings to be translated. Cut your string: $"...""$foo"
> or use printf '..%s..' "$foo".

Finally, what I really **love** to see in bash, is a *$'string'* feature, which
doesn't parse any «`» or «$» characters.

Whe should then warn that setting TEXTDOMAIN may change behaviour of this syntax
already used whith numerous *$'\n'*. It may break some compatibility, but I
bet there is no existent case on this planet (and before I wrote this !).

Does bash developers agree ?

