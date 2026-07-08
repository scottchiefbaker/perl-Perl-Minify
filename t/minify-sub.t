#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Perl::Minify qw(minify_sub);

# Fixture with multiple subs
my $code = <<'END_PERL';
sub color {
    my ($str, $txt) = @_;
    return "\e[0m";
}

sub other {
    my $x = 1;
    return $x;
}

# Nested: outer contains inner
sub outer {
    my $var = 10;
    sub inner {
        my $y = 20;
        return $y;
    }
    return $var;
}
END_PERL

# 1. Extract 'color' -> anonymous sub { }
my $r1 = minify_sub($code, 'color');
ok defined($r1), 'minify_sub color returns defined';
ok $r1 =~ /^sub\s*\{/, 'color output starts with sub {' or diag "got: $r1";
ok $r1 !~ /\bsub color\b/, 'color sub name stripped' or diag "got: $r1";

# 2. Nonexistent sub -> undef
my $r2 = minify_sub($code, 'nonexistent');
ok !defined($r2), 'nonexistent sub returns undef';

# 3. Nested sub (inner) extracted correctly
my $r3 = minify_sub($code, 'inner', { shorten_vars => 1 });
ok defined($r3), 'minify_sub inner returns defined';
ok $r3 =~ /^sub\s*\{/, 'inner output starts with sub {' or diag "got: $r3";
ok $r3 =~ /\$c\b/, 'inner: $y shortened to $c' or diag "got: $r3";

# 4. Empty code -> undef
my $r4 = minify_sub('', 'anything');
ok !defined($r4), 'empty code returns undef';

# 5. Options passed through (wrap)
my $r5 = minify_sub($code, 'color', { wrap => 40 });
ok defined($r5), 'minify_sub with wrap returns defined';
for my $line (split "\n", $r5) {
    ok length($line) <= 40, "wrap: line length ${\length($line)} <= 40"
        or diag "Overlong: [$line]";
}

# 6. keep_name preserves the sub name
my $r6 = minify_sub($code, 'color', { keep_name => 1 });
ok defined($r6), 'minify_sub color with keep_name returns defined';
ok $r6 =~ /^sub\s+color\s*\{/, 'color sub name preserved' or diag "got: $r6";

done_testing;
