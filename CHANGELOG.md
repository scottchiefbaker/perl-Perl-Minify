# CHANGELOG

## 0.03

- Add `shorten_vars` option to rename lexical variables to short names.
- Add `wrap` option to word-wrap output to a maximum column width (string/regex aware).
- Add `minify_sub` to extract and minify a single named subroutine.
- Add `minify_error` accessor and `$Perl::Minify::ERROR` for error reporting.
- Add `optimize` option (EXPERIMENTAL) for constant folding / dead-code removal.
- Treat `tr///` / `y///` transliteration as unsafe for wrapping.
- Integration: verify minified output compiles with `perl -c`.
