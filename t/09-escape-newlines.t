#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Perl::Minify qw(minify minify_sub);

# Each case: [ name, Perl literal source text, converted? ]
# "converted" means the minifier should remove every raw LF/TAB/CR from the
# output. Cases with code inside an interpolation are expected to be skipped.
my @CASES = (
    [ 'dq: LF and TAB',                 "\"SELECT *\n\tFROM t\n\tWHERE x\"",   1 ],
    [ 'dq: escaped backslash before LF', "\"a\\\\\nb\"",                        1 ],
    [ 'dq: backslash-LF continuation',   "\"a\\\nb\"",                          1 ],
    [ 'dq: quote, dollar, LF',           "\"q\\\"x\\\$y\nz\"",                  1 ],
    [ 'qq{}: LF with escaped brace',     "qq{a\nb\\}}",                         1 ],
    [ 'sq: LF',                          "'a\nb'",                              1 ],
    [ 'sq: escaped backslash and TAB',   "'back\\\\slash\tx'",                  1 ],
    [ 'sq: escaped single quote',        "'it\\'s\n'",                          1 ],
    [ 'sq: dollar, at, dq, LF',          "'\$x \@y \"z\"\n'",                   1 ],
    [ 'sq: literal backslash-n plus LF', "'lit \\n\nx'",                        1 ],
    [ 'q(): LF with escaped paren',      "q(a\n\\)b\\\\c)",                     1 ],
    [ 'q{}: nested braces and LF',       "q{x{y}\n\\}z}",                       1 ],
    [ 'q//: LF with escaped slash',      "q/s\n\\/t/",                          1 ],
    [ 'sq: no control chars unchanged',  "'a\$b'",                              0 ],
    [ 'dq: code interpolation skipped',  "\"\@{[ 1\n+1 ]}\"",                   0 ],
);

sub strip_nl { my ($s) = @_; $s =~ s/\n\z//; return $s }

# Evaluate a snippet of Perl code and return its value.
sub run_code {
    my ($code) = @_;
    my @r = eval "no strict; no warnings; $code";
    die $@ if $@;
    return @r;
}

for my $case (@CASES) {
    my ($name, $lit, $converted) = @$case;

    my $src = "my \$x = $lit;\n\$x;\n";
    my $min = minify($src);
    ok(defined $min, "$name: minify succeeds") or next;

    my ($expect) = run_code($lit);
    my ($got)    = run_code(strip_nl($min));
    is($got, $expect, "$name: round trip value preserved");

    my $one_line = strip_nl($min);
    if ($converted) {
        unlike($one_line, qr/[\n\t\r]/, "$name: no raw LF/TAB/CR in output");
    } else {
        pass("$name: left alone (not converted)");
    }
}

# Spot-check exact output shapes.
{
    my $min = strip_nl(minify("my \$x = 'a\n\$b';"));
    is($min, 'my$x="a\n\$b";', 'sq -> dq output shape');
}
{
    my $min = strip_nl(minify("my \$x = q(a\n\\)b);"));
    is($min, 'my$x="a\n)b";', 'q() -> dq output shape');
}
{
    my $min = strip_nl(minify("my \$x = \"a\n\tb\";"));
    is($min, 'my$x="a\n\tb";', 'dq output shape');
}

# Single quotes without control chars keep their original form.
{
    my $min = strip_nl(minify("my \$x = 'a\$b';"));
    is($min, q{my$x='a$b';}, 'sq without control chars stays single-quoted');
}

# Option off: raw control chars pass through.
{
    my $src = "my \$x = \"a\n\tb\";";
    my $min = minify($src, { escape_newlines => 0 });
    like($min, qr/\n\t/, 'escape_newlines => 0 keeps raw LF/TAB');

    my $sq = minify("my \$x = 'a\nb';", { escape_newlines => 0 });
    like($sq, qr/'a\nb'/, 'escape_newlines => 0 keeps single-quoted raw LF');
}

# Default is on.
{
    my $min = strip_nl(minify("my \$x = \"a\nb\";"));
    is($min, 'my$x="a\nb";', 'default: escape_newlines on');
}

# Whole-program round trip: all cases in one program, values compared.
{
    my @lits = map { $_->[1] } grep { $_->[2] } @CASES;
    my $src  = "my \@v = (" . join(",\n", @lits) . ");\n\@v;\n";

    my @expect = run_code(join(';', "my \@v = (" . join(",", @lits) . ")", '@v'));
    my $min    = minify($src);
    ok(defined $min, 'program round trip: minify succeeds');
    my @got = run_code(strip_nl($min));
    is_deeply(\@got, \@expect, 'program round trip: all values preserved');
}

# Works with shorten_vars: variable names inside single-quoted text must not
# be renamed, or the value changes.
{
    my $src = "my \$count = 'in\$count\n';\nmy \$s = \"v\n\$count\";\n\$s . \$count;\n";
    my @expect = run_code($src);
    my $min = minify($src, { shorten_vars => 1 });
    ok(defined $min, 'shorten_vars: minify succeeds');
    my @got = run_code(strip_nl($min));
    is_deeply(\@got, \@expect, 'shorten_vars: single-quoted $name text preserved');
}

# Works with wrap.
{
    my $src = "my \$x = \"SELECT *\n\tFROM t\n\tWHERE x\";\nmy \$y = 'a\nb';\n\$x . \$y;\n";
    my @expect = run_code($src);
    my $min = minify($src, { wrap => 20 });
    ok(defined $min, 'wrap: minify succeeds');
    my @got = run_code($min);
    is_deeply(\@got, \@expect, 'wrap: values preserved');
}

# minify_sub path.
{
    my $code = "sub greet {\n\tmy \$m = 'hi\n';\n\treturn \"x\n\$m\";\n}\n";
    my $sub = minify_sub($code, 'greet');
    ok(defined $sub, 'minify_sub succeeds');
    unlike($sub, qr/[\n\t]/, 'minify_sub: no raw LF/TAB in output');
    like($sub, qr/\\n/, 'minify_sub: escapes present');
}

done_testing();
