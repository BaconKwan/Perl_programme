#! /usr/bin/perl
use strict;
use utf8;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

die"perl $0 <fa> \n" unless(@ARGV eq 1);

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]", -format=>"fasta");

while (my $seq = $in->next_seq()){
	my $id = $seq->id;
	my $bases = $seq->seq;

	print "PRIMER_SEQUENCE_ID=$id\nSEQUENCE=$bases\n=\n";
}
