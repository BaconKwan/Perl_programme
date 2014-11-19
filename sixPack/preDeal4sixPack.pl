#! /usr/bin/perl
use strict;
use utf8;
use warnings;
use Bio::SeqIO;

die"perl $0 <cds.fa> > out.fa\n" unless(@ARGV eq 1);

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]",-format=>"fasta");
while (my $seq = $in->next_seq()){
	my $reseq = $seq->revcom;
	my $tmp_id = $seq->id;
	my $tmp_seq = $seq->seq;
	my $re_tmp_id = $reseq->id;
	my $re_tmp_seq = $reseq->seq;

	for(my $i = 1; $i <= 3; $i++){
		my $tag = 7 - $i;
		my $tmp_desc = "F$i";
		my $re_tmp_desc = "F$tag";
		print ">$tmp_id $tmp_desc\n$tmp_seq\n";
		print ">$re_tmp_id $re_tmp_desc\n$re_tmp_seq\n";
		$tmp_seq =~ s/^\w//;
		$re_tmp_seq =~ s/^\w//;
	}
}
