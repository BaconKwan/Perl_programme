#! /usr/bin/perl
use strict;
use utf8;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

die"perl $0 <fa> \n" unless(@ARGV eq 1);

my $in = Bio::SeqIO->new(-file=>"< $ARGV[0]", -format=>"fasta");

print "Seq ID\tLength\tA%\tG%\tC%\tT%\tN%\tX%\n";
while (my $seq = $in->next_seq()){
	my $len = $seq->length;
	my $a = $seq->seq =~ tr/Aa/Aa/;
	my $g = $seq->seq =~ tr/Gg/Gg/;
	my $c = $seq->seq =~ tr/Cc/Cc/;
	my $t = $seq->seq =~ tr/Tt/Tt/;
	my $n = $seq->seq =~ tr/Nn/Nn/;
	my $x = 100 * ($len - $a - $g - $c - $t - $n) / $len;

	$a = 100 * $a / $len;
	$g = 100 * $g / $len;
	$c = 100 * $c / $len;
	$t = 100 * $t / $len;
	$n = 100 * $n / $len;

	printf("%s\t%d\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\n", $seq->id, $len, $a, $g, $c, $t, $n, $x);
}
