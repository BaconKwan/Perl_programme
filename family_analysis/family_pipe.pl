#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die"
	perl $0 <fasta_file> <tag> ... <fasta_file> <tag>

"if(@ARGV%2 ne 0 || @ARGV eq 0);

$/ = "\n>";
open GG, "> all.gg" || die $!;
for(my $i =0; $i <= $#ARGV; $i++){
	open FA, "< $ARGV[$i]" || die $!;
	open OUT, "> $ARGV[$i].cut_mark" ||die $!;
	$i++;
	print GG "$ARGV[$i]: ";
	while(<FA>){
		s/>//g;
		s/(\S+).*\n/>$1_$ARGV[$i]\n/;
		print OUT;
		print GG "$1_$ARGV[$i] ";
	}
	print GG "\n";
	close OUT;
	close FA;
}
close GG;
$/ = "\n";

open SH,"> run.sh" || die $!;
print SH "cat *.cut_mark > all.pep\n";
print SH "formatdb -i all.pep -p T\n";
print SH "blastall -p blastp -m8 -e 1e-5 -F F -d all.pep -i all.pep -o blastp.m8 -a 3\n";
print SH "perl orthomcl.pl --mode 3 -blast_file blastp.m8 --gg_file all.gg\n";
close SH;
