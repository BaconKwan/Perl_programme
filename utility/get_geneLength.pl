#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	statistics length of each gene in a fasta file
	Usage: perl $0 <fasta_file>

"if(@ARGV != 1);

open OUTF , '>' , "$ARGV[0].length"|| die $!;

$/ = "\n>";
while(<>){
	s/>//g;
	if(/^.+\n/){
		my $index = $&;
		my $seq = $';
		$index =~ s/\n//g;
		$seq =~ s/\n//g;
		my $len = length $seq;
		print OUTF  "$index  $len\n";
		#print "$index $seq \n";
	}
}
