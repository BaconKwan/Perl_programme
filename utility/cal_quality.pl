#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	statistics reads_cnt, total_nt, q20, N%, GC% for a fq file
	Usage: perl $0 <fq_file>

"if(@ARGV < 1);

open IN , '<' , $ARGV[0];
open OUT , '>' , "$ARGV[0].stat";

my $reads_cnt = 0;
my $total_nt = 0;
my $good_nt = 0;
my $N_cnt = 0;
my $GC_cnt = 0;

while (<IN>){
	my $read = <IN>;
	<IN>;
	my $qua = <IN>;
	chomp $read;
	chomp $qua;
	$reads_cnt += 1;
	my $len=length($read);
	$total_nt += $len;
	my @reads=split //,$read;
	my @quality=split //,$qua;
	for (my $i = 0; $i < $len; $i++){
		my $bp_qua = ord($quality[$i]) - 33;
		$good_nt += 1 if ($bp_qua >= 20);
		$N_cnt += 1 if ($reads[$i] eq "N");
		$GC_cnt += 1 if ($reads[$i] eq "G" || $reads[$i] eq "C");
	}
}

my $q20 = 100 * $good_nt / $total_nt;
my $n = 100 * $N_cnt / $total_nt;
my $gc = 100 * $GC_cnt / $total_nt;
printf OUT "Carassius\t$reads_cnt\t$total_nt\t%.2f%%\t%.2f%%\t%.2f%%\n", $q20, $n, $gc;
