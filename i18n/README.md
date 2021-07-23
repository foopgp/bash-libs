
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

This reason are quite deprecated as of Today (years 2021, bash 5 released more
than a year ago).

portability problem may have been easily inside bash. TODO: check for it.

security problems may be mitigated and avoided.

bla bla ... (explain why and how)

unset TEXTDOMAINDIR

