#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;

use FindBin qw($RealBin);
use lib "$RealBin/lib";

use Perl::Minify qw(minify minify_sub);

# Read the sample source file.
my $source_file = "$RealBin/color.pl";
open(my $fh, '<', $source_file) or die "Cannot open $source_file: $!";
local $/;
my $source = <$fh>;
close $fh;

say "################ source ###############";
say $source;

say "################ minified (defaults) ###############";
my $min = minify($source);
print $min;
say "---- (length: ", length($min), ")";

say '';
say "################ minified + shorten_vars ###############";
my $sv = minify($source, { shorten_vars => 1 });
print $sv;
say "---- (length: ", length($sv), ")";

say '';
say "################ minified + wrap=60 ###############";
my $w = minify($source, { wrap => 60 });
print $w;
say "---- (length: ", length($w), ")";

say '';
say "################ minify_sub('color') ###############";
my $sub = minify_sub($source, 'color', { shorten_vars => 1 });
print $sub;
say "---- (length: ", length($sub), ")";

say '';
say "################ minify_sub('color 80') ###############";
my $sub2 = minify_sub($source, 'color', { shorten_vars => 1, wrap => 80 });
print $sub2;
say "---- (length: ", length($sub), ")";

say '';
say "################ minify_sub('nonexistent') ###############";
my $none = minify_sub($source, 'does_not_exist');
print defined($none) ? $none : "(undef, as expected)\n";

say '';
say "################ perl -c round-trip on defaults-minified ###############";
my $tmpfile = "/tmp/minified_default_$$.pl";
open(my $out, '>', $tmpfile) or die $!;
print $out $min;
close $out;
system("perl -c $tmpfile");
unlink $tmpfile;

say '';
say "################ perl -c on shorten_vars output ###############";
$tmpfile = "/tmp/minified_sv_$$.pl";
open($out, '>', $tmpfile) or die $!;
print $out $sv;
close $out;
system("perl -c $tmpfile");
unlink $tmpfile;
