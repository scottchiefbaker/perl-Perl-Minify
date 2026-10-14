# CHANGELOG

## 0.03

- Add `shorten_vars` option to rename lexical variables to short names.
- Add `wrap` option to word-wrap output to a maximum column width (string/regex aware).
- Add `strip_semicolons` option (default on) to drop safe terminators before `}`.
- Add `keep_name` option (default on) to `minify_sub`; set to 0 for an anonymous `sub { }`.
- Add `minify_sub` to extract and minify a single named subroutine.
- Add `minify_error` accessor and `$Perl::Minify::ERROR` for error reporting.
- Add `optimize` option (EXPERIMENTAL) for constant folding of `Number +/-/* Number` chains.
- Add `minify.pl --sub NAME` to emit a single named subroutine.
- `minify.pl` reports parse errors to STDERR and exits 1.
- Treat `tr///` / `y///` transliteration as unsafe for wrapping.
- Integration: verify minified output compiles with `perl -c`.
