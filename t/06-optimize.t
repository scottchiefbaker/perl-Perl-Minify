#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Perl::Minify qw(minify);

# Test experimental optimization features

# 1. Constant folding - basic arithmetic
my $r1 = minify('my $x = 2 + 3;', { optimize => 1 });
ok defined($r1), 'constant folding returns defined';
# The optimization may or may not trigger, so we just check it doesn't break
like $r1, qr/my\$x=/, 'basic structure preserved' or diag "got: $r1";

# 2. Dead code elimination - code after return
my $r2 = minify('sub f { return 1; my $dead = 2; }', { optimize => 1 });
ok defined($r2), 'dead code elimination returns defined';
# Check that the sub still works
like $r2, qr/sub f/, 'sub preserved' or diag "got: $r2";

# 3. Optimization doesn't break normal code
my $r3 = minify('my $x = 1; my $y = 2; print $x + $y;', { optimize => 1 });
ok defined($r3), 'optimization with normal code works';
like $r3, qr/print/, 'print statement preserved' or diag "got: $r3";

# 4. Optimization can be disabled (default)
my $r4 = minify('my $x = 2 + 3;');
ok defined($r4), 'default (no optimize) works';
like $r4, qr/2\+3/, 'expression not optimized by default' or diag "got: $r4";

done_testing;
