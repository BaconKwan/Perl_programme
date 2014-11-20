#! /usr/bin/perl
use strict;
use utf8;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

die"perl $0 <cds.fa> <out.fa>\n" unless(@ARGV eq 2);

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]", -format=>"fasta");
my $out = Bio::SeqIO->new(-file=>"> $ARGV[1]", -format=>"fasta");

while (my $seq = $in->next_seq()){
	my $reseq = $seq->revcom;
	my $tmp_seq = $seq->seq;
	my $re_tmp_seq = $reseq->seq;

	for(my $i = 1; $i <= 3; $i++){
		my $tag = 7 - $i;
		my $desc = "F$i";
		my $redesc = "F$tag";

		my $pep = Bio::Seq->new(-seq=>$tmp_seq, -display_id=>$seq->id, -desc=>$desc);
		my $repep = Bio::Seq->new(-seq=>$re_tmp_seq, -display_id=>$reseq->id, -desc=>$redesc);
		$pep = $pep->translate;
		$repep = $repep->translate;

		my ($pep_seq) = $pep->seq =~ /^([^*]+)/;
		my ($repep_seq) = $repep->seq =~ /^([^*]+)/;

		$pep->seq($pep_seq);
		$repep->seq($repep_seq);

		$out->write_seq($pep) if($pep->length >= 50);
		$out->write_seq($repep) if($repep->length >= 50);

		$tmp_seq =~ s/^\w//;
		$re_tmp_seq =~ s/^\w//;
	}
}
