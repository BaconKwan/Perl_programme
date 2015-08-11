#! /usr/bin/perl
use strict;
use utf8;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

die"perl $0 <fa> \n" unless(@ARGV eq 1);

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]", -format=>"fasta");
my %hash;

while (my $seq = $in->next_seq()){
	my ($gene) = $seq->id =~ /(\w+)\.\d+/;
	if(exists $hash{$gene}){
		if($hash{$gene}{l} < $seq->length){
			$hash{$gene}{t} = $seq->id;
			$hash{$gene}{l} = $seq->length;
		}
	}
	else{
		$hash{$gene}{t} = $seq->id;
		$hash{$gene}{l} = $seq->length;
	}
}

foreach my $gene (keys %hash){
	print "$gene\t$hash{$gene}{t}\n";
}
