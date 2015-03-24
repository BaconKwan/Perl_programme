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

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]", -format=>"fasta");
while(my $seq = $in->next_seq()){
	my $id = $seq->id;
	my $agct = $seq->seq;
	print ">$id\n$agct\n";
}
