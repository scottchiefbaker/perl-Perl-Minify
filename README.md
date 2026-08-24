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

### minify\_error()

Returns the last error message set by a failed `minify` or
`minify_sub` call (also available as `$Perl::Minify::ERROR`). Returns
an empty string when the most recent call succeeded.

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

## Command Line Script

This distribution ships a small wrapper script, `minify.pl`, that minifies a
Perl source file and prints the result to STDOUT. It always enables variable
shortening and accepts an optional line-width for word wrapping.

```
# Minify a file (variable shortening on, no wrapping)
perl minify.pl script.pl

# Minify and wrap output to 80 columns
perl minify.pl script.pl --width 80

# Redirect to a file
perl minify.pl script.pl --width 80 > script.min.pl
```

### Arguments

- `FILE`

    Path to the Perl source file to minify (required). The script dies with a
    usage message if the file is missing or unreadable.

- `--width N`

    If given, word-wraps the minified output to at most `N` columns. Omit it to
    emit a single, unwrapped line.

The script never overwrites the input; capture its STDOUT to save the result.
Internally it calls `minify` with `{ shorten_vars => 1, wrap => $width }`.

## Author

Scottchiefbaker - https://github.com/scottchiefbaker/

## License

Same terms as Perl itself.
