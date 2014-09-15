#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "
	Usage: perl $0 <fasta_file>

"unless(@ARGV eq 1);

my %hash;

open FA, "< $ARGV[0]" || die $!;
open OUT, "> $ARGV[0].chromosome.len" || die $!;
$/ = "\n>";
my $chr = "A";
while(<FA>){
	s/>//g;
	my $name = $1 if(s/^(\w+).*\n//);
#s/\n//g;
	my $length = tr/agctAGCTnN/agctAGCTnN/;
	print OUT "$name\t$chr\t1\t$length\tchr1\n";
	$chr++;
#foreach my $c (split "", $_){
#$hash{$c} += 1;
#}
}
close OUT;
close FA;

#foreach my $c (keys %hash){
#print "$c\t$hash{$c}\n";
#}
