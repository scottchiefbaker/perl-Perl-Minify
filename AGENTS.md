# Perl::Minify — agent notes

## Layout

```
lib/Perl/Minify.pm   # single-module dist (Perl::Minify, v0.4.0)
minify.pl            # CLI wrapper (installed as EXE_FILES)
t/                   # 9 test files
color.pl             # fixture for integration-compile.t and bench.pl
example.pl           # run with: perl -Ilib example.pl
```

## Commands

```sh
perl -c lib/Perl/Minify.pm   # compile check
prove -lv t/                 # run all tests
prove -lv t/foo.t            # single test file
```

Release build: `perl Makefile.PL && make && make test && make distcheck && make dist`.

## Versioning

- Odd minor versions (0.03, 0.05, ...) are development releases.
- Even minor versions (0.02, 0.04, ...) are production releases.
- Set the version in `lib/Perl/Minify.pm` (`$VERSION`) and add a matching `CHANGELOG.md` entry.

## Public API

- `minify($code, \%opts?)` — minify Perl source string, returns string or `undef`
- `minify_sub($code, $sub_name, \%opts?)` — extract one sub as bare source text (named by default; `keep_name => 0` gives `sub { }`), or `undef`
- `minify_error()` — last error message from a failed call
- Nothing exported by default; import with `qw(minify minify_sub)` or `:all`
- Options hashref: `strip_comments`, `strip_pod`, `strip_whitespace`, `strip_semicolons`, `keep_name` (all default 1), `shorten_vars` (0), `wrap` (0), `optimize` (0, experimental constant folding). Unknown keys ignored.

## Requirements

- Perl v5.16+ (uses `state` keyword)
- `PPI` (CPAN) — install with `cpan PPI`
- `Scalar::Util` (core)
- `Getopt::Long` (core, for minify.pl)
- `File::Temp`, `FindBin`, `Test::More` (core, for the tests; integration-compile.t)

## Quirks

- `PPI::Document->find()` may return empty string `""` (not `undef` or arrayref) when no matches exist. Guard with `ref $found eq 'ARRAY'` before dereferencing.
- `shorten_vars` skips symbols inside strings, regex, heredocs, and interpolation. For code using `state %map; ... s///$map{$1}//eg`, the regex-referenced `$map` won't be renamed and compilation will fail — the integration test avoids this case.
- Integration test wraps `minify_sub` output in `use v5.16; ... __END__` so `perl -c` works with `state`.
