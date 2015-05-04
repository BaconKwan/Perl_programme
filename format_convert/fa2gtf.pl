#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Bio::SeqIO;

die "perl $0 <fa> > <out>\n" unless(@ARGV eq 1);

my $in = Bio::SeqIO->new(-file => "< $ARGV[0]", -format => "fasta");

while(my $seq = $in->next_seq()){
	my $len = $seq->length;
	my $id = $seq->id;
	print "$id\tprotein_coding\texon\t1\t$len\t.\t+\t.\tgene_id \"$id\"\; transcript_id \"$id\"\;\n";
}
