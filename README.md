## Name

Perl::Minify - Compress Perl source by stripping comments, POD, and
non-essential whitespace, with optional lexical-variable shortening.

## Synopsis

```perl
use Perl::Minify qw(minify minify_sub);

# Minify a whole file's worth of code
my $min = minify($source_str);

# With options (all keys optional):
my $min = minify($source_str, { shorten_vars => 1, wrap => 100 });

# Extract & minify a single sub
my $sub = minify_sub($source_str, 'color', { wrap => 80 });
```

## Functions

### minify($code, \\%opts?)

Minifies a string of Perl source. Returns the minified string, or `undef`
on PPI parse failure. By default nothing is exported; import `minify`
explicitly or via `:all`.

### minify\_sub($code, $sub\_name, \\%opts?)

Locates a named subroutine, and runs the minification pipeline on it
alone. Returns `undef` on parse failure or if no sub named `$sub_name`
is found.

## Options

All options are optional; pass them as a hashref. Unknown keys are
ignored silently. Defaults:

```perl
strip_comments    1   remove C<#> line comments
strip_pod         1   remove POD blocks
strip_whitespace  1   collapse non-significant whitespace
shorten_vars      0   rename lexicals to short names ($c, $d, ...)
wrap              0   if >0, word-wrap output to <=N columns
keep_name         1   preserve the sub name in C<minify_sub> output
```

### `shorten_vars` Limitations

Renaming is skipped for symbols that appear inside string quotes, regex
literals, `s///e` replacement blocks, heredocs, and interpolations. Symbolic
references are not renamed. The renamer uses one global per-document map, so
two distinct `my` declarations with the same name (in different scopes)
share a single short name.

### Wrap Limitation

An overlong statement with no break point that is outside a string/regex
literal is emitted as a single line that may exceed the requested width.
This never breaks a string literal mid-character.

## Author

Scottchiefbaker - https://github.com/scottchiefbaker/

## License

Same terms as Perl itself.
